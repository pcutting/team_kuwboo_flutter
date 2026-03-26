import 'package:flutter/material.dart';

// V6: Minimal Swiss Metadata

const String designName = 'Minimal Swiss';
const String shortName = 'Swiss';
const String target = '30-45, design-conscious, minimalists';
const String philosophy =
    'Information clarity. Let content breathe. '
    'Inspired by the Swiss International Style, this design strips away all decoration '
    'to focus on pure typography, grid systems, and negative space.';

// Palette
const Color primaryColor = Color(0xFFE53935); // Swiss red
const Color secondaryColor = Color(0xFF1976D2); // Blue accent
const Color backgroundColor = Color(0xFFFFFFFF);
const Color surfaceColor = Color(0xFFFAFAFA);
const Color textColor = Color(0xFF000000);

// Typography
const String headlineFont = 'Helvetica Neue';
const String bodyFont = 'Helvetica Neue';

// Key Elements
const List<String> keyElements = [
  'Strict 8px grid system',
  'Helvetica Neue typography only',
  'No shadows, minimal borders',
  'Photography dominates',
  'Text as navigation',
  'Swiss red as the single accent',
  'Extreme whitespace',
];

// Scores (Phase B Review - Honest Assessment)
const int distinctiveness = 3; // Clean but generic - this is "startup SaaS template" energy
const int coherence = 5; // Perfectly consistent, every element follows the system
const int usability = 5; // Extremely clear information hierarchy, the Yoyo list view is highly scannable
const int targetFit = 3; // Design minimalists are a tiny niche - most daters want personality
const int longevity = 5; // Swiss style has been timeless since the 1950s

// Critique
const String works =
    'The Yoyo screen as a list rather than map is a smart alternative - shows RADIUS, NEW, ACTIVE stats at a glance. '
    'Information density is high without feeling cluttered. The red "NEW" badges draw the eye correctly. '
    'Elisabeth from Zurich feels authentic to the Swiss aesthetic. Date stamp "FEB 2026" adds a magazine quality.';
const String weakness =
    'This design is so minimal it has no personality. It looks like a prototype for a banking app, not a dating app. '
    'The extreme whitespace that works in portfolios may feel empty and cold in a dating context. '
    'Helvetica Neue is so ubiquitous it communicates nothing - it is the design equivalent of khakis. '
    'The 30-45 minimalist demographic is extremely small and probably already married.';
