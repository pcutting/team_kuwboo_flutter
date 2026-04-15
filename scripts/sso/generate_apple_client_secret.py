#!/usr/bin/env python3
"""Generate the Apple Sign In client secret JWT used by the backend to
verify Apple identity tokens, and upsert all related values into AWS
Secrets Manager.

Requires Apple Services ID to be registered in the Apple Developer Portal
first (see docs/team/internal/SSO_SETUP.md step 2).

Usage:
    python3 scripts/sso/generate_apple_client_secret.py \\
      --team-id 5GQA38WHMY \\
      --services-id com.kuwboo.signin.service \\
      --key-id 3B764CRX7S \\
      --key-file ~/Projects/clients/active/neil_douglas/AuthKey_3B764CRX7S.p8 \\
      --aws-profile neil-douglas \\
      --region eu-west-2

Idempotent — re-running rotates the JWT without changing the other secrets.
Apple accepts client secrets with max lifetime of 6 months (15552000s).
"""

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

try:
    import jwt  # pyjwt
except ImportError:
    sys.exit("install deps first: pip install pyjwt cryptography")


def mint_client_secret(team_id: str, services_id: str, key_id: str, key_p8: str, days: int = 180) -> tuple[str, int]:
    """Mint an Apple SSO client secret JWT. Returns (jwt, exp_unix_seconds)."""
    now = int(time.time())
    exp = now + days * 86400
    payload = {
        "iss": team_id,          # Apple Team ID
        "iat": now,
        "exp": exp,
        "aud": "https://appleid.apple.com",
        "sub": services_id,      # Services ID, not bundle ID
    }
    token = jwt.encode(
        payload,
        key_p8,
        algorithm="ES256",
        headers={"kid": key_id, "alg": "ES256"},
    )
    return token, exp


def put_secret(name: str, value: str, profile: str, region: str, dry_run: bool) -> None:
    if dry_run:
        print(f"[dry-run] Would upsert Secrets Manager secret {name} ({len(value)} chars)")
        return
    env = os.environ.copy()
    env["AWS_PROFILE"] = profile
    env["AWS_REGION"] = region
    # Try create; if it exists, put-secret-value
    create = subprocess.run(
        ["aws", "secretsmanager", "create-secret", "--name", name, "--secret-string", value],
        env=env,
        capture_output=True,
        text=True,
    )
    if create.returncode == 0:
        print(f"✓ Created secret {name}")
        return
    if "ResourceExistsException" in create.stderr:
        upd = subprocess.run(
            ["aws", "secretsmanager", "put-secret-value", "--secret-id", name, "--secret-string", value],
            env=env, capture_output=True, text=True,
        )
        if upd.returncode != 0:
            sys.exit(f"Failed to update secret {name}: {upd.stderr}")
        print(f"✓ Updated secret {name}")
        return
    sys.exit(f"Failed to create secret {name}: {create.stderr}")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--team-id", required=True, help="Apple Developer Team ID, e.g. 5GQA38WHMY")
    p.add_argument("--services-id", required=True, help="Apple Services ID registered for Sign in with Apple")
    p.add_argument("--key-id", required=True, help="Apple auth key ID (from AuthKey_XXX.p8 filename)")
    p.add_argument("--key-file", required=True, help="Path to .p8 private key")
    p.add_argument("--aws-profile", default="neil-douglas")
    p.add_argument("--region", default="eu-west-2")
    p.add_argument("--days", type=int, default=180, help="JWT validity period (max 180)")
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    key_path = Path(args.key_file).expanduser()
    if not key_path.exists():
        sys.exit(f"Key file not found: {key_path}")
    key_p8 = key_path.read_text()

    token, exp = mint_client_secret(
        args.team_id, args.services_id, args.key_id, key_p8, args.days
    )
    print(f"✓ Minted Apple client secret JWT, exp={time.strftime('%Y-%m-%d', time.gmtime(exp))}")

    prefix = "/kuwboo/apple"
    put_secret(f"{prefix}/team-id", args.team_id, args.aws_profile, args.region, args.dry_run)
    put_secret(f"{prefix}/services-id", args.services_id, args.aws_profile, args.region, args.dry_run)
    put_secret(f"{prefix}/key-id", args.key_id, args.aws_profile, args.region, args.dry_run)
    put_secret(f"{prefix}/private-key", key_p8, args.aws_profile, args.region, args.dry_run)
    put_secret(f"{prefix}/client-secret-jwt", token, args.aws_profile, args.region, args.dry_run)

    print(f"\n✅ Done. Rotate in {args.days} days; see expiry above.")
    print(f"Backend reads these via /kuwboo/apple/* in AWS Secrets Manager.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
