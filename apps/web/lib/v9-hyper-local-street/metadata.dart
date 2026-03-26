import 'package:flutter/material.dart';

// V9: Hyper-Local Street Metadata

const String designName = 'Hyper-Local Street';
const String shortName = 'Street';
const String target = '22-32, city dwellers, culture enthusiasts';
const String philosophy =
    'Dating meets neighborhood culture. Urban, authentic, local. '
    'This design emphasizes location and community, using street poster aesthetics '
    'to create a sense of authentic urban culture and neighborhood pride.';

// Palette
const Color primaryColor = Color(0xFFE63946); // Marker red
const Color secondaryColor = Color(0xFF457B9D); // Spray blue
const Color backgroundColor = Color(0xFFF5F1EB); // Poster paper
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF1D1D1D);

// Typography
const String headlineFont = 'Bebas Neue';
const String bodyFont = 'Inter';

// Key Elements
const List<String> keyElements = [
  'Street poster/wheat-paste aesthetic',
  'Condensed gothic typography (Bebas Neue)',
  'Location prominently featured',
  'Raw, documentary photography style',
  'Community-first messaging',
  'Bold borders and stark contrasts',
  'Neighborhood as identity marker',
];

// Scores (Phase B Review - Honest Assessment)
const int distinctiveness = 5; // Nothing else looks like this - wheat-paste poster aesthetic is fresh
const int coherence = 4; // Bebas Neue and bold tags work, but the grid Yoyo map feels disconnected
const int usability = 4; // Bold typography is scannable, red distance badges are clever
const int targetFit = 4; // Urban culture enthusiasts in London/NYC will love it, but excludes suburbs
const int longevity = 3; // Street art aesthetic could feel try-hard as it becomes more mainstream

// Critique
const String works =
    'The SHOREDITCH E2 header immediately grounds the experience in place - brilliant for Yoyo feature. '
    'Bebas Neue condensed type screams urban poster culture. '
    '"Local guide. Street art lover. Best coffee spots in E2." bio is perfect neighborhood identity. '
    'The red VERIFIED badge pops against the monochrome scheme. '
    'Coffee and Street Art interest tags feel authentic, not generic.';
const String weakness =
    'The location-first approach will alienate users in suburbs or smaller cities. "SHOREDITCH" as identity only works in trendy urban areas. '
    'Privacy-conscious users may be uncomfortable with such prominent location display. '
    'The street poster aesthetic could feel performative or appropriative to those actually in street culture. '
    'The grid-based Yoyo map is harder to read spatially than bubble-based alternatives.';
