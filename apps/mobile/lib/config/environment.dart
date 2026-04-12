/// Build-time environment configuration for Kuwboo mobile.
///
/// Values are injected via `--dart-define` at build time. Example:
///
/// ```bash
/// flutter run --dart-define=KUWBOO_ENV=dev
/// flutter build ipa --dart-define=KUWBOO_ENV=prod
/// ```
///
/// CI workflows pass these in the fastlane `beta` lane.
class Environment {
  const Environment._();

  /// The current environment name: `dev`, `staging`, or `prod`.
  ///
  /// Defaults to `dev` for local `flutter run` without flags.
  static const String current = String.fromEnvironment(
    'KUWBOO_ENV',
    defaultValue: 'dev',
  );

  /// API base URL. Can be overridden via
  /// `--dart-define=KUWBOO_API_BASE_URL=...` (preferred) or the legacy
  /// `KUWBOO_API_URL` name. Otherwise defaults based on [current].
  ///
  /// The dev default points to the EC2 greenfield instance over plain HTTP
  /// until TLS is provisioned.
  static String get apiBaseUrl {
    const override = String.fromEnvironment('KUWBOO_API_BASE_URL');
    if (override.isNotEmpty) return override;
    const legacy = String.fromEnvironment('KUWBOO_API_URL');
    if (legacy.isNotEmpty) return legacy;

    switch (current) {
      case 'prod':
        return 'https://api.kuwboo.com';
      case 'staging':
      case 'dev':
      default:
        return 'http://35.177.230.139';
    }
  }

  /// When true, the client accepts a fixed bypass OTP (`000000`) and skips
  /// the `send-otp` call. Used only while the SMS provider on the backend
  /// is unconfigured. Enable with `--dart-define=KUWBOO_DEV_AUTH=1`.
  static const String _devAuthFlag = String.fromEnvironment(
    'KUWBOO_DEV_AUTH',
    defaultValue: '',
  );
  static bool get devAuthBypass =>
      _devAuthFlag == '1' || _devAuthFlag.toLowerCase() == 'true';

  /// The bypass OTP accepted when [devAuthBypass] is enabled.
  static const String devBypassOtp = '000000';

  /// Whether this build should show debug UI, extra logging, etc.
  static bool get isProduction => current == 'prod';

  /// Whether this build is a local development build.
  static bool get isDev => current == 'dev';
}
