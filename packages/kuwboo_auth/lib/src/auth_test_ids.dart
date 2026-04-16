/// Stable identifiers for interactive or assert-worthy widgets in the
/// auth flow. Used by Semantics(identifier:) — maps to iOS
/// UIAccessibilityIdentifier and Android resource-id for Maestro / Patrol.
abstract class AuthIds {
  // auth_welcome_screen
  static const welcomeCreateAccount = 'auth.welcome.btn_create_account';
  static const welcomeLogin = 'auth.welcome.btn_login';
  static const welcomeApple = 'auth.welcome.btn_apple';
  static const welcomeGoogle = 'auth.welcome.btn_google';

  // auth_method_screen
  static const methodPhoneEmail = 'auth.method.btn_phone_email';
  static const methodGoogle = 'auth.method.btn_google';
  static const methodApple = 'auth.method.btn_apple';
  static const methodTerms = 'auth.method.link_terms';
  static const methodPrivacy = 'auth.method.link_privacy';

  // auth_phone_screen
  static const phoneTabPhone = 'auth.phone.tab_phone';
  static const phoneTabEmail = 'auth.phone.tab_email';
  static const phoneField = 'auth.phone.field_phone';
  static const phoneSendCode = 'auth.phone.send_code';
  static const emailField = 'auth.email.field_email';
  static const emailNext = 'auth.email.next';
  static const phoneHeaderLabel = 'auth.phone.label_phone';

  // auth_otp_screen
  static const otpBanner = 'auth.otp.banner_dev_code';
  static const otpIdentifier = 'auth.otp.text_identifier';
  static const otpResend = 'auth.otp.btn_resend';
  static String otpDigit(int i) => 'auth.otp.digit_$i';

  // auth_birthday_screen
  static const birthdayWheelDay = 'auth.birthday.wheel_day';
  static const birthdayWheelMonth = 'auth.birthday.wheel_month';
  static const birthdayWheelYear = 'auth.birthday.wheel_year';
  static const birthdayContinue = 'auth.birthday.btn_continue';

  // auth_profile_screen
  static const profileDisplayName = 'auth.profile.field_display_name';
  static const profileUsername = 'auth.profile.field_username';
  static const profileUsernameError = 'auth.profile.text_username_error';
  static const profileAddPhoto = 'auth.profile.btn_add_photo';
  static const profileContinue = 'auth.profile.btn_continue';

  // auth_tutorial_screen
  static const tutorialSkip = 'auth.tutorial.btn_skip';
  static const tutorialNext = 'auth.tutorial.btn_next_or_go';
  static String tutorialDot(int i) => 'auth.tutorial.dot_$i';
}
