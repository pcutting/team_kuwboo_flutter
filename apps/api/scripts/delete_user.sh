#!/usr/bin/env bash
# delete_user.sh — ops-only hard delete for a Kuwboo user.
#
# PURPOSE:
#   Wipe a test account and every row that references it, during prototype
#   testing. NOT a production deletion flow (no GDPR logging, no soft-delete,
#   no audit trail beyond this script's stdout).
#
# DESIGN:
#   - Discovers every FK pointing at users.id dynamically from
#     information_schema, so new schema additions are covered automatically.
#   - Dry-run by default. Requires --confirm to mutate.
#   - Refuses to run against real-looking accounts (has email, has ADMIN role)
#     unless an explicit override flag is passed.
#   - Single transaction: loops DELETEs up to 3 passes until no rows remain,
#     then deletes the user row. ROLLBACK on any residual FK violation.
#
# REQUIREMENTS (assumed on the runtime host, i.e. EC2 ubuntu user):
#   - psql (PostgreSQL client) reachable to the RDS VPC endpoint
#   - aws CLI + IAM permission to read the RDS master secret
#   - python3 (for JSON parsing)
#
# USAGE:
#   bash delete_user.sh --by phone --value "+16142856112"             # dry-run
#   bash delete_user.sh --by email --value "foo@bar.com" --confirm     # mutate
#   bash delete_user.sh --by id    --value "aaaa-bbbb-..." --confirm
#
# Flags:
#   --by {phone|email|id}         How to look up the target user (required)
#   --value <value>               Lookup value (required)
#   --confirm                     Actually run DELETEs. Default: dry-run.
#   --allow-email-users           Permit deleting a user with a non-NULL email.
#   --allow-admin                 Permit deleting a user whose role is ADMIN/SUPER_ADMIN.
#   --help                        Print this help.

set -euo pipefail

# ---- Config (hard-coded — this is an ops script, not an app) ---------------
PG_HOST="${PG_HOST:-kuwboo-greenfield-db.cepsv4bfmn1r.eu-west-2.rds.amazonaws.com}"
PG_USER="${PG_USER:-kuwboo_admin}"
PG_DB="${PG_DB:-kuwboo}"
PG_SECRET_ID="${PG_SECRET_ID:-rds!db-8f61fdd3-bc92-4705-b576-0593a8c2417a}"
AWS_REGION_ENV="${AWS_REGION:-eu-west-2}"
AWS_PROFILE_ARG=""
if [[ -n "${AWS_PROFILE:-}" ]]; then
  AWS_PROFILE_ARG="--profile ${AWS_PROFILE}"
fi
export PGSSLMODE=require

# ---- Arg parsing -----------------------------------------------------------
BY=""
VALUE=""
CONFIRM=0
ALLOW_EMAIL=0
ALLOW_ADMIN=0

die() { echo "ERROR: $*" >&2; exit 1; }
log() { echo "[$(date -u +%H:%M:%SZ)] $*"; }

usage() { sed -n '2,30p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --by)                   BY="${2:-}"; shift 2 ;;
    --value)                VALUE="${2:-}"; shift 2 ;;
    --confirm)              CONFIRM=1; shift ;;
    --allow-email-users)    ALLOW_EMAIL=1; shift ;;
    --allow-admin)          ALLOW_ADMIN=1; shift ;;
    --help|-h)              usage; exit 0 ;;
    *) die "Unknown flag: $1 (use --help)" ;;
  esac
done

[[ -z "$BY" || -z "$VALUE" ]] && { usage; die "--by and --value are required"; }
case "$BY" in phone|email|id) ;; *) die "--by must be one of: phone, email, id" ;; esac

# ---- Resolve password from Secrets Manager ---------------------------------
log "Fetching DB password from Secrets Manager (${PG_SECRET_ID})"
PGPASSWORD_VAL=$(aws $AWS_PROFILE_ARG --region "$AWS_REGION_ENV" secretsmanager get-secret-value \
  --secret-id "$PG_SECRET_ID" \
  --query SecretString --output text \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])')
[[ -n "$PGPASSWORD_VAL" ]] || die "Could not retrieve DB password"
export PGPASSWORD="$PGPASSWORD_VAL"

PSQL=(psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1)

# ---- Resolve target user id ------------------------------------------------
# Lookup priority:
#   by=id     -> users.id
#   by=email  -> users.email
#   by=phone  -> users.phone OR credentials.identifier (phone-based creds)
case "$BY" in
  id)
    RESOLVE_SQL="SELECT id, email, role FROM users WHERE id = '${VALUE//\'/\'\'}'::uuid AND deleted_at IS NULL;"
    ;;
  email)
    RESOLVE_SQL="SELECT id, email, role FROM users WHERE lower(email) = lower('${VALUE//\'/\'\'}') AND deleted_at IS NULL;"
    ;;
  phone)
    RESOLVE_SQL="
      SELECT DISTINCT u.id, u.email, u.role
      FROM users u
      LEFT JOIN credentials c ON c.user_id = u.id
      WHERE u.deleted_at IS NULL
        AND (u.phone = '${VALUE//\'/\'\'}'
             OR c.identifier = '${VALUE//\'/\'\'}');
    "
    ;;
esac

log "Resolving user by ${BY}='${VALUE}'"
RESULT=$("${PSQL[@]}" -At -F '|' -c "$RESOLVE_SQL")
if [[ -z "$RESULT" ]]; then
  die "No user found matching ${BY}='${VALUE}'"
fi
MATCH_COUNT=$(printf '%s\n' "$RESULT" | grep -c '^' || true)
if [[ "$MATCH_COUNT" -gt 1 ]]; then
  echo "ERROR: Multiple users matched ${BY}='${VALUE}':" >&2
  printf '%s\n' "$RESULT" >&2
  exit 1
fi

USER_ID=$(printf '%s' "$RESULT" | cut -d'|' -f1)
USER_EMAIL=$(printf '%s' "$RESULT" | cut -d'|' -f2)
USER_ROLE=$(printf '%s' "$RESULT" | cut -d'|' -f3)
log "Resolved user id=${USER_ID} email='${USER_EMAIL}' role='${USER_ROLE}'"

# ---- Safety gates ----------------------------------------------------------
if [[ -n "$USER_EMAIL" && "$ALLOW_EMAIL" -ne 1 ]]; then
  die "Refusing: user has an email ('${USER_EMAIL}'). Re-run with --allow-email-users if this is intentional."
fi
case "${USER_ROLE^^}" in
  ADMIN|SUPER_ADMIN|SUPERADMIN|MODERATOR)
    if [[ "$ALLOW_ADMIN" -ne 1 ]]; then
      die "Refusing: user role is '${USER_ROLE}'. Re-run with --allow-admin if this is intentional."
    fi
    ;;
esac

# ---- Enumerate FKs that reference users.id or users.username ---------------
log "Enumerating FKs referencing users(id|username) from information_schema"
FK_SQL=$(cat <<'SQL'
SELECT
  tc.table_name      AS child_table,
  kcu.column_name    AS child_column,
  ccu.column_name    AS parent_column,
  rc.delete_rule,
  tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema   = kcu.table_schema
JOIN information_schema.referential_constraints rc
  ON tc.constraint_name = rc.constraint_name
 AND tc.table_schema   = rc.constraint_schema
JOIN information_schema.constraint_column_usage ccu
  ON rc.unique_constraint_name   = ccu.constraint_name
 AND rc.unique_constraint_schema = ccu.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name  = 'users'
  AND ccu.column_name IN ('id','username')
  AND rc.delete_rule <> 'CASCADE'
  AND rc.delete_rule <> 'SET NULL'
ORDER BY tc.table_name, kcu.column_name;
SQL
)
FKS=$("${PSQL[@]}" -At -F '|' -c "$FK_SQL")
if [[ -z "$FKS" ]]; then
  log "No non-CASCADE/SET NULL FKs found. Proceeding to user delete."
fi

# ---- Dry-run counts per FK -------------------------------------------------
echo
log "--- Row counts that reference user ${USER_ID} ---"
TOTAL_ROWS=0
TABLES_TOUCHED=0
# users.username lookup (if any FKs ref username)
USERNAME=$("${PSQL[@]}" -At -c "SELECT username FROM users WHERE id = '${USER_ID}'::uuid;")

declare -a DELETE_STMTS=()

while IFS='|' read -r TBL COL PARENT_COL DELRULE CNAME; do
  [[ -z "$TBL" ]] && continue
  if [[ "$PARENT_COL" == "id" ]]; then
    WHERE="${COL} = '${USER_ID}'::uuid"
  else
    if [[ -z "$USERNAME" ]]; then
      continue
    fi
    WHERE="${COL} = '${USERNAME//\'/\'\'}'"
  fi
  COUNT=$("${PSQL[@]}" -At -c "SELECT COUNT(*) FROM ${TBL} WHERE ${WHERE};")
  printf '  %-32s %-24s %6d rows  [%s]\n' "$TBL" "$COL" "$COUNT" "$DELRULE"
  if [[ "$COUNT" -gt 0 ]]; then
    TOTAL_ROWS=$((TOTAL_ROWS + COUNT))
    TABLES_TOUCHED=$((TABLES_TOUCHED + 1))
    DELETE_STMTS+=("DELETE FROM ${TBL} WHERE ${WHERE};")
  fi
done <<< "$FKS"

echo
log "Plan: delete ${TOTAL_ROWS} dependent rows across ${TABLES_TOUCHED} tables, then delete user."
log "Also: transitive rows (content -> auctions/comments/content_tags/interaction_*/seller_ratings/sponsored_campaigns/reports, threads via thread_participants, bot_profiles -> bot_activity_logs) will be swept by retry-loop."

if [[ "$CONFIRM" -ne 1 ]]; then
  echo
  log "DRY RUN — no changes made. Re-run with --confirm to execute."
  exit 0
fi

# ---- Mutation phase --------------------------------------------------------
echo
log "=== --confirm passed: executing deletion in a single transaction ==="

# Build a SQL script that:
#   1. Cleans transitive-from-content rows (deep-nested first).
#   2. Loops the enumerated FK DELETEs up to 3 passes.
#   3. Deletes the user row.
#   4. If any pass leaves violating rows, RAISE -> transaction rolls back.

TMPSQL=$(mktemp)
trap 'rm -f "$TMPSQL"' EXIT

{
  echo "\\set ON_ERROR_STOP on"
  echo "BEGIN;"
  echo "-- Target: ${USER_ID} (${USER_EMAIL:-<no email>}, role=${USER_ROLE})"

  # Stage 1: sweep rows that reference this user's content / threads / bot profiles.
  # These tables don't FK directly to users, but their parents do. Deleting them
  # up-front lets the per-user FK sweep succeed without FK violations.
  cat <<'SWEEP'
-- Transitive sweep: content produced by the user
DO $sweep$
DECLARE
  v_user uuid := :'uid'::uuid;
BEGIN
  -- Rows under content authored by the user
  DELETE FROM auctions           WHERE product_id IN (SELECT id FROM content WHERE creator_id = v_user);
  DELETE FROM content_tags       WHERE content_id IN (SELECT id FROM content WHERE creator_id = v_user);
  DELETE FROM interaction_events WHERE content_id IN (SELECT id FROM content WHERE creator_id = v_user);
  DELETE FROM interaction_states WHERE content_id IN (SELECT id FROM content WHERE creator_id = v_user);
  DELETE FROM sponsored_campaigns WHERE content_id IN (SELECT id FROM content WHERE creator_id = v_user);
  DELETE FROM seller_ratings     WHERE product_id IN (SELECT id FROM content WHERE creator_id = v_user);
  DELETE FROM comments           WHERE content_id IN (SELECT id FROM content WHERE creator_id = v_user);
  UPDATE reports SET reported_content_id = NULL WHERE reported_content_id IN (SELECT id FROM content WHERE creator_id = v_user);

  -- Comments authored by the user (parent_comment_id is SET NULL, safe)
  UPDATE reports SET reported_comment_id = NULL WHERE reported_comment_id IN (SELECT id FROM comments WHERE author_id = v_user);

  -- Bot activity logs for bot profiles owned by the user
  DELETE FROM bot_activity_logs WHERE bot_profile_id IN (SELECT id FROM bot_profiles WHERE user_id = v_user);

  -- Messages in threads where the user is the only participant? Not safely knowable;
  -- messages authored by the user are deleted directly below. Other participants' messages stay.
END
$sweep$;
SWEEP

  # Stage 2: run the FK-enumerated DELETEs in up to 3 passes until quiescent.
  echo
  echo "-- Stage 2: per-FK deletes, looped up to 3 passes"
  cat <<'LOOP'
DO $loop$
DECLARE
  v_user uuid := :'uid'::uuid;
  v_username text;
  v_pass int := 0;
  v_rows_this_pass int;
  v_deleted_total int := 0;
  r record;
  v_col_ref text;
  v_sql text;
  v_count int;
BEGIN
  SELECT username INTO v_username FROM users WHERE id = v_user;

  FOR v_pass IN 1..3 LOOP
    v_rows_this_pass := 0;
    FOR r IN
      SELECT tc.table_name AS tbl,
             kcu.column_name AS col,
             ccu.column_name AS parent_col,
             rc.delete_rule AS drule
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
      JOIN information_schema.referential_constraints rc
        ON tc.constraint_name = rc.constraint_name AND tc.table_schema = rc.constraint_schema
      JOIN information_schema.constraint_column_usage ccu
        ON rc.unique_constraint_name = ccu.constraint_name AND rc.unique_constraint_schema = ccu.constraint_schema
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND ccu.table_name = 'users'
        AND ccu.column_name IN ('id','username')
        AND rc.delete_rule NOT IN ('CASCADE','SET NULL')
    LOOP
      IF r.parent_col = 'id' THEN
        v_col_ref := format('%I = %L::uuid', r.col, v_user);
      ELSE
        IF v_username IS NULL THEN CONTINUE; END IF;
        v_col_ref := format('%I = %L', r.col, v_username);
      END IF;

      v_sql := format('DELETE FROM %I WHERE %s', r.tbl, v_col_ref);
      EXECUTE v_sql;
      GET DIAGNOSTICS v_count = ROW_COUNT;
      IF v_count > 0 THEN
        RAISE NOTICE 'pass % delete %: % rows (%)', v_pass, r.tbl, v_count, r.drule;
        v_rows_this_pass := v_rows_this_pass + v_count;
        v_deleted_total := v_deleted_total + v_count;
      END IF;
    END LOOP;
    RAISE NOTICE 'pass % complete: % rows', v_pass, v_rows_this_pass;
    EXIT WHEN v_rows_this_pass = 0;
  END LOOP;

  -- Now delete the user. credentials and other CASCADE FKs will auto-delete.
  DELETE FROM users WHERE id = v_user;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count = 0 THEN
    RAISE EXCEPTION 'user row not deleted (already gone?)';
  END IF;

  RAISE NOTICE 'TOTAL dependent rows deleted: %; user row deleted.', v_deleted_total;
END
$loop$;
LOOP

  echo
  echo "COMMIT;"
} > "$TMPSQL"

log "Executing transaction..."
if "${PSQL[@]}" -v "uid=${USER_ID}" -f "$TMPSQL"; then
  log "SUCCESS: user ${USER_ID} and all dependent rows removed."
else
  rc=$?
  log "FAILURE: transaction rolled back (exit $rc). Check output above for the offending constraint."
  exit "$rc"
fi

echo
log "Summary: user=${USER_ID} email='${USER_EMAIL}' role='${USER_ROLE}' — DELETED"
