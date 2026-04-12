import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// -----------------------------------------------------------------------------
// Release signing configuration.
//
// We resolve signing material in this order:
//   1. Env vars set by CI (ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD,
//      ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD).
//   2. A local key.properties file at apps/mobile/android/key.properties
//      (gitignored). Convenient for local release builds.
//   3. If neither is present, fall back to the debug signing config so that
//      `flutter run --release` keeps working on a dev machine without
//      distribution material.
//
// See docs/team/internal/ANDROID_PLAY_RUNBOOK.md for setup.
// -----------------------------------------------------------------------------
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

fun resolveSigningValue(envName: String, propName: String): String? {
    val fromEnv = System.getenv(envName)
    if (!fromEnv.isNullOrBlank()) return fromEnv
    val fromProps = keystoreProperties.getProperty(propName)
    if (!fromProps.isNullOrBlank()) return fromProps
    return null
}

val releaseKeystorePath = resolveSigningValue("ANDROID_KEYSTORE_PATH", "storeFile")
val releaseKeystorePassword = resolveSigningValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = resolveSigningValue("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = resolveSigningValue("ANDROID_KEY_PASSWORD", "keyPassword")

val hasReleaseSigning = listOf(
    releaseKeystorePath,
    releaseKeystorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() } && file(releaseKeystorePath!!).exists()

android {
    namespace = "com.kuwboo.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Matches iOS bundle ID convention (com.kuwboo.mobile).
        applicationId = "com.kuwboo.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseKeystorePath!!)
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Fall back to debug signing so that local `flutter run --release`
                // still works on a machine without distribution material.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
