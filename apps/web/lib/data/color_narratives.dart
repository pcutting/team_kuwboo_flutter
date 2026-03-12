/// Color science narratives for each design theme and swappable palette.
/// Separated from [ColorPalette] to keep palette definitions lean (pure color
/// containers) while giving the properties panel rich educational content.
class ColorNarrative {
  final String emotionalTone;
  final List<String> emotions;
  final String psychology;
  final String harmonyType;
  final String harmonyExplain;
  final String bestFor;
  final String contrastNote;
  final String colorWorks;
  final String colorWeakness;

  const ColorNarrative({
    required this.emotionalTone,
    required this.emotions,
    required this.psychology,
    required this.harmonyType,
    required this.harmonyExplain,
    required this.bestFor,
    required this.contrastNote,
    required this.colorWorks,
    required this.colorWeakness,
  });

  /// Narrative for a design's default color story (index 0-7).
  static ColorNarrative forDesign(int designIndex) {
    return _designNarratives[designIndex.clamp(0, _designNarratives.length - 1)];
  }

  /// Narrative for a swappable palette (index 0-11).
  static ColorNarrative forPalette(int paletteIndex) {
    return _paletteNarratives[paletteIndex.clamp(0, _paletteNarratives.length - 1)];
  }

  // ─── Design Narratives (8) ──────────────────────────────────────────────

  static const _designNarratives = <ColorNarrative>[
    // 0: V0 Urban Warmth
    ColorNarrative(
      emotionalTone: 'Warm & Grounding',
      emotions: ['Authenticity', 'Confidence', 'Approachability'],
      psychology:
          'Terracotta and earth tones activate warmth associations rooted '
          'in natural materials — clay, leather, sun-baked stone. Research shows '
          'warm hues increase perceived friendliness and reduce social distance. '
          'The sage green secondary adds a trust-anchoring organic quality.',
      harmonyType: 'Analogous + Accent',
      harmonyExplain:
          'Terracotta, amber, and sage sit near each other on the warm side '
          'of the wheel, creating cohesion while sage provides a natural contrast point.',
      bestFor: 'Dating and social profiles where genuine, confident first '
          'impressions matter more than flashy design.',
      contrastNote:
          'Dark brown text on warm cream provides strong readability. '
          'The terracotta accent meets AA contrast on white surfaces.',
      colorWorks:
          'Earth tones feel premium without trying too hard — the palette says '
          '"I have taste" without shouting. Sage green verified badges feel '
          'organic and trustworthy.',
      colorWeakness:
          'The warm overlay tints photos with terracotta which may not '
          'complement every skin tone. Limited cool tones make the palette '
          'feel heavy in large surfaces.',
    ),

    // 1: V2 Soft Luxury
    ColorNarrative(
      emotionalTone: 'Elegant & Refined',
      emotions: ['Sophistication', 'Trust', 'Exclusivity'],
      psychology:
          'Champagne gold and burgundy are historically associated with wealth '
          'and fine craftsmanship. Gold activates reward centers — studies show '
          'it increases perceived value of adjacent elements. The muted burgundy '
          'prevents ostentation, keeping luxury quiet rather than loud.',
      harmonyType: 'Complementary',
      harmonyExplain:
          'Warm gold and cool burgundy sit on opposite sides of the wheel, '
          'creating visual tension that reads as sophisticated contrast.',
      bestFor: 'Premium product showcases, luxury dating experiences, and '
          'editorial content where the audience expects refinement.',
      contrastNote:
          'Near-black text on cream background exceeds AAA contrast. '
          'Gold accents need careful sizing to maintain readability at small scales.',
      colorWorks:
          'The restrained palette signals quality through subtlety — like a '
          'well-designed hotel lobby. Every colour earns its place.',
      colorWeakness:
          'Can feel muted or "beige" to younger demographics expecting '
          'bolder visual energy. Burgundy on gold can look dated if proportions are off.',
    ),

    // 2: V3 Vibrant Pop
    ColorNarrative(
      emotionalTone: 'Bold & Energetic',
      emotions: ['Excitement', 'Fun', 'Playfulness'],
      psychology:
          'Electric blue and hot pink trigger dopamine-associated excitement '
          'responses. High-saturation colours demand attention — the brain '
          'processes them 20% faster than muted tones. The multi-chromatic '
          'approach mirrors Gen Z visual language shaped by social media.',
      harmonyType: 'Triadic',
      harmonyExplain:
          'Blue, pink, and green form an equilateral triangle on the colour '
          'wheel, maximising vibrancy while maintaining mathematical balance.',
      bestFor: 'Youth-oriented social feeds, gamified experiences, and '
          'content discovery where energy and engagement are the priority.',
      contrastNote:
          'White text on saturated blue/pink passes AA. The high saturation '
          'can cause visual fatigue in extended reading — use neutrals for body text.',
      colorWorks:
          'Instantly eye-catching and impossible to scroll past. The palette '
          'practically vibrates with youthful energy and makes UI feel alive.',
      colorWeakness:
          'Risk of visual overwhelm — too many saturated elements competing '
          'for attention. Needs generous neutral space to breathe.',
    ),

    // 3: V4 Dark Mode Native
    ColorNarrative(
      emotionalTone: 'Mysterious & Premium',
      emotions: ['Focus', 'Modernity', 'Immersion'],
      psychology:
          'True black backgrounds with purple accents evoke digital-native '
          'luxury. Purple has the shortest wavelength in visible light, '
          'activating creative and contemplative neural pathways. Dark UIs '
          'reduce eye strain in low-light and create a cinema-like focus on content.',
      harmonyType: 'Analogous',
      harmonyExplain:
          'Purple, cyan, and pink occupy adjacent cool positions, unified '
          'by their luminous quality against the dark background.',
      bestFor: 'Night-time browsing, media-heavy feeds, dating apps where '
          'mood and atmosphere matter more than information density.',
      contrastNote:
          'White text on true black achieves maximum 21:1 contrast ratio. '
          'Purple accents need sufficient brightness to read against dark surfaces.',
      colorWorks:
          'The dark canvas makes every color pop like neon signs. Content feels '
          'curated and cinematic, photos look their absolute best.',
      colorWeakness:
          'True black OLED smearing on scroll. Extended dark-mode use can feel '
          'oppressive — no warm "breathing room" for the eyes.',
    ),

    // 4: V5 Organic Warmth
    ColorNarrative(
      emotionalTone: 'Natural & Nurturing',
      emotions: ['Comfort', 'Trust', 'Wellness'],
      psychology:
          'Terracotta paired with sage green mirrors natural landscapes — '
          'research in biophilic design shows these combinations reduce cortisol '
          'levels by 8-12%. The warm cream background emulates natural paper, '
          'creating a tactile quality that digital screens usually lack.',
      harmonyType: 'Analogous',
      harmonyExplain:
          'Earth-toned palette stays within a 90-degree arc of warm hues, '
          'creating deep harmony reminiscent of autumn landscapes.',
      bestFor: 'Wellness content, mindful dating, organic marketplace listings, '
          'and any context where calm authenticity builds trust.',
      contrastNote:
          'Warm dark brown on cream meets AAA at body sizes. Terracotta on white '
          'passes AA. Sage green needs a dark background for text readability.',
      colorWorks:
          'Feels like holding a handmade ceramic mug — warm, textured, and '
          'genuinely comforting. The organic palette ages gracefully.',
      colorWeakness:
          'Can read as conservative or earthy-crunchy to some demographics. '
          'Limited punch for attention-grabbing CTAs in competitive feeds.',
    ),

    // 5: V6 Minimal Swiss
    ColorNarrative(
      emotionalTone: 'Precise & Authoritative',
      emotions: ['Clarity', 'Efficiency', 'Professionalism'],
      psychology:
          'The Swiss design tradition eliminates decoration to let information '
          'speak. Red accents exploit the urgency response — red processing is '
          'fastest among all hues. Black on white is the highest-contrast pairing '
          'possible, maximising scanning speed and comprehension.',
      harmonyType: 'Monochromatic + Accent',
      harmonyExplain:
          'Black-white backbone with a single red accent creates maximum '
          'visual hierarchy from minimum elements.',
      bestFor: 'Information-dense interfaces, professional profiles, marketplace '
          'listings where clarity and scannability are paramount.',
      contrastNote:
          'Black on white is 21:1 — the theoretical maximum. Red on white at '
          'large sizes passes AA. System requires no contrast workarounds.',
      colorWorks:
          'Aggressively functional — nothing competes with content. The red '
          'accent has maximum stopping power because there is zero colour noise.',
      colorWeakness:
          'Can feel clinical or cold for intimate contexts like dating. No '
          'emotional warmth — every surface is a working surface.',
    ),

    // 6: V9 Hyper-Local Street
    ColorNarrative(
      emotionalTone: 'Raw & Urban',
      emotions: ['Energy', 'Locality', 'Authenticity'],
      psychology:
          'Red signals urgency and passion — street culture leverages this '
          'for immediacy. Blue-grey secondary provides trust-anchoring calm, '
          'a counterweight seen in urban signage systems worldwide. Orange '
          'tertiary brings warmth without softening the edge.',
      harmonyType: 'Split-Complementary',
      harmonyExplain:
          'Red primary with blue-grey and warm orange flanking its complement, '
          'creating dynamic tension without the harshness of pure complements.',
      bestFor: 'Location-based discovery, neighbourhood social feeds, street '
          'market browsing — anything rooted in local culture and immediacy.',
      contrastNote:
          'Dark text on warm off-white meets AAA. Red accents are strong on '
          'white but need size considerations on the warm background.',
      colorWorks:
          'Feels like a well-designed street poster — bold, immediate, and '
          'impossible to ignore. The warm paper tone grounds the energy.',
      colorWeakness:
          'Red fatigue in heavy usage — too many red elements reduce urgency '
          'effectiveness. The palette can feel aggressive in quieter contexts.',
    ),

    // 7: V10 Calm Tech
    ColorNarrative(
      emotionalTone: 'Soft & Serene',
      emotions: ['Peace', 'Creativity', 'Mindfulness'],
      psychology:
          'Lavender activates the parasympathetic nervous system, lowering '
          'heart rate and blood pressure. Combined with mint green and soft '
          'pink, this triadic palette creates what neuroscientists call "soft '
          'fascination" — engaged attention without cognitive load.',
      harmonyType: 'Triadic (Pastel)',
      harmonyExplain:
          'Purple, green, and pink form an equilateral triangle, but at low '
          'saturation the contrast is gentle rather than jarring.',
      bestFor: 'Meditation content, thoughtful social connections, wellness '
          'features, and any UI that wants to feel calming yet modern.',
      contrastNote:
          'Grey text on near-white passes AA at body sizes. Lavender accents '
          'are subtle — critical actions may need darker variants for clickability.',
      colorWorks:
          'Uniquely calming in a world of bold apps — the pastel palette '
          'feels like a deep breath. Distinctively modern without being harsh.',
      colorWeakness:
          'Low contrast pastels can wash out on cheaper screens. The softness '
          'may not convey enough urgency for marketplace or competitive dating.',
    ),
  ];

  // ─── Palette Narratives (12) ────────────────────────────────────────────
  // Indices match ColorPalette.all order exactly.

  static const _paletteNarratives = <ColorNarrative>[
    // 0: Sunset Boulevard
    ColorNarrative(
      emotionalTone: 'Warm & Passionate',
      emotions: ['Passion', 'Energy', 'Joy'],
      psychology:
          'Warm oranges and reds stimulate appetite and social engagement — '
          'restaurants use this extensively. These wavelengths increase perceived '
          'temperature and urgency. The golden yellow tertiary adds optimism, '
          'creating a sunrise-to-sunset emotional arc.',
      harmonyType: 'Analogous',
      harmonyExplain:
          'Orange, red, and yellow occupy adjacent warm positions, building '
          'intensity like heat rising.',
      bestFor: 'Food and lifestyle content, social gatherings, event promotion, '
          'and any feature that wants to feel celebratory.',
      contrastNote:
          'Dark brown text on seashell white meets AAA. Orange on white needs '
          'darkening for body text — pure orange fails AA below 18px.',
      colorWorks:
          'Impossible to feel cold — the palette radiates physical warmth and '
          'social energy. Makes food photography look irresistible.',
      colorWeakness:
          'Red-orange palette triggers anxiety in some users. Extended exposure '
          'causes warm-hue fatigue. Poor for conveying calm or professionalism.',
    ),

    // 1: Coral Reef
    ColorNarrative(
      emotionalTone: 'Warm & Inviting',
      emotions: ['Warmth', 'Comfort', 'Harmony'],
      psychology:
          'Coral (Pantone 2019 Colour of the Year) bridges pink warmth and '
          'orange energy. Paired with sage green, it creates a Mediterranean '
          'harmony. The muted mustard accent adds earthiness, grounding the '
          'otherwise buoyant palette.',
      harmonyType: 'Complementary (Muted)',
      harmonyExplain:
          'Coral and sage sit opposite each other but are desaturated enough '
          'to feel harmonious rather than clashing.',
      bestFor: 'Lifestyle content, casual social discovery, home and garden '
          'marketplace, food photography backgrounds.',
      contrastNote:
          'Warm dark text on blush white meets AAA. Coral on white passes AA '
          'at heading sizes but needs care at small text.',
      colorWorks:
          'Feels like a Tuscan villa — warm stone, green shutters, terracotta '
          'pots. Universally pleasant and photogenic.',
      colorWeakness:
          'The muted quality can feel wishy-washy compared to bolder palettes. '
          'Navy tertiary feels out of place in the warm scheme.',
    ),

    // 2: Golden Hour
    ColorNarrative(
      emotionalTone: 'Warm & Nostalgic',
      emotions: ['Nostalgia', 'Warmth', 'Authenticity'],
      psychology:
          'Gold and amber trigger memories of late afternoon sunlight — the '
          '"golden hour" beloved by photographers. These tones increase '
          'perceived warmth and sincerity. The teal accent provides a cool '
          'counterpoint like evening sky meeting warm earth.',
      harmonyType: 'Complementary',
      harmonyExplain:
          'Warm gold and cool teal form a natural complement — like sunset '
          'light against a blue sky.',
      bestFor: 'Photo-centric feeds, nostalgic content, artisanal marketplace, '
          'and profiles emphasising authenticity and craft.',
      contrastNote:
          'Dark earth text on warm cream meets AAA. Gold accents on white '
          'need darkening — pure gold fails AA for body text.',
      colorWorks:
          'Every photo looks better in golden light — this palette acts as a '
          'built-in Instagram filter for the entire UI.',
      colorWeakness:
          'The warm tint can look yellowed on poorly calibrated screens. Teal '
          'accent feels disconnected from the golden warmth.',
    ),

    // 3: Sahara Dusk
    ColorNarrative(
      emotionalTone: 'Earthy & Timeless',
      emotions: ['Heritage', 'Warmth', 'Groundedness'],
      psychology:
          'Desert earth tones are among the oldest colours in human art — '
          'cave paintings used these exact pigments 40,000 years ago. Brown and '
          'ochre create deep comfort associations tied to wood, soil, and '
          'natural shelter. The palette feels ancestrally familiar.',
      harmonyType: 'Analogous (Earth)',
      harmonyExplain:
          'Sand, terracotta, ochre, and umber form a naturally occurring '
          'palette — these colours literally sit together in sedimentary rock.',
      bestFor: 'Artisan marketplaces, heritage content, travel and exploration, '
          'and profiles emphasising depth over flash.',
      contrastNote:
          'Dark brown text on warm cream exceeds AAA. Earth-tone accents need '
          'darker values for small text — mid-browns can drift below AA.',
      colorWorks:
          'Timeless and universally warm. The palette photographs beautifully '
          'and makes handmade items look premium.',
      colorWeakness:
          'Can read as old-fashioned to younger audiences expecting digital-native '
          'colours. Lacks any cool accent to create visual surprise.',
    ),

    // 4: Ocean Depths
    ColorNarrative(
      emotionalTone: 'Deep & Trustworthy',
      emotions: ['Trust', 'Calm', 'Depth'],
      psychology:
          'Blue is the most universally preferred colour — 57% of men and 35% '
          'of women cite it as their favourite. Deep ocean blues activate '
          'associations with stability, intelligence, and reliability. The '
          'graduating blues mimic water depth, creating a natural visual hierarchy.',
      harmonyType: 'Monochromatic',
      harmonyExplain:
          'Multiple blues at different lightness values create depth and '
          'hierarchy without introducing competing hues.',
      bestFor: 'Trust-critical interfaces — financial features, verified profiles, '
          'professional networking, and community safety messaging.',
      contrastNote:
          'Dark navy text on alice blue meets AAA. Mid-blues on white need '
          'careful sizing — check AA compliance at body text sizes.',
      colorWorks:
          'Universally inoffensive yet distinctive — ocean blues feel premium '
          'and trustworthy. The monochromatic approach makes hierarchy intuitive.',
      colorWeakness:
          'All-blue can feel corporate or cold for dating and social contexts. '
          'Lacks a warm accent to create emotional connection.',
    ),

    // 5: Nordic Frost
    ColorNarrative(
      emotionalTone: 'Crisp & Serene',
      emotions: ['Clarity', 'Calm', 'Sophistication'],
      psychology:
          'The Nordic colour palette draws from Scandinavian winters — ice blues '
          'and cool grays that activate cooling associations. Studies show rooms '
          'in light blue tones are perceived as 3-4 degrees cooler. The muted '
          'saturation creates a sense of refined restraint and quiet confidence.',
      harmonyType: 'Analogous (Cool)',
      harmonyExplain:
          'Steel blue, slate, and ice cyan sit adjacent on the cool side of the '
          'wheel, creating a cohesive Nordic atmosphere with subtle depth.',
      bestFor: 'Clean data displays, professional profiles, content that '
          'benefits from a sense of measured calm and quiet authority.',
      contrastNote:
          'Dark slate text on near-white exceeds AAA. Mid-tone blues on light '
          'backgrounds need careful checking — some fail AA at body sizes.',
      colorWorks:
          'Distinctively Nordic — the muted palette feels intelligent and '
          'considered. Every element reads as intentionally placed.',
      colorWeakness:
          'Can feel cold or emotionally distant for dating and social warmth. '
          'The grey undertones may read as dull on low-quality screens.',
    ),

    // 6: Rose Quartz
    ColorNarrative(
      emotionalTone: 'Soft & Romantic',
      emotions: ['Romance', 'Gentleness', 'Elegance'],
      psychology:
          'Pink tones lower aggression and create nurturing associations. '
          'Research shows exposure to pink reduces hostile behaviour (Baker-Miller '
          'pink). The mauve secondary adds sophistication, preventing the palette '
          'from feeling juvenile. Deep rose tertiary grounds the softness.',
      harmonyType: 'Analogous',
      harmonyExplain:
          'Pink, mauve, and rose form a natural gradient through the cool-warm '
          'spectrum, unified by their red undertones.',
      bestFor: 'Dating profiles, romantic content, beauty and wellness, '
          'and any context where softness and approachability are key.',
      contrastNote:
          'Dark plum text on rose-white meets AAA. Pink accents on white '
          'are subtle — ensure interactive elements are large enough.',
      colorWorks:
          'Genuinely romantic without being saccharine — the mauve-rose range '
          'adds maturity. Photos of people look great against these tones.',
      colorWeakness:
          'Strong gender association may deter some users. Can feel one-note '
          'without a contrasting accent. Fades on low-quality displays.',
    ),

    // 7: Forest Canopy
    ColorNarrative(
      emotionalTone: 'Fresh & Balanced',
      emotions: ['Growth', 'Balance', 'Renewal'],
      psychology:
          'Green is processed by the largest number of retinal cones, making '
          'it the easiest colour to see. Forest greens trigger biophilic '
          'responses — studies show viewing green for 40 seconds improves '
          'creative performance by 20%. This palette mimics dappled sunlight '
          'through leaves.',
      harmonyType: 'Monochromatic',
      harmonyExplain:
          'Dark to light greens create a natural gradient that reads like '
          'forest depth — dense canopy to bright clearing.',
      bestFor: 'Wellness features, eco-conscious marketplace, outdoor activity '
          'social, and sustainability-focused content.',
      contrastNote:
          'Dark green text on mint-white meets AAA. Mid-greens on white can '
          'drift below AA — use the darkest green for readable text.',
      colorWorks:
          'Instantly signals health and nature. The darkest green feels premium, '
          'the lightest feels fresh — the range carries real emotional variation.',
      colorWeakness:
          'All-green interfaces can feel clinical or institutional. Lacks warmth '
          'for personal and dating contexts. Red-green colour blindness reduces '
          'differentiation for ~8% of men.',
    ),

    // 8: Slate Professional
    ColorNarrative(
      emotionalTone: 'Neutral & Professional',
      emotions: ['Stability', 'Neutrality', 'Timelessness'],
      psychology:
          'Cool grays with a blue-steel undertone signal competence and '
          'reliability. Grey amplifies surrounding content rather than '
          'competing with it. The blue accent provides a precise focal point '
          'that stands out sharply against the neutral background, like a '
          'single spotlight in a grey room.',
      harmonyType: 'Achromatic + Accent',
      harmonyExplain:
          'Blue-grey scale provides structure through value alone, while '
          'the blue accent creates hierarchy without colour noise.',
      bestFor: 'Content-first interfaces, photography showcases, professional '
          'profiles, and any context where content should do the talking.',
      contrastNote:
          'Near-black on slate-white exceeds AAA. Mid-greys need careful '
          'management — the 4.5:1 AA threshold falls around the 50% mark.',
      colorWorks:
          'The ultimate content showcase — nothing distracts from the user\'s '
          'photos, text, and listings. Feels timeless and permanent.',
      colorWeakness:
          'Minimal personality — the palette expresses little about the brand. '
          'Can feel dull in social contexts. Interactive elements need the blue '
          'accent to be distinguishable.',
    ),

    // 9: Midnight Purple
    ColorNarrative(
      emotionalTone: 'Dark & Creative',
      emotions: ['Mystery', 'Creativity', 'Intensity'],
      psychology:
          'Purple on dark backgrounds is associated with creativity, luxury, '
          'and the mystical. Near-black reduces visual noise to zero, making '
          'purple accents feel precious — like gemstones in a dark room. The '
          'violet-to-lilac range stimulates creative and contemplative pathways.',
      harmonyType: 'Analogous (Dark)',
      harmonyExplain:
          'Deep violet, purple, and lilac are neighbours on the cool side, '
          'creating a cohesive dark mood with enough variation to distinguish '
          'UI elements.',
      bestFor: 'Night-mode interfaces, creative portfolios, music and '
          'entertainment feeds, premium dating experiences.',
      contrastNote:
          'Lavender text on near-black meets AAA easily. Purple accents need '
          'sufficient lightness — dark purple on dark backgrounds disappears.',
      colorWorks:
          'Dramatic and immersive — content floating on darkness feels curated '
          'and exclusive. Purple glows carry genuine visual magic.',
      colorWeakness:
          'Very dark interfaces lack visual landmarks for navigation. Extended '
          'use can feel heavy and isolating. True blacks cause OLED smearing.',
    ),

    // 10: Neon Tokyo
    ColorNarrative(
      emotionalTone: 'Electric & Intense',
      emotions: ['Adrenaline', 'Rebellion', 'Futurism'],
      psychology:
          'Hot pink, electric teal, and neon yellow on near-black mirror the '
          'sensory overload of Tokyo nightlife signage. This combination triggers '
          'maximum alertness — the brain processes neon colours as urgent signals. '
          'The multi-chromatic approach creates a toxic-energy cocktail that feels '
          'dangerously exciting.',
      harmonyType: 'Tetradic (High Saturation)',
      harmonyExplain:
          'Four fully-saturated hues form a rectangle on the colour wheel — '
          'maximum variety, maximum energy, minimal subtlety.',
      bestFor: 'Gaming-adjacent social features, nightlife discovery, '
          'high-energy video feeds, youth and counter-culture audiences.',
      contrastNote:
          'Neon pink on black has excellent contrast (14:1+). Teal on black '
          'is also strong. Yellow accents pop but need size care for readability.',
      colorWorks:
          'Unmistakable and unforgettable — like a neon sign in a dark alley. '
          'Maximum attention-grabbing power for scroll-heavy feeds.',
      colorWeakness:
          'Visual assault in extended use. Impossible to use for body text at '
          'small sizes. Alienates older demographics immediately.',
    ),

    // 11: Electric Violet
    ColorNarrative(
      emotionalTone: 'Bold & Futuristic',
      emotions: ['Innovation', 'Confidence', 'Dynamism'],
      psychology:
          'Indigo-violet paired with electric cyan creates a digital-native '
          'palette that signals cutting-edge technology. Violet activates '
          'creative neural pathways while cyan adds clarity and focus. The '
          'pink tertiary prevents the cool palette from feeling sterile, '
          'adding an unexpected warmth that humanises the technology.',
      harmonyType: 'Split-Complementary (Dark)',
      harmonyExplain:
          'Violet primary flanked by cyan and pink — warm and cool accents '
          'splitting the complement for dynamic tension without clash.',
      bestFor: 'Tech-forward features, creative tools, music and media feeds, '
          'and audiences who identify with digital culture and innovation.',
      contrastNote:
          'Light lavender text on deep navy-violet meets AAA. Cyan accents '
          'provide excellent visibility against the dark surface. Pink highlights '
          'read clearly at heading sizes.',
      colorWorks:
          'The palette feels like the future — a digital aurora borealis. '
          'Each accent colour pops with its own personality against the dark '
          'canvas, creating genuine visual excitement.',
      colorWeakness:
          'The multi-chromatic dark palette can feel chaotic if overused. '
          'Needs careful restraint — too many competing neon accents create '
          'visual noise rather than hierarchy.',
    ),
  ];
}
