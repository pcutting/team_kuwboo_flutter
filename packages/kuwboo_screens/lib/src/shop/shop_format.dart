/// Formats a price expressed in minor currency units (pence / cents) to a
/// user-visible string.
///
/// Mirrors the helper in `apps/mobile/lib/features/feed/presentation/feed_common.dart`
/// so the shop screens in this package don't pull a host-app dependency.
String formatPriceCents(int? cents, String currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  final symbol = switch (currency) {
    'GBP' => '\u00a3',
    'USD' => '\$',
    'EUR' => '\u20ac',
    _ => '$currency ',
  };
  return '$symbol$amount';
}
