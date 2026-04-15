#!/usr/bin/env python3
"""Enable "Sign In with Apple" capability on the Kuwboo App ID, then
regenerate the provisioning profile so it includes the new entitlement,
then update the two GitHub Secrets that the iOS TestFlight workflow
consumes.

This is the scripted equivalent of the Apple Developer Portal workflow:
1. PATCH /v1/bundleIds/{id} — add AppleSignIn capability
2. DELETE old profile, POST new profile referencing current cert
3. Update APPLE_PROVISIONING_PROFILE_BASE64 + APPLE_PROVISIONING_PROFILE_UUID
   GitHub Secrets so the next CI run picks up the new profile.

The ASC API JWT is generated the same way as in the existing cert-rotation
runbook — see docs/team/internal/TESTFLIGHT_RUNBOOK.md.

Prerequisites:
- ASC API key file present at ~/Projects/clients/active/neil_douglas/AuthKey_<KEY_ID>.p8
- `gh` CLI authenticated for pcutting/team_kuwboo
- Python 3.10+ with `pyjwt` and `cryptography` installed

Run:
    python3 scripts/sso/enable_apple_signin.py --dry-run    # plan only
    python3 scripts/sso/enable_apple_signin.py              # execute

Environment variables (or flags):
    APPLE_ISSUER_ID, APPLE_KEY_ID, APPLE_KEY_P8, APPLE_TEAM_ID,
    APPLE_BUNDLE_ID (default com.kuwboo.mobile),
    APPLE_CERT_ID (current Apple Distribution cert, needed for profile gen),
    GITHUB_REPO (default pcutting/team_kuwboo)
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import time
from pathlib import Path

try:
    import jwt  # pyjwt
    import requests
except ImportError:
    print("ERROR: install deps first: pip install pyjwt cryptography requests", file=sys.stderr)
    sys.exit(2)


ASC_BASE = "https://api.appstoreconnect.apple.com/v1"


def mint_jwt(issuer_id: str, key_id: str, key_p8: str) -> str:
    """Mint an ASC API JWT — ES256, 20-minute lifetime."""
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(
        payload,
        key_p8,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )


def api(method: str, path: str, token: str, **kw) -> requests.Response:
    r = requests.request(
        method,
        f"{ASC_BASE}/{path.lstrip('/')}",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        timeout=30,
        **kw,
    )
    if r.status_code >= 400:
        print(f"ASC API error {method} {path}: {r.status_code} {r.text}", file=sys.stderr)
    return r


def find_bundle_id(token: str, bundle_id: str) -> dict:
    r = api("GET", f"bundleIds?filter[identifier]={bundle_id}&limit=1", token)
    r.raise_for_status()
    data = r.json().get("data", [])
    if not data:
        sys.exit(f"Bundle ID {bundle_id} not found on App Store Connect")
    return data[0]


def ensure_capability(token: str, bundle_id_record: dict, capability: str, dry_run: bool) -> None:
    """Add a bundle-ID capability if not already present.

    capability is a capability-type enum like 'SIGN_IN_WITH_APPLE'.
    """
    bid = bundle_id_record["id"]
    r = api("GET", f"bundleIds/{bid}/bundleIdCapabilities", token)
    r.raise_for_status()
    caps = [c["attributes"]["capabilityType"] for c in r.json().get("data", [])]
    if capability in caps:
        print(f"✓ Capability {capability} already enabled on {bundle_id_record['attributes']['identifier']}")
        return
    if dry_run:
        print(f"[dry-run] Would enable capability {capability} on {bundle_id_record['attributes']['identifier']}")
        return
    payload = {
        "data": {
            "type": "bundleIdCapabilities",
            "attributes": {"capabilityType": capability},
            "relationships": {
                "bundleId": {"data": {"type": "bundleIds", "id": bid}}
            },
        }
    }
    r = api("POST", "bundleIdCapabilities", token, json=payload)
    r.raise_for_status()
    print(f"✓ Enabled capability {capability}")


def regenerate_profile(token: str, bundle_id_record: dict, cert_id: str, profile_name: str, dry_run: bool) -> tuple[str, bytes]:
    """Delete any provisioning profile with the given name and create a fresh
    one. Returns (uuid, raw_p12_bytes)."""
    r = api("GET", f"profiles?filter[name]={profile_name}&limit=10", token)
    r.raise_for_status()
    existing = r.json().get("data", [])
    for p in existing:
        if dry_run:
            print(f"[dry-run] Would delete profile {p['attributes']['name']} ({p['id']})")
        else:
            api("DELETE", f"profiles/{p['id']}", token)
            print(f"✓ Deleted old profile {p['attributes']['name']}")
    if dry_run:
        print(f"[dry-run] Would create new profile '{profile_name}' type IOS_APP_STORE")
        return "<dry-run-uuid>", b""
    payload = {
        "data": {
            "type": "profiles",
            "attributes": {
                "name": profile_name,
                "profileType": "IOS_APP_STORE",
            },
            "relationships": {
                "bundleId": {"data": {"type": "bundleIds", "id": bundle_id_record["id"]}},
                "certificates": {"data": [{"type": "certificates", "id": cert_id}]},
            },
        }
    }
    r = api("POST", "profiles", token, json=payload)
    r.raise_for_status()
    body = r.json()["data"]
    attrs = body["attributes"]
    uuid = attrs["uuid"]
    raw_b64 = attrs["profileContent"]
    print(f"✓ Created new profile {attrs['name']} uuid={uuid}")
    return uuid, base64.b64decode(raw_b64)


def set_gh_secret(repo: str, name: str, value: str, dry_run: bool) -> None:
    if dry_run:
        print(f"[dry-run] Would set GitHub Secret {name} on {repo} ({len(value)} chars)")
        return
    # Write to a temp file so `gh secret set` reads from stdin safely
    proc = subprocess.run(
        ["gh", "secret", "set", name, "--repo", repo, "--body", value],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        sys.exit(f"gh secret set failed: {proc.stderr}")
    print(f"✓ Updated GitHub Secret {name}")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--issuer-id", default=os.environ.get("APPLE_ISSUER_ID"))
    p.add_argument("--key-id", default=os.environ.get("APPLE_KEY_ID", "3B764CRX7S"))
    p.add_argument("--key-p8", default=os.environ.get(
        "APPLE_KEY_P8",
        str(Path.home() / "Projects/clients/active/neil_douglas/AuthKey_3B764CRX7S.p8"),
    ))
    p.add_argument("--team-id", default=os.environ.get("APPLE_TEAM_ID", "5GQA38WHMY"))
    p.add_argument("--bundle-id", default=os.environ.get("APPLE_BUNDLE_ID", "com.kuwboo.mobile"))
    p.add_argument("--cert-id", default=os.environ.get("APPLE_CERT_ID"),
                   help="Apple Distribution cert ID (required to regenerate the profile). Run once without this to see available cert IDs.")
    p.add_argument("--profile-name", default="Kuwboo Mobile App Store")
    p.add_argument("--github-repo", default=os.environ.get("GITHUB_REPO", "pcutting/team_kuwboo"))
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    if not args.issuer_id:
        sys.exit("--issuer-id required (or set APPLE_ISSUER_ID)")

    key_p8_path = Path(args.key_p8)
    if not key_p8_path.exists():
        sys.exit(f"Key file not found: {key_p8_path}")
    key_p8 = key_p8_path.read_text()

    token = mint_jwt(args.issuer_id, args.key_id, key_p8)
    print(f"✓ Minted ASC API JWT (team={args.team_id}, key={args.key_id})")

    bundle = find_bundle_id(token, args.bundle_id)
    print(f"✓ Found bundleId {args.bundle_id} id={bundle['id']}")

    ensure_capability(token, bundle, "SIGN_IN_WITH_APPLE", args.dry_run)

    if not args.cert_id:
        r = api("GET", "certificates?filter[certificateType]=IOS_DISTRIBUTION&limit=10", token)
        r.raise_for_status()
        print("\nAvailable iOS Distribution certificates:")
        for c in r.json().get("data", []):
            attrs = c["attributes"]
            print(f"  id={c['id']}  name={attrs['name']}  expiry={attrs['expirationDate']}")
        print("\nRerun with --cert-id <id> to regenerate the provisioning profile.")
        return 0

    uuid, profile_bytes = regenerate_profile(
        token, bundle, args.cert_id, args.profile_name, args.dry_run
    )

    if args.dry_run:
        print("\n[dry-run] Would update GitHub Secrets APPLE_PROVISIONING_PROFILE_UUID and _BASE64")
        return 0

    set_gh_secret(args.github_repo, "APPLE_PROVISIONING_PROFILE_UUID", uuid, args.dry_run)
    set_gh_secret(
        args.github_repo,
        "APPLE_PROVISIONING_PROFILE_BASE64",
        base64.b64encode(profile_bytes).decode("ascii"),
        args.dry_run,
    )

    print(f"\n✅ Done. Trigger a TestFlight build: gh workflow run ios-testflight.yml --ref <branch> -f environment=prod --repo {args.github_repo}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
