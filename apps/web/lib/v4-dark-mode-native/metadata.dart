import 'package:flutter/material.dart';

// V4: Dark Mode Native Metadata

const String designName = 'Dark Mode Native';
const String shortName = 'Dark';
const String target = '22-35, tech-savvy, night owls, gamers';
const String philosophy =
    'Night owl dating. Designed for dark, not adapted. '
    'This design embraces true black for OLED screens, glowing accents that feel alive, '
    'and a tech-forward aesthetic that appeals to digital natives.';

// Palette
const Color primaryColor = Color(0xFF8B5CF6); // Purple
const Color secondaryColor = Color(0xFF06B6D4); // Cyan
const Color backgroundColor = Color(0xFF000000); // True black
const Color surfaceColor = Color(0xFF0A0A0F);
const Color textColor = Color(0xFFFFFFFF);

// Typography
const String headlineFont = 'Inter';
const String bodyFont = 'Inter';

// Key Elements
const List<String> keyElements = [
  'True black (#000000) for OLED efficiency',
  'Purple and cyan accents that glow',
  'Subtle rim lighting on cards',
  'Monospace font for tech feel',
  'High contrast text for readability',
  'Particle/grid effects in backgrounds',
  'Colored shadows create depth',
];

// Scores (Phase B Review - Honest Assessment)
const int distinctiveness = 4; // True black with glowing accents is memorable, though Discord/Twitch vibes
const int coherence = 5; // Purple and cyan work beautifully together, everything feels unified
const int usability = 4; // High contrast text is readable, but the grid-line map is confusing
const int targetFit = 4; // Gamers and night owls will love it, but excludes everyone else
const int longevity = 4; // Dark mode is not a trend, it is a preference - this will age fine

// Critique
const String works =
    'This is genuinely designed for dark, not adapted from light mode. The rim lighting on cards creates depth without being garish. '
    'The "ONLINE" status badge in cyan is immediately visible. Gaming/Anime/Code interest tags make sense for the audience. '
    'The Yoyo map with glowing user circles against true black looks premium.';
const String weakness =
    'The aesthetic is so strongly "gamer" that mainstream users will feel excluded. The purple/cyan palette is essentially Discord colors. '
    'Bio text "Software engineer by day, gamer by night. Looking for someone to raid..." is extremely niche. '
    'This design says "we only want tech bros" which may not be the best message for a dating app with broader ambitions.';
