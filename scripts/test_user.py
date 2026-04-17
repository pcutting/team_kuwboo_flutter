#!/usr/bin/env python3
"""Manage the Kuwboo App Store reviewer test account.

A single CLI that creates / inspects / resets the dedicated demo user the
App Store reviewer logs into, plus 10 seed Marketplace products the
reviewer can browse. The user also exists with a DOB, is fully onboarded,
and has an email — so reviewers can exercise the phone-OTP path, the
email-OTP path, or the dev-only phone login that returns real JWTs.

The database is not exposed to the public internet (security group
allows EC2 only). All SQL therefore runs on the EC2 API host via
AWS SSM `send-command`, which uses the box's IAM role to fetch the RDS
master password from Secrets Manager and execute psql against RDS.

Quick start:
    pip3 install -r scripts/requirements.txt
    AWS_PROFILE=neil-douglas-kuwboo python3 scripts/test_user.py create

Reviewer flow (--help also surfaces this):
    The reviewer logs in with phone +12025550100 via OTP, or email
    cuttingphilip+test@gmail.com via email OTP. In dev builds the OTP
    code is shown in an in-app banner (no SMS/email delivery needed).
    The user is fully onboarded (DOB set, onboarding_progress='complete')
    with 10 sample products listed.

Commands:
    create [--force]  Create user + products. --force deletes any
                      pre-existing record first (idempotent reset).
    delete            Hard-delete the user and all their content.
    reset             delete + create (convenience shortcut).
    info              Print whether the user exists and how many
                      products they own.
    login-token       Call /auth/dev-login with the user's phone and
                      print a working access token for manual testing.

Schema compatibility:
    The script introspects the live schema before writing. Columns
    added in the 2026-04-17 migration (email_verified, email_verified_at,
    credibility_score, dob_choice, content.thumbnail_url) are set when
    present and silently skipped when the migration has not yet run on
    the target database. This keeps the script usable across the
    backend-agent's schema rollout.
"""

from __future__ import annotations

import argparse
import base64
import json
import sys
import time
import urllib.error
import urllib.request
import uuid
from dataclasses import dataclass
from typing import Optional

try:
    import boto3
    import bcrypt
except ImportError as exc:  # pragma: no cover
    sys.stderr.write(
        f"Missing dependency: {exc.name}. Run:\n"
        "    pip3 install -r scripts/requirements.txt\n"
    )
    sys.exit(2)


# ---------------------------------------------------------------------------
# Fixed configuration
# ---------------------------------------------------------------------------

AWS_PROFILE_DEFAULT = "neil-douglas-kuwboo"
AWS_REGION = "eu-west-2"


# Per-environment targeting. Today there is only one deployed environment
# (greenfield), which serves both dev iteration and the TestFlight builds
# the client is testing — so `dev` and `prod` both point here. When a
# genuine production stack exists, populate the `prod` block and remove
# the duplicate IDs; the `--env prod --yes-i-mean-production` double-opt-in
# + the NODE_ENV pre-flight will already gate destructive runs at that
# point without further code changes.
ENVIRONMENTS: dict[str, dict[str, str]] = {
    "dev": {
        "ec2_instance_id": "i-0766e373b3147a2aa",
        "rds_host": "kuwboo-greenfield-db.cepsv4bfmn1r.eu-west-2.rds.amazonaws.com",
        "api_base_url": "http://35.177.230.139",
        "expected_node_env": "development",
    },
    "prod": {
        "ec2_instance_id": "i-0766e373b3147a2aa",
        "rds_host": "kuwboo-greenfield-db.cepsv4bfmn1r.eu-west-2.rds.amazonaws.com",
        "api_base_url": "http://35.177.230.139",
        "expected_node_env": "production",
    },
}
RDS_USER = "kuwboo_admin"
RDS_DB = "kuwboo"

# Commands that delete data. These require `--yes` confirmation, and when
# `--env prod` they additionally require `--yes-i-mean-production`.
DESTRUCTIVE_COMMANDS = frozenset({"delete", "reset", "create"})  # create w/ --force deletes first

# Reserved fictional-use US number (NANPA 555-01xx block). Passes
# libphonenumber validation used by the backend's class-validator
# `@IsPhoneNumber()` decorator, whereas `+15555550100` (all 555s) does
# not. The 202 area code is used here only because NANPA requires a
# valid NPA for the reserved 555-01xx range to parse.
TEST_PHONE = "+12025550100"
TEST_EMAIL = "cuttingphilip+test@gmail.com"
TEST_NAME = "Phil Test"
TEST_USERNAME = "philtest"
TEST_PASSWORD = "123456789"
TEST_DOB = "1980-06-01"


@dataclass(frozen=True)
class SeedProduct:
    title: str
    description: str
    price_cents: int
    condition: str          # NEW | LIKE_NEW | GOOD | FAIR | FOR_PARTS
    is_deal: bool
    original_price_cents: Optional[int]
    thumbnail_url: str


# Condition values in the schema (`content_condition_check`) are:
#   NEW, LIKE_NEW, GOOD, FAIR, FOR_PARTS
# The task brief uses older names (USED_GOOD etc.); those are mapped here
# to the current enum so the seed inserts pass the check constraint.
SEED_PRODUCTS: list[SeedProduct] = [
    SeedProduct(
        "Vintage Leather Jacket",
        "Genuine leather, 1980s, size M. Small patina near cuff, fully lined.",
        4500, "GOOD", False, None,
        "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800",
    ),
    SeedProduct(
        "iPhone 13 Pro 256GB",
        "Unlocked, battery 94%, minor bezel scuff, original box + charger.",
        55000, "LIKE_NEW", False, None,
        "https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=800",
    ),
    SeedProduct(
        "Dyson V8 Animal",
        "All attachments, new filter, 30 min runtime, recent service.",
        18000, "GOOD", False, None,
        "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800",
    ),
    SeedProduct(
        "IKEA KALLAX 4x4 Shelf",
        "White, fully assembled, no damage. Collection only, N1 London.",
        5500, "GOOD", False, None,
        "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800",
    ),
    SeedProduct(
        "Peloton Bike+",
        "2022 model, low miles, tablet + subscription transferable.",
        120000, "LIKE_NEW", True, 150000,
        "https://images.unsplash.com/photo-1591291621060-89264bf3e7b8?w=800",
    ),
    SeedProduct(
        "MacBook Air M2 13\"",
        "16GB / 512GB, space grey, AppleCare+ until 2026.",
        85000, "LIKE_NEW", False, None,
        "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800",
    ),
    SeedProduct(
        "Nintendo Switch OLED",
        "White, 2 Joy-Cons, dock, original box. Animal Crossing included.",
        22500, "LIKE_NEW", False, None,
        "https://images.unsplash.com/photo-1617096200347-cb04ae810b1d?w=800",
    ),
    SeedProduct(
        "Sony WH-1000XM5",
        "Sealed, bought in error. UK plug. Black.",
        26000, "NEW", True, 32000,
        "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=800",
    ),
    SeedProduct(
        "Le Creuset Dutch Oven 26cm",
        "Cerise, signature round, hand-wash only, gift unused.",
        18000, "NEW", True, 23000,
        "https://images.unsplash.com/photo-1584727638096-042c45049ebe?w=800",
    ),
    SeedProduct(
        "Vintage Vinyl Collection",
        "50 albums: rock, jazz, blues. Sleeves VG+, discs VG to NM.",
        15000, "GOOD", False, None,
        "https://images.unsplash.com/photo-1461360228754-6e81c478b882?w=800",
    ),
]


# ---------------------------------------------------------------------------
# SSM / psql transport
# ---------------------------------------------------------------------------


class RemoteSQL:
    """Executes SQL on the EC2 host by dispatching psql via SSM."""

    def __init__(self, profile: str, region: str, env: dict[str, str]):
        session = boto3.Session(profile_name=profile, region_name=region)
        self.ssm = session.client("ssm")
        self.env = env

    def _send(self, shell: str, *, poll_seconds: int = 120) -> str:
        """Run a shell snippet on the remote host and return stdout.

        Raises RuntimeError on non-zero exit or error output.
        """
        resp = self.ssm.send_command(
            InstanceIds=[self.env["ec2_instance_id"]],
            DocumentName="AWS-RunShellScript",
            Parameters={"commands": [shell]},
            TimeoutSeconds=120,
        )
        command_id = resp["Command"]["CommandId"]
        deadline = time.time() + poll_seconds
        while True:
            try:
                inv = self.ssm.get_command_invocation(
                    CommandId=command_id, InstanceId=self.env["ec2_instance_id"],
                )
            except self.ssm.exceptions.InvocationDoesNotExist:
                if time.time() > deadline:
                    raise
                time.sleep(1)
                continue
            if inv["Status"] not in ("Pending", "InProgress", "Delayed"):
                break
            if time.time() > deadline:
                raise RuntimeError(
                    f"SSM command {command_id} timed out after {poll_seconds}s",
                )
            time.sleep(1)
        if inv["Status"] != "Success":
            raise RuntimeError(
                f"SSM command failed ({inv['Status']}): "
                f"stderr={inv.get('StandardErrorContent','').strip()} "
                f"stdout={inv.get('StandardOutputContent','').strip()}",
            )
        return inv.get("StandardOutputContent", "")

    def probe_node_env(self) -> str:
        """Ask PM2 what NODE_ENV the API is running with.

        Returns a lowercase string ('development', 'production', '') —
        empty when it can't be determined. Best-effort: if parsing
        fails for any reason the guard is skipped (see main()). Earlier
        versions grepped `^NODE_ENV:` out of `pm2 env 0`, but that output
        mixes the user-facing table header (`node_env:development`) with
        the actual value, which produced the bogus `node_env:development`
        string. Now we scan every line of `pm2 env` output, split on the
        first `:` or `=`, and accept only a plain 'development' or
        'production' value. Anything else → return empty.
        """
        out = self._send(
            'sudo -u ubuntu bash -c "pm2 env 0 2>&1"',
            poll_seconds=20,
        )
        for raw in out.splitlines():
            line = raw.strip()
            if not line:
                continue
            # PM2 emits both `NODE_ENV: development` (status dump) and
            # `node_env:development` (env listing). Take the rightmost
            # token after either `:` or `=` and accept only the two
            # known values.
            parts = line.replace("=", ":").split(":")
            if len(parts) < 2:
                continue
            key = parts[0].strip().lower()
            if key != "node_env":
                continue
            value = parts[-1].strip().lower()
            if value in ("development", "production"):
                return value
        return ""

    def run_sql(self, sql: str, *, tuples_only: bool = False) -> str:
        """Run a block of SQL and return psql's stdout."""
        b64 = base64.b64encode(sql.encode("utf-8")).decode("ascii")
        flags = "-v ON_ERROR_STOP=1"
        if tuples_only:
            flags += " -A -t"
        shell = (
            'SECRET=$(aws secretsmanager list-secrets --region eu-west-2 '
            "--query 'SecretList[?starts_with(Name, `rds!`)].Name' "
            "--output text | head -1); "
            'PW=$(aws secretsmanager get-secret-value '
            '--secret-id "$SECRET" --region eu-west-2 '
            "--query SecretString --output text "
            "| python3 -c 'import sys,json; print(json.load(sys.stdin)[\"password\"])'); "
            'export PGPASSWORD="$PW"; '
            f'echo {b64} | base64 -d > /tmp/_ts.sql && '
            f'psql -h {self.env["rds_host"]} -U {RDS_USER} -d {RDS_DB} {flags} -f /tmp/_ts.sql'
        )
        return self._send(shell)


# ---------------------------------------------------------------------------
# Schema probe
# ---------------------------------------------------------------------------


@dataclass
class SchemaCaps:
    users_email_verified: bool
    users_credibility_score: bool
    users_dob_choice: bool
    content_thumbnail_url: bool

    def summary(self) -> str:
        flags = [
            f"email_verified={self.users_email_verified}",
            f"credibility_score={self.users_credibility_score}",
            f"dob_choice={self.users_dob_choice}",
            f"content.thumbnail_url={self.content_thumbnail_url}",
        ]
        return ", ".join(flags)


def probe_schema(sql: RemoteSQL) -> SchemaCaps:
    query = """
select
  exists(select 1 from information_schema.columns
         where table_name='users' and column_name='email_verified')       as u_ev,
  exists(select 1 from information_schema.columns
         where table_name='users' and column_name='credibility_score')    as u_cs,
  exists(select 1 from information_schema.columns
         where table_name='users' and column_name='dob_choice')           as u_dc,
  exists(select 1 from information_schema.columns
         where table_name='content' and column_name='thumbnail_url')      as c_tu;
"""
    out = sql.run_sql(query, tuples_only=True).strip()
    # psql -A -t returns pipe-delimited bools: "t|f|f|t"
    parts = out.splitlines()[-1].split("|")
    flags = [p.strip() == "t" for p in parts]
    if len(flags) != 4:
        raise RuntimeError(f"Unexpected schema probe output: {out!r}")
    return SchemaCaps(*flags)


# ---------------------------------------------------------------------------
# SQL builders
# ---------------------------------------------------------------------------


def sql_literal(value) -> str:
    """Quote a Python value as a safe-enough SQL literal for seed data."""
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, int):
        return str(value)
    # string: standard SQL single-quote with doubling
    return "'" + str(value).replace("'", "''") + "'"


def build_info_sql() -> str:
    # Match on either the reviewer email or the reviewer phone — the
    # dev-login endpoint bootstraps a user with the phone only (no email)
    # on first call, and we want `info` to report that collision before
    # `create` hits a unique constraint.
    return f"""
SELECT
  (SELECT id::text FROM users
     WHERE (email = {sql_literal(TEST_EMAIL)} OR phone = {sql_literal(TEST_PHONE)})
     AND deleted_at IS NULL
     ORDER BY (email = {sql_literal(TEST_EMAIL)}) DESC
     LIMIT 1) AS user_id,
  (SELECT count(*) FROM content c
     JOIN users u ON u.id = c.creator_id
     WHERE (u.email = {sql_literal(TEST_EMAIL)} OR u.phone = {sql_literal(TEST_PHONE)})
     AND c.type='PRODUCT' AND c.deleted_at IS NULL) AS product_count;
"""


def build_create_sql(user_id: str, caps: SchemaCaps, password_hash: str) -> str:
    extra_user_cols: list[str] = []
    extra_user_vals: list[str] = []
    if caps.users_email_verified:
        extra_user_cols += ['"email_verified"', '"email_verified_at"']
        extra_user_vals += ["FALSE", "NULL"]
    if caps.users_credibility_score:
        extra_user_cols.append('"credibility_score"')
        extra_user_vals.append("50")
    if caps.users_dob_choice:
        extra_user_cols.append('"dob_choice"')
        extra_user_vals.append(sql_literal("provided"))

    user_cols = [
        '"id"', '"phone"', '"email"', '"name"', '"username"',
        '"password_hash"', '"date_of_birth"', '"birthday_skipped"',
        '"onboarding_progress"', '"age_verification_status"',
    ] + extra_user_cols
    user_vals = [
        sql_literal(user_id),
        sql_literal(TEST_PHONE),
        sql_literal(TEST_EMAIL),
        sql_literal(TEST_NAME),
        sql_literal(TEST_USERNAME),
        sql_literal(password_hash),
        sql_literal(TEST_DOB),
        "FALSE",
        sql_literal("complete"),
        sql_literal("self_declared"),
    ] + extra_user_vals

    insert_user = (
        f"INSERT INTO users ({', '.join(user_cols)}) "
        f"VALUES ({', '.join(user_vals)});\n"
    )

    # Credentials are the backend's source-of-truth for "this phone/email
    # is registered." `auth.service.ts#verifyPhoneOtp` looks up
    # `credentials` (not `users`) before deciding whether to create a new
    # account. A bare user row without matching credentials makes the OTP
    # verify path try to insert a second user with the same phone, hits
    # the unique constraint, and 500s — the reviewer sees "Internal server
    # error" at the exact moment the flow is supposed to complete.
    #
    # Seed a verified phone credential AND a verified email credential so
    # both OTP flows work. Note that `users.email_verified = false` stays
    # independent: the credential existing just means the linkage is
    # established, not that the user has confirmed ownership via the
    # email-verify endpoint.
    phone_cred_id = str(uuid.uuid4())
    email_cred_id = str(uuid.uuid4())
    insert_credentials = (
        f'INSERT INTO credentials ("id", "user_id", "type", "identifier", '
        f'"verified_at", "is_primary") VALUES '
        f'({sql_literal(phone_cred_id)}, {sql_literal(user_id)}, '
        f'{sql_literal("phone")}, {sql_literal(TEST_PHONE)}, now(), TRUE);\n'
        f'INSERT INTO credentials ("id", "user_id", "type", "identifier", '
        f'"verified_at", "is_primary") VALUES '
        f'({sql_literal(email_cred_id)}, {sql_literal(user_id)}, '
        f'{sql_literal("email")}, {sql_literal(TEST_EMAIL)}, now(), TRUE);\n'
    )

    product_rows: list[str] = []
    for p in SEED_PRODUCTS:
        pid = str(uuid.uuid4())
        cols = [
            '"id"', '"type"', '"creator_id"', '"visibility"', '"tier"',
            '"status"', '"title"', '"description"', '"price_cents"',
            '"currency"', '"condition"', '"is_deal"', '"original_price_cents"',
        ]
        vals = [
            sql_literal(pid),
            sql_literal("PRODUCT"),
            sql_literal(user_id),
            sql_literal("PUBLIC"),
            sql_literal("FREE"),
            sql_literal("ACTIVE"),
            sql_literal(p.title),
            sql_literal(p.description),
            sql_literal(p.price_cents),
            sql_literal("GBP"),
            sql_literal(p.condition),
            sql_literal(p.is_deal),
            sql_literal(p.original_price_cents),
        ]
        if caps.content_thumbnail_url:
            cols.append('"thumbnail_url"')
            vals.append(sql_literal(p.thumbnail_url))
        product_rows.append(
            f"INSERT INTO content ({', '.join(cols)}) "
            f"VALUES ({', '.join(vals)});"
        )

    return (
        "BEGIN;\n"
        + insert_user
        + insert_credentials
        + "\n".join(product_rows)
        + "\nCOMMIT;\n"
    )


def build_delete_sql() -> str:
    """Hard delete: remove the user's content, dependent rows, then the user.

    Every delete runs in its own PL/pgSQL block with an `undefined_table`
    handler so that tables introduced by in-flight migrations in other
    branches (or not yet deployed) do not abort the whole command. The
    sequence is: per-content child rows → content → per-user child rows →
    users. Matches on email OR phone so a stray dev-login bootstrap user
    (phone set, email null) is also reaped.
    """
    email = sql_literal(TEST_EMAIL)
    phone = sql_literal(TEST_PHONE)

    # Tables keyed by content_id. Order matters only where FKs point
    # between them (bids → auctions, so do bids before auctions).
    content_child_deletes = [
        ("comments", "content_id"),
        ("content_tags", "content_id"),
        ("content_interest_tags", "content_id"),
        ("interaction_events", "content_id"),
        ("interaction_states", "content_id"),
        ("seller_ratings", "product_id"),
        # bids reference auctions, so bids first via auctions subquery.
        ("bids_via_auctions", None),
        ("auctions", "product_id"),
        ("sponsored_campaigns", "content_id"),
    ]

    # Tables keyed by user_id (in addition to their content).
    user_child_deletes = [
        ("bids", "bidder_id"),
        ("comments", "author_id"),
        ("interaction_events", "user_id"),
        ("interaction_states", "user_id"),
        ("credentials", "user_id"),
        ("sessions", "user_id"),
        ("devices", "user_id"),
        ("user_preferences", "user_id"),
        ("bot_profiles", "user_id"),
        ("apple_notification_events", "user_id"),
        ("trust_signals", "user_id"),
        ("user_interests", "user_id"),
        ("verification_challenges", "user_id"),
    ]

    # Reports cannot hard-delete against because they reference us with
    # ON DELETE SET NULL; nulling explicitly keeps auditing intact.
    # Connections / blocks are between two users — handled separately.

    def safe_delete_content(table: str, col: str) -> str:
        return f"""
  BEGIN
    EXECUTE 'DELETE FROM {table} WHERE {col} = ANY($1)' USING content_ids;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;"""

    def safe_delete_user(table: str, col: str) -> str:
        return f"""
  BEGIN
    EXECUTE 'DELETE FROM {table} WHERE {col} = $1' USING target_id;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;"""

    content_child_blocks: list[str] = []
    for table, col in content_child_deletes:
        if table == "bids_via_auctions":
            content_child_blocks.append("""
  BEGIN
    EXECUTE 'DELETE FROM bids WHERE auction_id IN
      (SELECT id FROM auctions WHERE product_id = ANY($1))' USING content_ids;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;""")
        else:
            content_child_blocks.append(safe_delete_content(table, col))

    user_child_blocks = [safe_delete_user(t, c) for t, c in user_child_deletes]

    return f"""
BEGIN;

DO $$
DECLARE
  target_id uuid;
  content_ids uuid[];
BEGIN
  SELECT id INTO target_id FROM users
    WHERE email = {email} OR phone = {phone}
    LIMIT 1;

  IF target_id IS NULL THEN
    RETURN;
  END IF;

  SELECT array_agg(id) INTO content_ids FROM content WHERE creator_id = target_id;
  IF content_ids IS NULL THEN
    content_ids := ARRAY[]::uuid[];
  END IF;

  -- Clear rows keyed by content_id.
  {''.join(content_child_blocks)}

  -- Null out audit references; do not hard-delete reports.
  BEGIN
    EXECUTE 'UPDATE reports SET reported_content_id = NULL
             WHERE reported_content_id = ANY($1)' USING content_ids;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;

  -- Delete the content rows themselves.
  DELETE FROM content WHERE id = ANY(content_ids);

  -- Clear rows keyed by user_id.
  {''.join(user_child_blocks)}

  -- Two-sided user references.
  BEGIN
    EXECUTE 'DELETE FROM connections
              WHERE from_user_id = $1 OR to_user_id = $1' USING target_id;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;
  BEGIN
    EXECUTE 'DELETE FROM blocks
              WHERE blocker_id = $1 OR blocked_id = $1' USING target_id;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;
  BEGIN
    EXECUTE 'UPDATE reports SET reporter_id = NULL
              WHERE reporter_id = $1' USING target_id;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;
  BEGIN
    EXECUTE 'DELETE FROM admin_audit_logs WHERE admin_user_id = $1'
      USING target_id;
  EXCEPTION WHEN undefined_table THEN NULL;
  END;

  -- Finally the user.
  DELETE FROM users WHERE id = target_id;
END$$;

COMMIT;
"""


# ---------------------------------------------------------------------------
# Command implementations
# ---------------------------------------------------------------------------


def bcrypt_hash(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt(rounds=10)).decode(
        "utf-8",
    )


def parse_info(out: str) -> tuple[Optional[str], int]:
    """Parse a two-column psql result from build_info_sql."""
    # Output is: header, separator, data row, (n rows), blank
    # Use tuples-only mode via a sentinel or parse defensively.
    lines = [ln.strip() for ln in out.strip().splitlines() if ln.strip()]
    for ln in lines:
        if "|" not in ln:
            continue
        # Skip the header line ('user_id | product_count')
        if ln.lower().startswith("user_id"):
            continue
        # Skip the dash separator
        if set(ln.replace("|", "").replace(" ", "")) <= {"-", "+"}:
            continue
        parts = [p.strip() for p in ln.split("|")]
        if len(parts) != 2:
            continue
        uid = parts[0] or None
        try:
            count = int(parts[1]) if parts[1] else 0
        except ValueError:
            continue
        return uid, count
    return None, 0


def cmd_info(sql: RemoteSQL) -> int:
    out = sql.run_sql(build_info_sql())
    uid, count = parse_info(out)
    caps = probe_schema(sql)
    print(f"Schema caps:       {caps.summary()}")
    if uid is None:
        print("User:              does not exist")
        print(f"Email:             {TEST_EMAIL}")
        print(f"Phone:             {TEST_PHONE}")
        return 0
    print(f"User:              exists (id={uid})")
    print(f"Email:             {TEST_EMAIL}")
    print(f"Phone:             {TEST_PHONE}")
    print(f"Products:          {count}")
    return 0


def cmd_delete(sql: RemoteSQL, verbose: bool = True) -> int:
    if verbose:
        print("Deleting test user and their content…")
    sql.run_sql(build_delete_sql())
    if verbose:
        out = sql.run_sql(build_info_sql())
        uid, _ = parse_info(out)
        if uid is None:
            print("Deleted.")
        else:
            print(f"Warning: user still present (id={uid}); manual cleanup required.")
            return 1
    return 0


def cmd_create(sql: RemoteSQL, force: bool) -> int:
    # Pre-flight.
    out = sql.run_sql(build_info_sql())
    uid, count = parse_info(out)
    if uid is not None:
        if not force:
            print(f"Error: user already exists (id={uid}, {count} products).")
            print("Use --force to delete and recreate, or 'reset' to do both.")
            return 1
        print(f"User exists (id={uid}); --force supplied, deleting first.")
        rc = cmd_delete(sql, verbose=False)
        if rc != 0:
            return rc

    caps = probe_schema(sql)
    print(f"Schema caps:       {caps.summary()}")

    new_uid = str(uuid.uuid4())
    pw_hash = bcrypt_hash(TEST_PASSWORD)
    print(f"Creating user…      id={new_uid}")
    sql.run_sql(build_create_sql(new_uid, caps, pw_hash))
    print(f"Seeded {len(SEED_PRODUCTS)} products.")
    # Confirm.
    out = sql.run_sql(build_info_sql())
    uid, count = parse_info(out)
    print(f"Result:            id={uid}, products={count}")
    return 0


def cmd_reset(sql: RemoteSQL) -> int:
    rc = cmd_delete(sql)
    if rc != 0:
        return rc
    return cmd_create(sql, force=False)


def cmd_login_token(env: dict[str, str]) -> int:
    api_base = env["api_base_url"]
    body = json.dumps({"phone": TEST_PHONE}).encode("utf-8")
    req = urllib.request.Request(
        url=f"{api_base}/auth/dev-login",
        data=body,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            payload = json.load(resp)
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        if e.code == 403:
            print(
                "Error: /auth/dev-login returned 403. "
                "DEV_LOGIN_ENABLED=1 must be set on the API process.",
                file=sys.stderr,
            )
        else:
            print(f"Error: HTTP {e.code} from /auth/dev-login: {detail}",
                  file=sys.stderr)
        return 1
    except urllib.error.URLError as e:
        print(f"Error: could not reach {api_base}: {e}", file=sys.stderr)
        return 1

    data = payload.get("data", payload)
    access = data.get("accessToken")
    refresh = data.get("refreshToken")
    if not access:
        print(f"Error: no accessToken in response: {payload}", file=sys.stderr)
        return 1
    print(f"accessToken:  {access}")
    print(f"refreshToken: {refresh}")
    print()
    print("Verify with:")
    print(f"  curl {api_base}/me -H 'Authorization: Bearer {access}'")
    return 0


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


HELP_EPILOG = f"""\
App Store reviewer flow:
  This user has DOB set, is onboarded, and has 10 products. Reviewer uses
  phone {TEST_PHONE} via OTP or email {TEST_EMAIL} via email OTP — the
  dev-mode banner shows the OTP code in-app.

  For a working JWT right now, run:
    python3 scripts/test_user.py login-token

Environment:
  AWS_PROFILE defaults to 'neil-douglas-kuwboo'. Override with
    AWS_PROFILE=... python3 scripts/test_user.py <command>
"""


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="test_user.py",
        description="Manage the Kuwboo App Store reviewer demo account.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=HELP_EPILOG,
    )
    parser.add_argument(
        "--aws-profile",
        default=AWS_PROFILE_DEFAULT,
        help=f"AWS profile (default: {AWS_PROFILE_DEFAULT})",
    )
    parser.add_argument(
        "--env",
        choices=sorted(ENVIRONMENTS.keys()),
        default="dev",
        help="Target environment (default: dev). `prod` requires "
             "--yes-i-mean-production for any mutation.",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Skip the interactive confirmation for destructive commands "
             "(delete / reset / create --force).",
    )
    parser.add_argument(
        "--yes-i-mean-production",
        action="store_true",
        help="Required alongside --yes when --env=prod is used with a "
             "destructive command.",
    )
    parser.add_argument(
        "--skip-env-check",
        action="store_true",
        help="Skip the NODE_ENV pre-flight probe (useful when the API is "
             "down but you still need to reset the DB). Not recommended.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_create = sub.add_parser("create", help="Create the test user + 10 products")
    p_create.add_argument(
        "--force",
        action="store_true",
        help="Delete existing user first if present",
    )
    sub.add_parser("delete", help="Hard-delete the test user and their content")
    sub.add_parser("reset", help="Shortcut for: delete then create")
    sub.add_parser("info", help="Print current state of the test user")
    sub.add_parser(
        "login-token",
        help="Call /auth/dev-login and print a working access token",
    )

    args = parser.parse_args(argv)
    env = ENVIRONMENTS[args.env]

    is_destructive = args.command in DESTRUCTIVE_COMMANDS and not (
        args.command == "create" and not getattr(args, "force", False)
    )

    # Opt-in gate for destructive commands. --yes is always required;
    # prod additionally requires --yes-i-mean-production.
    if is_destructive:
        if not args.yes:
            print(
                f"Refusing to run `{args.command}` without --yes. "
                f"This will delete the test user and seeded products on env={args.env}.",
                file=sys.stderr,
            )
            return 2
        if args.env == "prod" and not args.yes_i_mean_production:
            print(
                "Refusing to run a destructive command against --env=prod "
                "without --yes-i-mean-production. Double-opt-in required.",
                file=sys.stderr,
            )
            return 2

    # login-token does not need DB access.
    if args.command == "login-token":
        return cmd_login_token(env)

    sql = RemoteSQL(profile=args.aws_profile, region=AWS_REGION, env=env)

    # NODE_ENV pre-flight. Refuse if what the API actually reports doesn't
    # match what the caller claimed with --env. Only runs for mutating
    # commands (info is read-only, login-token already bypassed).
    if is_destructive and not args.skip_env_check:
        try:
            actual = sql.probe_node_env()
        except RuntimeError as e:
            print(
                f"Warning: NODE_ENV probe failed ({e}). "
                "Re-run with --skip-env-check if you know what you're doing.",
                file=sys.stderr,
            )
            return 2
        expected = env["expected_node_env"]
        if actual and actual != expected:
            print(
                f"Refusing to mutate: --env={args.env} expects "
                f"NODE_ENV={expected}, but the target API reports "
                f"NODE_ENV={actual}. Pick the right --env or use "
                "--skip-env-check to override.",
                file=sys.stderr,
            )
            return 2

    if args.command == "info":
        return cmd_info(sql)
    if args.command == "delete":
        return cmd_delete(sql)
    if args.command == "create":
        return cmd_create(sql, force=args.force)
    if args.command == "reset":
        return cmd_reset(sql)

    parser.error(f"Unknown command: {args.command}")
    return 2


if __name__ == "__main__":
    sys.exit(main())
