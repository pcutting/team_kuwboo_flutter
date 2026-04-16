/// Kuwboo shared shell infrastructure.
///
/// Provides theme, navigation, state management, and shared UI atoms
/// for both mobile and web apps.
library kuwboo_shell;

// Theme
export 'src/theme/proto_theme.dart';
export 'src/theme/color_palettes.dart';
export 'src/theme/icon_sets.dart';
export 'src/theme/brand_colors.dart';

// Shared widgets
export 'src/shared/proto_scaffold.dart';
export 'src/shared/proto_bottom_nav.dart';
export 'src/shared/proto_top_bar.dart';
export 'src/shared/proto_dialogs.dart';
export 'src/shared/proto_press_button.dart';
export 'src/shared/proto_image.dart';
export 'src/shared/proto_states.dart';
export 'src/shared/feature_flags.dart';

// State
export 'src/state/proto_state_provider.dart';
export 'src/state/proto_module.dart';

// Routes
export 'src/routes/proto_routes.dart';
export 'src/routes/proto_transitions.dart';

// Data
export 'src/data/demo_data.dart';
export 'src/data/proto_demo_data.dart';
