import 'package:flutter/material.dart';

// V0: Urban Warmth Metadata

const String designName = 'Urban Warmth';
const String shortName = 'Urban';
const String target = '25-35, confident urban professionals who value authenticity';
const String philosophy =
    'Full-bleed impact meets organic approachability. '
    'This design puts the photo front and center as the hero element, '
    'combining the bold condensed typography of street culture with the warm '
    'earth tones and organic shapes of natural design. The result is confident '
    'yet inviting — a dating profile that feels both impactful and genuine.';

// Palette — V5 warmth with V9 accent punch
const Color primaryColor = Color(0xFFCB6843); // Terracotta
const Color secondaryColor = Color(0xFF7B9E6B); // Sage green
const Color backgroundColor = Color(0xFFF8F4F0); // Warm cream
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF2D2A26); // Warm dark brown

// Typography — V9 display + V5 body
const String headlineFont = 'Bebas Neue';
const String bodyFont = 'Lato';

// Key Elements
const List<String> keyElements = [
  'Full-bleed hero photo — image is the entire card',
  'Warm terracotta gradient overlay (not cold black)',
  'Bold condensed display type (Bebas Neue) from street design',
  'Organic rounded badges and pills from warmth design',
  'Location-forward with warm earth tones',
  'Minimal chrome — let the person shine through',
  'Sage green verified badge ties organic + trust',
];

// Scores
const int distinctiveness = 5; // Full-bleed with warm tones is unique in dating apps
const int coherence = 5; // V5 warmth + V9 boldness blend seamlessly
const int usability = 5; // Simple, photo-first, essential info overlaid cleanly
const int targetFit = 5; // Perfect for confident professionals who lead with their photo
const int longevity = 4; // Full-bleed is timeless, warm palette grounds the trend

// Critique
const String works =
    'The full-bleed photo makes an immediate emotional connection — you see the person, '
    'not a UI. The warm terracotta gradient overlay feels inviting rather than moody. '
    'Bebas Neue display type adds confidence and urban edge without feeling aggressive. '
    'Sage green verified badge and organic pills soften the boldness beautifully. '
    'This is the "less is more" approach done right.';
const String weakness =
    'Full-bleed designs depend heavily on photo quality — a poorly lit selfie will '
    'look worse here than in a card-based layout with padding and decoration. '
    'The warm overlay tints all photos with terracotta, which may not suit every skin tone. '
    'Less visual structure means less room for detailed profile information.';
