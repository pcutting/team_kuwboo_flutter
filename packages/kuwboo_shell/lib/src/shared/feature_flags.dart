/// Compile-time feature flags for the demo build.
///
/// Flags gate features that are incomplete or not ready for launch. Flip
/// once the backing implementation lands and demo/GA are unblocked.
library feature_flags;

/// When `false`, the Sponsored (advertiser) surface is hidden from
/// navigation. The screens remain compilable but render a "coming soon"
/// banner so any stray deep-link hit is not a dead end.
const bool kSponsoredEnabled = false;
