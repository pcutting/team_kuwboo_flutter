/// Design metadata for the properties panel Theme tab.
/// Extracted from the old viewer's per-design metadata files.
/// Only the 4 visible designs are included (mapped by original index).
class DesignScores {
  final int distinctiveness;
  final int coherence;
  final int usability;
  final int targetFit;
  final int longevity;

  const DesignScores({
    required this.distinctiveness,
    required this.coherence,
    required this.usability,
    required this.targetFit,
    required this.longevity,
  });

  double get overall =>
      (distinctiveness + coherence + usability + targetFit + longevity) / 5;
}

class DesignMetadataEntry {
  final String name;
  final String target;
  final String philosophy;
  final String headlineFont;
  final String bodyFont;
  final List<String> keyElements;
  final DesignScores scores;
  final String works;
  final String weakness;

  const DesignMetadataEntry({
    required this.name,
    required this.target,
    required this.philosophy,
    required this.headlineFont,
    required this.bodyFont,
    required this.keyElements,
    required this.scores,
    required this.works,
    required this.weakness,
  });

  /// Look up metadata by original design index (0-7).
  static DesignMetadataEntry forDesign(int originalIndex) {
    return _entries[originalIndex] ?? _entries[0]!;
  }

  static const _entries = <int, DesignMetadataEntry>{
    // 0: V0 Urban Warmth
    0: DesignMetadataEntry(
      name: 'Urban Warmth',
      target: '25-35, confident urban professionals who value authenticity',
      philosophy:
          'Full-bleed impact meets organic approachability. '
          'This design puts the photo front and center as the hero element, '
          'combining the bold condensed typography of street culture with the warm '
          'earth tones and organic shapes of natural design. The result is confident '
          'yet inviting — a dating profile that feels both impactful and genuine.',
      headlineFont: 'Bebas Neue',
      bodyFont: 'Lato',
      keyElements: [
        'Full-bleed hero photo — image is the entire card',
        'Warm terracotta gradient overlay (not cold black)',
        'Bold condensed display type (Bebas Neue) from street design',
        'Organic rounded badges and pills from warmth design',
        'Location-forward with warm earth tones',
        'Minimal chrome — let the person shine through',
        'Sage green verified badge ties organic + trust',
      ],
      scores: DesignScores(
        distinctiveness: 5,
        coherence: 5,
        usability: 5,
        targetFit: 5,
        longevity: 4,
      ),
      works:
          'The full-bleed photo makes an immediate emotional connection — you see the person, '
          'not a UI. The warm terracotta gradient overlay feels inviting rather than moody. '
          'Bebas Neue display type adds confidence and urban edge without feeling aggressive. '
          'Sage green verified badge and organic pills soften the boldness beautifully. '
          'This is the "less is more" approach done right.',
      weakness:
          'Full-bleed designs depend heavily on photo quality — a poorly lit selfie will '
          'look worse here than in a card-based layout with padding and decoration. '
          'The warm overlay tints all photos with terracotta, which may not suit every skin tone. '
          'Less visual structure means less room for detailed profile information.',
    ),

    // 3: V4 Dark Mode Native
    3: DesignMetadataEntry(
      name: 'Dark Mode Native',
      target: '22-35, tech-savvy, night owls, gamers',
      philosophy:
          'Night owl dating. Designed for dark, not adapted. '
          'This design embraces true black for OLED screens, glowing accents that feel alive, '
          'and a tech-forward aesthetic that appeals to digital natives.',
      headlineFont: 'Inter',
      bodyFont: 'Inter',
      keyElements: [
        'True black (#000000) for OLED efficiency',
        'Purple and cyan accents that glow',
        'Subtle rim lighting on cards',
        'Monospace font for tech feel',
        'High contrast text for readability',
        'Particle/grid effects in backgrounds',
        'Colored shadows create depth',
      ],
      scores: DesignScores(
        distinctiveness: 4,
        coherence: 5,
        usability: 4,
        targetFit: 4,
        longevity: 4,
      ),
      works:
          'This is genuinely designed for dark, not adapted from light mode. The rim lighting on cards creates depth without being garish. '
          'The "ONLINE" status badge in cyan is immediately visible. Gaming/Anime/Code interest tags make sense for the audience. '
          'The Yoyo map with glowing user circles against true black looks premium.',
      weakness:
          'The aesthetic is so strongly "gamer" that mainstream users will feel excluded. The purple/cyan palette is essentially Discord colors. '
          'Bio text "Software engineer by day, gamer by night. Looking for someone to raid..." is extremely niche. '
          'This design says "we only want tech bros" which may not be the best message for a dating app with broader ambitions.',
    ),

    // 4: V5 Organic Warmth
    4: DesignMetadataEntry(
      name: 'Organic Warmth',
      target: '25-40, relationship-seekers, tired of swipe culture',
      philosophy:
          'Human connection in a digital age. Soft, natural, approachable. '
          'This design uses organic shapes, earth tones, and warm textures to create '
          'a feeling of genuine human connection rather than transactional swiping.',
      headlineFont: 'Playfair Display',
      bodyFont: 'Lato',
      keyElements: [
        'Blob shapes instead of rectangles',
        'Asymmetric border radius creates organic feel',
        'Earth tone palette (terracotta, sage, cream)',
        'Soft gradients mimicking natural light',
        'Pillow-like, soft buttons',
        'Warm photography filters concept',
        'Humanist typography adds approachability',
      ],
      scores: DesignScores(
        distinctiveness: 4,
        coherence: 5,
        usability: 4,
        targetFit: 5,
        longevity: 4,
      ),
      works:
          'The warmest, most human-feeling design of all ten. The blob-shaped map area in the Yoyo screen feels like a cozy gathering rather than a grid. '
          'Bio text "Looking for real conversations over coffee" perfectly matches the aesthetic. '
          'The "Verified" badge in a pill shape with leaf icon ties into the organic theme. '
          'Playfair Display with Lato is an elegant pairing that feels approachable.',
      weakness:
          'The muted palette may disappear in app store screenshots next to bolder competitors. '
          'Blob shapes are difficult to implement consistently and may cause layout issues on different screen sizes. '
          'The "introverted extrovert" bio text is a dating app cliche - the design is better than the sample content.',
    ),

    // 6: V9 Hyper-Local Street
    6: DesignMetadataEntry(
      name: 'Hyper-Local Street',
      target: '22-32, city dwellers, culture enthusiasts',
      philosophy:
          'Dating meets neighborhood culture. Urban, authentic, local. '
          'This design emphasizes location and community, using street poster aesthetics '
          'to create a sense of authentic urban culture and neighborhood pride.',
      headlineFont: 'Bebas Neue',
      bodyFont: 'Inter',
      keyElements: [
        'Street poster/wheat-paste aesthetic',
        'Condensed gothic typography (Bebas Neue)',
        'Location prominently featured',
        'Raw, documentary photography style',
        'Community-first messaging',
        'Bold borders and stark contrasts',
        'Neighborhood as identity marker',
      ],
      scores: DesignScores(
        distinctiveness: 5,
        coherence: 4,
        usability: 4,
        targetFit: 4,
        longevity: 3,
      ),
      works:
          'The SHOREDITCH E2 header immediately grounds the experience in place - brilliant for Yoyo feature. '
          'Bebas Neue condensed type screams urban poster culture. '
          '"Local guide. Street art lover. Best coffee spots in E2." bio is perfect neighborhood identity. '
          'The red VERIFIED badge pops against the monochrome scheme. '
          'Coffee and Street Art interest tags feel authentic, not generic.',
      weakness:
          'The location-first approach will alienate users in suburbs or smaller cities. "SHOREDITCH" as identity only works in trendy urban areas. '
          'Privacy-conscious users may be uncomfortable with such prominent location display. '
          'The street poster aesthetic could feel performative or appropriative to those actually in street culture. '
          'The grid-based Yoyo map is harder to read spatially than bubble-based alternatives.',
    ),
  };
}
