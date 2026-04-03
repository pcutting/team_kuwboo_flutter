# Mobile Codebase Assessment

**Assessment Date:** January 25, 2026
**Source:** Codiant archive dated December 2, 2025

---

## Summary

| Platform | Status | Lines of Code | Git History |
|----------|--------|---------------|-------------|
| **iOS** | Complete | 124,183 | Yes (75+ commits) |
| **Android** | Appears Complete | 28,413 | No |

---

## iOS Application

### Overview

| Property | Value |
|----------|-------|
| **Language** | Swift |
| **Min iOS Version** | 14.0 |
| **Bundle ID** | com.codiant.kuwboo |
| **Architecture** | MVVM with RxSwift |
| **Source Files** | 718 Swift files |
| **Lines of Code** | 124,183 |

### Key Dependencies (from Podfile)

| Category | Libraries |
|----------|-----------|
| **Reactive** | RxSwift, RxCocoa, RxGesture |
| **Auth** | FBSDKLoginKit, GoogleSignIn |
| **Firebase** | Analytics, Crashlytics, Messaging, DynamicLinks |
| **Maps** | GoogleMaps, GooglePlaces |
| **Media** | MetalPetal, GSPlayer, SoundWave, Lottie |
| **UI** | Kingfisher, Cosmos, MarqueeLabel, CHIPageControl |
| **Networking** | Socket.IO-Client-Swift |
| **Utilities** | KeychainAccess, JWTDecode, libPhoneNumber-iOS |

### Source Structure

```
Kuwboo/
├── Application/          # App lifecycle
├── Authorization/        # Auth flows
├── Configuration/        # Environment config
├── Models/              # Data models (43 items)
├── Views/               # UI components (30 items)
├── Storyboards/         # UI layouts (20 items)
├── SocketClient/        # Real-time messaging
├── Resources/           # Assets
└── Misc/                # Helpers and utilities
```

### Git History Available

The iOS project includes full git history showing:
- Blog module development
- Bug fixes and mantis issues
- UI updates and text changes
- Feature branches for different modules

---

## Android Application

### Overview

| Property | Value |
|----------|-------|
| **Language** | Kotlin (primary) + Java (legacy) |
| **Min SDK** | 24 (Android 7.0) |
| **Target SDK** | 35 (Android 14) |
| **Package** | com.kuwboo |
| **Architecture** | MVVM with DataBinding |
| **Source Files** | 950 Kotlin + 180 Java |
| **Lines of Code** | 28,413 |

### Build Configuration

| Property | Value |
|----------|-------|
| **Version** | 1.0.1-alpha01 |
| **Signing** | Keystore included (kuwboo_live.jks) |
| **ProGuard** | Configured but minify disabled |

### Key Features (from package structure)

- Video making / editing
- Social stumble (discovery feature)
- Buy and sell marketplace
- Messaging / chat
- User profiles
- Feed system

### No Git History

Android archive did not include .git directory - no development history available.

---

## Configuration & Keys Found

### Firebase Project

| Property | Value |
|----------|-------|
| **Project ID** | kuwboo-296008 |
| **Project Number** | 552807654083 |
| **Database URL** | https://kuwboo-296008.firebaseio.com |
| **Storage Bucket** | kuwboo-296008.appspot.com |

### API Endpoints (from Android build.gradle)

| Endpoint | URL |
|----------|-----|
| **Base API** | https://kuwboo-api.codiantdev.com/api/ |
| **Socket** | https://kuwboo-api.codiantdev.com/ |
| **Feed Service** | http://15.206.254.12:8000/v1/ |
| **Deep Links** | https://kuwboo.codiantdev.com |

**Note:** The Feed URL (15.206.254.12) points to AWS ap-south-1 (Mumbai) region - different from the main EC2 in eu-west-2 (London). This may indicate a separate microservice.

### App Store IDs

| Platform | ID |
|----------|-----|
| **iOS App Store** | 1524262871 |
| **iOS Bundle** | com.codiant.kuwboo / com.kuwboo |
| **Android Package** | com.kuwboo |

### Google APIs

| Key Type | Present |
|----------|---------|
| Firebase API Key (iOS) | Yes |
| Firebase API Key (Android) | Yes |
| Google Places Key | Referenced (in plist) |
| Google Maps | Configured |

### Social Auth

| Provider | Configured |
|----------|------------|
| Facebook | Yes (SDK included) |
| Google | Yes (Sign-In SDK) |
| Instagram | Yes (OAuth) |
| Twitter | Referenced in backend |

---

## Code Size Discrepancy

### The 4.4x Difference

iOS has 4.4x more code than Android (124K vs 28K lines). Possible explanations:

1. **iOS has more features** - Git history shows Blog module work not obviously present in Android
2. **Different coding styles** - iOS may have more verbose patterns
3. **Android incomplete** - Some features may not be implemented
4. **Shared code missing** - Android may use more libraries for common functionality

### Recommendation

Before development work, verify feature parity between platforms by testing both apps.

---

## Security Notes

### Included Sensitive Files

| File | Risk | Notes |
|------|------|-------|
| google-services.json | Low | Client-side Firebase config |
| GoogleService-Info.plist | Low | Client-side Firebase config |
| kuwboo_live.jks | Medium | Android signing keystore |
| local.properties | Low | Local SDK paths |

### Not Found (Good)

- No .env files with secrets
- No hardcoded API keys in source (uses build config)
- No database credentials

### Signing Keystore

The Android keystore (kuwboo_live.jks) is included. The password is configured via gradle.properties which references environment variables - actual passwords not in archive.

---

## Repository Status

| Repo | Location | Status |
|------|----------|--------|
| **iOS** | mobile/ios/kuwboo | Git history preserved, Codiant remote removed |
| **Android** | mobile/android/kuwboo | New repo initialized from archive |

Both repos are ready for remote setup (GitHub/GitLab).

---

## Next Steps

1. **Verify feature parity** - Test both apps to understand what's implemented
2. **Set up remote repos** - Create GitHub repos for both platforms
3. **Regenerate Pods** - Run `pod install` in iOS project
4. **Test builds** - Verify both projects compile and run
5. **Investigate Feed service** - The 15.206.254.12 endpoint needs research

---

*Assessment by LionPro Dev - January 25, 2026*
