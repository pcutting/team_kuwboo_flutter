# System Changes Log

This document tracks all modifications made to the Kuwboo infrastructure, codebase, and configuration beyond the initial discovery phase.

---

## 2026-01-27: SSL Certificate Renewal

### Problem
The iOS app displayed SSL certificate error when connecting to `kuwboo-api.codiantdev.com`:
> "The certificate for the service is invalid. You might be connecting to a server that is pretending to be 'kuwboo-api.codiantdev.com' which could put your confidential information at risk."

### Root Cause
The Sectigo wildcard SSL certificate (`*.codiantdev.com`) expired on **January 13, 2026**.

| Property | Value |
|----------|-------|
| Old Certificate Issuer | Sectigo RSA Domain Validation |
| Old Certificate Expiry | Jan 13, 2026 23:59:59 GMT |
| Certificate Location | `/etc/nginx/share/ssl/certificate.crt` |

### Solution
Installed Let's Encrypt (Certbot) and obtained a new certificate.

**Commands executed on EC2 instance (`i-00ba3186d66389f31`):**

```bash
# Install certbot with nginx plugin
sudo apt-get update --allow-releaseinfo-change
sudo apt-get install -y certbot python3-certbot-nginx

# Obtain and deploy certificate
sudo certbot --nginx -d kuwboo-api.codiantdev.com \
  --non-interactive --agree-tos --email admin@kuwboo.com --redirect
```

### Result

| Property | Old (Expired) | New (Active) |
|----------|---------------|--------------|
| Issuer | Sectigo (paid) | Let's Encrypt (free) |
| Valid Until | Jan 13, 2026 | Apr 27, 2026 |
| Auto-Renewal | No | Yes (cron job) |
| Coverage | `*.codiantdev.com` | `kuwboo-api.codiantdev.com` |

**New certificate location:** `/etc/letsencrypt/live/kuwboo-api.codiantdev.com/`

**Auto-renewal:** Certbot installed a systemd timer that automatically renews the certificate before expiration.

### Verification
```bash
# Verify certificate is valid
echo | openssl s_client -connect kuwboo-api.codiantdev.com:443 \
  -servername kuwboo-api.codiantdev.com 2>/dev/null | \
  openssl x509 -noout -dates -issuer -subject

# Expected output:
# notBefore=Jan 27 09:18:30 2026 GMT
# notAfter=Apr 27 09:18:29 2026 GMT
# issuer=C=US, O=Let's Encrypt, CN=R13
# subject=CN=kuwboo-api.codiantdev.com
```

---

## 2026-01-27: Server Infrastructure Improvements

### Packages Installed

The following packages were installed on EC2 instance `i-00ba3186d66389f31` to improve server management and reliability:

#### 1. Certbot (Let's Encrypt)
- **Package:** `certbot`, `python3-certbot-nginx`
- **Purpose:** Automated SSL certificate management
- **Auto-renewal:** Systemd timer runs twice daily to check/renew certificates

#### 2. Cron Service
- **Package:** `cron`
- **Purpose:** Scheduled task execution
- **Status:** Enabled and running

#### 3. AWS Systems Manager (SSM) Agent
- **Package:** `amazon-ssm-agent`
- **Purpose:** Enables AWS Session Manager access (no SSH/security group changes needed)
- **Benefit:** Can access server via AWS Console without managing SSH keys or IP whitelisting

### SSM Session Manager Access

With SSM installed, you can now connect to the server without SSH:

```bash
# Connect via AWS CLI
aws ssm start-session \
  --target i-00ba3186d66389f31 \
  --profile neil-douglas

# Or use AWS Console:
# EC2 → Instances → Select instance → Connect → Session Manager
```

**Advantages over EC2 Instance Connect:**
- No 60-second key expiration window
- No need to update security groups for IP changes
- Session logging available in CloudWatch
- IAM-based access control

---

## 2026-01-27: iOS Live Scheme API URL Fix

### Problem
The iOS app's "Live" build scheme was configured to connect to a non-existent server (`kuwboo-api-dev.codiantdev.com`) instead of the working production server (`kuwboo-api.codiantdev.com`).

### Root Cause
In `Kuwboo/Configuration/Live.xcconfig`, the correct API URL was commented out and the incorrect `-dev` URL was active.

### File Modified
`mobile/ios/kuwboo/Kuwboo/Configuration/Live.xcconfig`

### Changes Made

**Before:**
```xcconfig
// Server URL
//API_URL = https:/$()/kuwboo-api.codiantdev.com/api
API_URL = https:/$()/kuwboo-api-dev.codiantdev.com/api
```

**After:**
```xcconfig
// Server URL
API_URL = https:/$()/kuwboo-api.codiantdev.com/api
//API_URL = https:/$()/kuwboo-api-dev.codiantdev.com/api
```

### Note
The `SOCKET_URL` was already correctly pointing to `kuwboo-api.codiantdev.com` - only the `API_URL` needed correction.

### Next Steps
1. Clean build folder in Xcode (`Cmd+Shift+K`)
2. Archive with Live scheme
3. Upload new build to TestFlight
4. Test login with phone number + OTP `4444`

---

## Testing Credentials

For development/testing (server has `NODE_ENV=development`):

| Field | Value |
|-------|-------|
| Test Phone | 7566662735 |
| OTP | 4444 (works for ANY phone number) |

---

## Change Log Summary

| Date | Component | Change Type | Description |
|------|-----------|-------------|-------------|
| 2026-01-27 | Server | Infrastructure | Renewed SSL certificate via Let's Encrypt |
| 2026-01-27 | Server | Infrastructure | Installed certbot for auto-renewal |
| 2026-01-27 | Server | Infrastructure | Installed/enabled cron service |
| 2026-01-27 | Server | Infrastructure | Installed AWS SSM Agent for Session Manager access |
| 2026-01-27 | iOS App | Configuration | Fixed API URL in Live.xcconfig |

---

## Pending Items

- [ ] Deploy new iOS build to TestFlight with corrected API URL
- [ ] Verify login works end-to-end on TestFlight build
- [ ] Consider rotating credentials (previous developer has access)
- [ ] Review if `kuwboo-api-dev.codiantdev.com` should be provisioned or removed from configs entirely
