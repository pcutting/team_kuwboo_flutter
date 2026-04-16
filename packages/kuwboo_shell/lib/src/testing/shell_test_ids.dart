/// Stable identifiers for shared shell widgets used across every screen.
/// Used by Semantics(identifier:) — maps to iOS UIAccessibilityIdentifier
/// and Android resource-id for Maestro / Patrol.
abstract class ShellIds {
  // proto_top_bar
  static const topbarChatIcon = 'shell.topbar.icon_chat';
  static const topbarProfileMenu = 'shell.topbar.btn_profile_menu';
  static const topbarYoyoToggle = 'shell.topbar.icon_yoyo_toggle';

  // proto_bottom_nav
  static const bottomnavFab = 'shell.bottomnav.fab_service_menu';
  static String bottomnavTab(String label) =>
      'shell.bottomnav.tab_${label.toLowerCase()}';
  static String bottomnavService(String module) =>
      'shell.bottomnav.service_$module';

  // proto_scaffold
  static const subbarBack = 'shell.subbar.btn_back';

  // proto_dialogs — profile menu
  static const profileMenuViewProfile = 'shell.profile_menu.item_view_profile';
  static const profileMenuSettings = 'shell.profile_menu.item_settings';
  static const profileMenuDarkMode = 'shell.profile_menu.toggle_dark_mode';
  static const profileMenuLogOut = 'shell.profile_menu.item_log_out';

  // proto_dialogs — confirm
  static const dialogConfirmCancel = 'shell.dialog_confirm.btn_cancel';
  static const dialogConfirmConfirm = 'shell.dialog_confirm.btn_confirm';

  // proto_dialogs — share sheet
  static String shareOption(String label) =>
      'shell.share_sheet.option_${label.toLowerCase()}';
}
