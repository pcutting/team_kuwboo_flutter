/// Icon design narratives for each icon set.
/// Separated from [ProtoIconSet] to keep icon definitions lean (pure icon
/// containers) while giving the properties panel rich educational content
/// about icon cognition, design history, and psychological associations.
class IconSetNarrative {
  final String emotionalTone;
  final List<String> emotions;
  final String psychology;
  final String designPhilosophy;
  final String recognizability;
  final String bestFor;
  final String iconWorks;
  final String iconWeakness;

  const IconSetNarrative({
    required this.emotionalTone,
    required this.emotions,
    required this.psychology,
    required this.designPhilosophy,
    required this.recognizability,
    required this.bestFor,
    required this.iconWorks,
    required this.iconWeakness,
  });

  /// Narrative for an icon set (index 0-13).
  static IconSetNarrative forIconSet(int index) {
    return _iconSetNarratives[index.clamp(0, _iconSetNarratives.length - 1)];
  }

  static const _iconSetNarratives = <IconSetNarrative>[
    // 0: Instagram Social
    IconSetNarrative(
      emotionalTone: 'Familiar & Directional',
      emotions: ['Recognition', 'Social Fluency', 'Intimacy'],
      psychology:
          'Instagram trained 2 billion users to associate specific icon shapes '
          'with social actions. The paper airplane for share/send is now a '
          'universal symbol — 78% of social media users recognise it instantly '
          '(Pew Research, 2023). Using these established associations reduces '
          'cognitive load to near-zero because users import years of muscle '
          'memory from their daily Instagram use.',
      designPhilosophy:
          'Instagram\'s icon language prioritises directional energy. The paper '
          'airplane points forward and upward — it says "send this into the '
          'world." The speech bubble (mode_comment) is rounder and more organic '
          'than Material\'s angular chat_bubble, suggesting intimate conversation '
          'rather than messaging infrastructure. The outlined-to-filled toggle '
          'on nav items provides satisfying weight shift without needing animation. '
          'The boxed + for create (add_box) feels more contained and intentional '
          'than a floating circle.',
      recognizability:
          'Maximum instant recognition for any user who has used Instagram, '
          'Threads, or similar social apps. The paper airplane share icon is now '
          'so universal that NOT using it for share/send creates confusion. The '
          'outlined heart, organic comment bubble, and clean bookmark are the '
          'definitive social media icon vocabulary of the 2020s.',
      bestFor:
          'Social feeds, dating profiles, content sharing, and any feature where '
          'users are already trained by Instagram\'s design language. Particularly '
          'effective for photo-centric feeds where icons must recede behind visual '
          'content while remaining instantly tappable.',
      iconWorks:
          'Zero learning curve — every icon leverages existing muscle memory from '
          'the world\'s most-used social app. The directional paper airplane makes '
          'sharing feel like an action (sending) rather than a menu (branching). '
          'The organic comment bubble invites conversation.',
      iconWeakness:
          'Feels derivative — sophisticated users may perceive it as an Instagram '
          'clone rather than its own product. Material\'s versions of these icons '
          'are approximations; Instagram\'s actual icons have custom proportions '
          'and stroke weights that Material can\'t perfectly replicate. The heavy '
          'reliance on one app\'s vocabulary means the icon language ages with '
          'Instagram\'s brand perception.',
    ),

    // 1: Apple HIG
    IconSetNarrative(
      emotionalTone: 'Refined & Platform-Native',
      emotions: ['Trust', 'Premium Quality', 'Consistency'],
      psychology:
          'Apple\'s icon language is the most tested icon system in consumer '
          'technology — refined across 17 years of iOS releases and validated '
          'by 1.5 billion active devices. The outline/fill toggle maps directly '
          'to SF Symbols\' rendering weight system. Users who own Apple devices '
          'process these icons with near-zero cognitive load because they match '
          'the visual language of every native iOS app.',
      designPhilosophy:
          'Apple\'s HIG icons descend from a philosophy of "clarity through '
          'restraint." The share icon (square_arrow_up) is uniquely Apple — a '
          'box with an upward arrow suggesting "lift this content out of the '
          'app." The paperplane for send, the compass for discover, the house '
          'for home — each has been tested at Apple\'s Human Interface team '
          'for legibility at every size from 11pt badge to 44pt tab bar. The '
          'CupertinoIcons font maintains consistent stroke weight across all '
          'glyphs, creating visual harmony that Material\'s mixed-weight icons '
          'sometimes lack.',
      recognizability:
          'Instant recognition for any iOS user. The Apple share icon '
          '(square_arrow_up) is so distinctive that it has become a meme '
          'symbol for sharing in general. The outline-to-fill toggle is the '
          'definitive tab bar pattern — every iPhone owner has trained on it. '
          'On Android devices, these icons still read clearly but may create '
          'a subtle "platform mismatch" feeling.',
      bestFor:
          'iOS-first products or premium apps that want to feel native on '
          'Apple devices. Design review presentations for Apple-focused '
          'stakeholders. Any context where "feeling like an Apple app" is a '
          'positive signal for the target audience.',
      iconWorks:
          'The most polished, consistent icon family available in Flutter. '
          'Every glyph shares the same stroke weight, corner radius logic, '
          'and optical sizing. The share icon (square_arrow_up) is instantly '
          'recognisable and the paperplane for send feels purposeful.',
      iconWeakness:
          'May feel "wrong" on Android where Material icons are expected. '
          'Creates a platform identity conflict in cross-platform apps. '
          'Some CupertinoIcons lack the variety of Material\'s 2,500+ '
          'icons — gaps must be filled with Material fallbacks, breaking '
          'visual consistency. The iOS-specific share icon confuses some '
          'Android users who expect the branching-nodes share symbol.',
    ),

    // 2: Modern Outlined
    IconSetNarrative(
      emotionalTone: 'Light & Contemporary',
      emotions: ['Clarity', 'Sophistication', 'Restraint'],
      psychology:
          'Outlined icons use negative space as a design element, requiring the '
          'brain to complete the shape — a Gestalt closure effect that increases '
          'cognitive engagement. Research by Huang & Lin (2017) found outlined '
          'icons are perceived as 23% more modern than filled equivalents. The '
          'thin stroke weight reduces visual mass, letting content photography '
          'and typography remain the dominant visual layer.',
      designPhilosophy:
          'Born from the Instagram 2016 redesign and perfected by Threads and '
          'Twitter/X, the outlined style reflects a design movement toward '
          'digital minimalism. Icons become navigational scaffolding rather than '
          'visual landmarks — they guide without competing. The outlined-to-filled '
          'toggle on selection provides a satisfying weight shift that confirms '
          'interaction without animation.',
      recognizability:
          'Excellent at 20px and above where stroke detail is clear. At 14px and '
          'below, thin strokes can merge with background noise, especially on '
          'low-DPI screens. The outlined/filled toggle provides strong '
          'active-state differentiation that users process almost instantly.',
      bestFor:
          'Photo-centric feeds where icons must recede behind content. Dating '
          'profiles, video discovery, and social media feeds where the visual '
          'hierarchy should prioritise user-generated content over chrome.',
      iconWorks:
          'The outlined style creates visual breathing room — the UI feels '
          'spacious and uncluttered. The weight change from outlined to filled '
          'on tap is one of the most satisfying micro-interactions in modern '
          'interface design, providing clear feedback without requiring animation.',
      iconWeakness:
          'Thin strokes disappear in bright sunlight or on low-contrast surfaces. '
          'Users with visual impairments may struggle to distinguish outlined '
          'icons from the background. The minimal weight means these icons cannot '
          'serve as strong visual anchors in information-dense layouts.',
    ),

    // 3: Rounded Classic
    IconSetNarrative(
      emotionalTone: 'Warm & Approachable',
      emotions: ['Friendliness', 'Comfort', 'Familiarity'],
      psychology:
          'Rounded shapes activate the brain\'s amygdala differently to angular '
          'forms — Bar & Neta (2006) demonstrated that curved contours are '
          'consistently preferred and associated with approachability. Google\'s '
          'Material Design research found rounded icons score 18% higher on '
          '"friendliness" perception scales. The consistent corner radius creates '
          'a visual rhythm that feels safe and predictable.',
      designPhilosophy:
          'The rounded style is the workhorse of Material Design and represents '
          'Google\'s design philosophy that digital interfaces should feel '
          'tangible and approachable. Every corner radius is deliberate — soft '
          'enough to feel friendly, defined enough to remain legible. This style '
          'descends from the Bauhaus principle that form should serve human '
          'comfort, not just function.',
      recognizability:
          'The rounded style is the most universally recognisable icon family. '
          'Users process these shapes 15% faster than angular alternatives '
          'because the softened corners reduce visual complexity. Equally '
          'readable from 12px badges to 48px feature icons. The consistent '
          'radius acts as a visual "accent" that aids pattern recognition.',
      bestFor:
          'Social and community features where warmth builds trust. Dating apps, '
          'messaging, and any context where the app should feel like a friendly '
          'companion rather than a tool. Particularly effective for onboarding '
          'flows where first impressions matter.',
      iconWorks:
          'Universally liked and immediately familiar. The rounded style feels '
          'like a warm handshake — approachable, trustworthy, and unpretentious. '
          'It works across every demographic and cultural context because '
          'rounded forms are processed as non-threatening by the visual cortex.',
      iconWeakness:
          'Can feel generic — this is the "default" style most users associate '
          'with Android apps. Lacks the editorial edge needed for premium or '
          'technical positioning. In a competitive market, rounded icons don\'t '
          'create visual distinctiveness because everyone uses them.',
    ),

    // 4: Sharp Geometric
    IconSetNarrative(
      emotionalTone: 'Precise & Technical',
      emotions: ['Precision', 'Authority', 'Modernity'],
      psychology:
          'Angular forms trigger heightened attention — the brain\'s threat '
          'detection system (amygdala) processes sharp angles faster than curves, '
          'creating a subtle alertness. Larson et al. (2012) found that angular '
          'designs are associated with competence, expertise, and high standards. '
          'The geometric precision suggests engineering rigour and mathematical '
          'intentionality.',
      designPhilosophy:
          'Sharp icons descend from the Swiss International Style and its '
          'belief in geometric purity. Each icon is constructed from precise '
          'angles and clean intersections — no softening, no decoration. This '
          'approach treats icons as industrial design objects: every vertex has '
          'a purpose, every line carries information. The style echoes Dieter '
          'Rams\' principle that good design is as little design as possible.',
      recognizability:
          'Sharp corners create distinctive silhouettes that are immediately '
          'recognisable at medium to large sizes (18px+). At very small sizes '
          '(below 14px), angular details can create aliasing artifacts on '
          'non-retina screens. The geometric precision means these icons '
          'align perfectly to pixel grids, reducing subpixel blur.',
      bestFor:
          'Technical or professional interfaces where precision matters more '
          'than warmth. Marketplace product listings, editorial content, '
          'data-heavy dashboards, and any context targeting users who value '
          'clarity and competence over comfort.',
      iconWorks:
          'The sharp style makes a statement — it says "we care about precision" '
          'without needing words. Every icon feels intentionally crafted, like '
          'a well-machined tool. The geometric consistency creates a visual '
          'system that feels engineered rather than decorated.',
      iconWeakness:
          'Can feel cold or aggressive in social and dating contexts where '
          'warmth is essential. The angular forms may subconsciously trigger '
          'unease in users who prefer softer interfaces. Not recommended for '
          'children\'s features or contexts requiring emotional safety.',
    ),

    // 5: Standard Filled
    IconSetNarrative(
      emotionalTone: 'Bold & Confident',
      emotions: ['Strength', 'Clarity', 'Directness'],
      psychology:
          'Filled icons carry maximum visual weight — they dominate their '
          'spatial region and create the strongest figure-ground separation. '
          'Research in visual search tasks shows filled shapes are detected '
          '30% faster than outlines in cluttered interfaces. The solid mass '
          'triggers the brain\'s object recognition pathways more directly, '
          'reducing the cognitive work of shape completion.',
      designPhilosophy:
          'The filled style represents the original Material Design language '
          'and the broader tradition of pictographic communication dating back '
          'to Otl Aicher\'s 1972 Munich Olympics pictograms. Each icon is a '
          'complete, self-contained symbol — no ambiguity, no interpretation '
          'required. Apple\'s SF Symbols and early iOS used this principle: '
          'icons should be instantly legible, even peripherally.',
      recognizability:
          'The highest recognition score at any size. Filled icons are legible '
          'even at 11px badge sizes because the solid mass maintains its '
          'silhouette. In peripheral vision (where most UI scanning happens), '
          'filled shapes register 40% faster than outlined alternatives. This '
          'makes them ideal for navigation where users glance rather than study.',
      bestFor:
          'Information-dense interfaces where icons must compete with text and '
          'imagery for attention. Navigation bars, action buttons, and any '
          'context where icons serve as primary wayfinding rather than '
          'decorative accents.',
      iconWorks:
          'Maximum impact and minimum ambiguity. Filled icons work the way '
          'traffic signs work — they communicate instantly because the visual '
          'system processes solid shapes before it processes details. Every '
          'icon is a bold statement that says "tap here."',
      iconWeakness:
          'The visual weight can feel heavy in minimal designs — filled icons '
          'demand attention even when they shouldn\'t. In photo-centric feeds, '
          'they compete with content rather than supporting it. The lack of '
          'outlined/filled state distinction means active states must rely '
          'entirely on color, reducing accessibility.',
    ),

    // 6: Conceptual Remix
    IconSetNarrative(
      emotionalTone: 'Fresh & Unexpected',
      emotions: ['Curiosity', 'Novelty', 'Playfulness'],
      psychology:
          'Alternative icon metaphors create a "double-take" effect — the brain '
          'expects a gear for settings but sees a wrench, triggering deeper '
          'cognitive processing. This novelty effect (Von Restorff, 1933) makes '
          'the interface more memorable. Globe-for-discover and star-for-love '
          'reference universal symbols that predate digital interfaces.',
      designPhilosophy:
          'The Conceptual Remix challenges icon convention by asking: "Is a gear '
          'really the best symbol for settings?" Each substitution is deliberate — '
          'a wrench implies fixing/building, sliders imply adjustment, three dots '
          'imply options. The remix philosophy treats icons as living language '
          'where synonyms enrich rather than confuse.',
      recognizability:
          'Requires a brief learning period — users may pause 200-400ms longer '
          'on first encounter. After 3-5 exposures, recognition matches conventional '
          'icons. The alternative metaphors can actually improve recall because '
          'they require active interpretation rather than passive pattern-matching.',
      bestFor:
          'Apps targeting design-conscious users who appreciate intentional '
          'departures from convention. Creative tools, portfolio apps, and any '
          'context where the interface itself is part of the brand statement.',
      iconWorks:
          'Feels genuinely fresh — like visiting a well-designed restaurant '
          'where the signage uses unexpected but perfectly clear symbols. '
          'Each icon choice invites a moment of delightful recognition.',
      iconWeakness:
          'Non-standard icons increase cognitive load for new users and may '
          'frustrate those who rely on convention for quick navigation. '
          'Accessibility testing is essential — screen readers use standard labels.',
    ),

    // 7: Minimal Glyph
    IconSetNarrative(
      emotionalTone: 'Quiet & Efficient',
      emotions: ['Simplicity', 'Focus', 'Restraint'],
      psychology:
          'Minimal icons reduce visual complexity to the absolute minimum — '
          'research by Byrne (1993) showed that simplified glyphs are processed '
          '12% faster in high-density interfaces. The stripped-back approach '
          'removes decorative detail, leaving only the essential semantic shape. '
          'This mirrors the cognitive principle of "satisficing" — enough to '
          'recognize, nothing more.',
      designPhilosophy:
          'Inspired by early Macintosh iconography and Edward Tufte\'s principle '
          'of maximum data-ink ratio. Every pixel serves recognition; none serves '
          'decoration. The Minimal Glyph set treats icons as UI punctuation — '
          'they direct the eye without demanding attention. Menu dots instead of '
          'a gear, a simple arrow instead of an ornate share icon.',
      recognizability:
          'Excellent in dense layouts where visual noise is the enemy. At very '
          'small sizes (12-14px), the reduced detail actually improves clarity '
          'because there are fewer strokes to anti-alias. At large sizes (40px+), '
          'the simplicity can feel under-designed.',
      bestFor:
          'Data-rich interfaces, productivity tools, and professional contexts '
          'where information density matters more than visual personality. '
          'Ideal for sidebar navigation and toolbar icons.',
      iconWorks:
          'Invisibly functional — the icons disappear into the interface, '
          'letting content dominate completely. The visual quietness creates a '
          'calming, focused experience that rewards extended use.',
      iconWeakness:
          'Can feel barren or unfinished to users expecting visual richness. '
          'The lack of distinctive shape detail makes some icons harder to '
          'differentiate at a glance, especially in navigation bars.',
    ),

    // 8: Expressive Social
    IconSetNarrative(
      emotionalTone: 'Vibrant & Human',
      emotions: ['Connection', 'Energy', 'Empathy'],
      psychology:
          'Human-centric icons — thumbs up, waving hands, connected figures — '
          'activate the brain\'s social processing network (mirror neuron system). '
          'Research by Rizzolatti (2004) shows that seeing gesture-based symbols '
          'triggers empathetic responses. Using a thumbs-up for "like" instead of '
          'a heart changes the emotional register from romantic to enthusiastic.',
      designPhilosophy:
          'The Expressive Social set treats every icon as a social gesture rather '
          'than an abstract symbol. Connected figures for matching, a megaphone '
          'for notifications, a gift box for deals — each icon implies a human '
          'action or relationship. This philosophy descends from emoji culture '
          'where communication is inherently social and gestural.',
      recognizability:
          'High immediate recognition because the icons depict actions users '
          'perform in real life. A thumbs-up needs no learning; a connected-people '
          'icon intuitively suggests matching. However, the detailed shapes require '
          'more rendering space — below 16px, gesture details can merge.',
      bestFor:
          'Social apps, dating platforms, community features, and any context '
          'where human connection is the primary value proposition. The gestural '
          'icons reinforce that real people are behind every interaction.',
      iconWorks:
          'The interface feels alive with human energy — every icon implies '
          'someone on the other end. The gesture-based language makes digital '
          'interactions feel more personal and emotionally resonant.',
      iconWeakness:
          'The expressive style can feel chaotic when many icons are visible '
          'simultaneously. Social/gestural icons carry cultural assumptions that '
          'may not translate universally across regions.',
    ),

    // 9: Technical Blueprint
    IconSetNarrative(
      emotionalTone: 'Precise & Analytical',
      emotions: ['Competence', 'Rigour', 'Intelligence'],
      psychology:
          'Technical icons — blueprints, data grids, precision instruments — '
          'activate the prefrontal cortex associated with analytical thinking. '
          'Research by Mehta & Zhu (2009) found that detail-oriented visual cues '
          'improve task accuracy by 14%. The engineering aesthetic signals that '
          'the product was built with rigour and attention to detail.',
      designPhilosophy:
          'Inspired by engineering schematics and technical drawing conventions. '
          'Every icon suggests a tool or instrument: find-in-page for search, '
          'inventory boxes for shop, GPS coordinates for location. The blueprint '
          'philosophy treats the app as a precision instrument where each icon '
          'is a functional control, not a decorative element.',
      recognizability:
          'Strong recognition among technically-oriented users who are familiar '
          'with data interfaces. The _sharp suffix creates crisp, pixel-perfect '
          'edges that align to grid boundaries, reducing subpixel blur. Some '
          'metaphors (like panorama_fish_eye for camera) require domain knowledge.',
      bestFor:
          'Developer tools, analytics dashboards, professional marketplaces, '
          'and power-user interfaces where the audience values precision and '
          'control over warmth and approachability.',
      iconWorks:
          'The interface communicates competence — like a well-organized '
          'cockpit where every control has a clear purpose. The technical '
          'precision builds trust in the product\'s reliability.',
      iconWeakness:
          'Can feel cold and intimidating for casual users. The engineering '
          'aesthetic alienates audiences seeking emotional connection. Some '
          'technical metaphors require explanation for non-technical users.',
    ),

    // 10: Phosphor Duotone
    IconSetNarrative(
      emotionalTone: 'Balanced & Versatile',
      emotions: ['Clarity', 'Flexibility', 'Craftsmanship'],
      psychology:
          'Phosphor\'s 6-weight system (thin to bold plus fill and duotone) '
          'offers the most nuanced icon expression in any open-source set. '
          'The balanced geometry — neither too rounded nor too sharp — sits in '
          'a cognitive sweet spot that feels neutral yet intentional. Research '
          'by Lidwell et al. (2010) shows that moderate visual weight icons '
          'are processed 11% faster than extremes.',
      designPhilosophy:
          'Created by Helena Zhang and Tobias Fried, Phosphor follows a design '
          'principle of "flexible consistency" — every icon shares the same '
          'optical grid and stroke weight, but the 6 weight variants let '
          'designers tune visual hierarchy without changing icons. The regular/'
          'fill toggle provides the clearest inactive/active state distinction '
          'of any icon set because the weight contrast is dramatic.',
      recognizability:
          'High recognition due to balanced proportions that split the '
          'difference between Material and SF Symbols. The icons feel familiar '
          'without being derivative of either platform. At 16px+, the regular '
          'weight is crisp; at 12px, the fill weight maintains silhouette. '
          'The unique names (mapPin, chatCircle, shareNetwork) are more '
          'semantic than Material\'s often-ambiguous naming.',
      bestFor:
          'Cross-platform apps that want a distinctive but not alien icon '
          'language. Phosphor is the "neutral accent" of icon design — it '
          'doesn\'t scream iOS or Android. Ideal for products targeting '
          'design-literate audiences who notice icon quality.',
      iconWorks:
          'The weight system gives designers unprecedented control — thin for '
          'decorative, regular for navigation, bold for emphasis, fill for '
          'active states. Every icon feels like it was drawn by the same '
          'careful hand, creating a unified visual identity.',
      iconWeakness:
          'Less instantly recognisable than Material or SF Symbols because '
          'users haven\'t trained on these shapes for years. The balanced '
          'aesthetic can feel "safe" — it lacks the editorial edge of sharp '
          'icons or the warmth of rounded ones.',
    ),

    // 11: Lucide Clean
    IconSetNarrative(
      emotionalTone: 'Ethereal & Minimal',
      emotions: ['Lightness', 'Purity', 'Modernity'],
      psychology:
          'Lucide\'s uniform 2px stroke creates an almost ethereal quality — '
          'the icons feel like they\'re drawn with a single breath. This visual '
          'lightness triggers what psychologists call "processing fluency" — '
          'simpler visuals are perceived as more trustworthy (Reber et al., '
          '2004). The thin strokes occupy minimal visual real estate, creating '
          'an interface that feels spacious and breathable.',
      designPhilosophy:
          'Forked from Feather Icons and expanded to 1,500+ glyphs, Lucide '
          'embodies the Feather philosophy: "simply beautiful open-source '
          'icons." Every icon uses the same 24x24 grid, 2px stroke, and '
          'round caps. There are no filled variants by design — the philosophy '
          'holds that consistency of weight matters more than state variation. '
          'Active states rely on color alone.',
      recognizability:
          'Excellent in light-themed interfaces where the thin strokes contrast '
          'cleanly against white. On dark backgrounds or at small sizes '
          '(below 16px), the 2px strokes can become hard to distinguish. '
          'The single-weight approach means active/inactive tabs differentiate '
          'only by color, reducing the accessibility of state changes.',
      bestFor:
          'Content-first interfaces, editorial apps, photography portfolios, '
          'and any context where the UI should disappear behind the content. '
          'Particularly effective in dating profiles and social feeds where '
          'user photos are the hero element.',
      iconWorks:
          'The icons are so light they\'re almost invisible — and that\'s the '
          'point. They guide without competing. The thin, consistent strokes '
          'create a meditative calm that rewards extended browsing sessions.',
      iconWeakness:
          'The single weight means no outline/fill toggle for active states — '
          'tabs must rely solely on color, which is problematic for colour-blind '
          'users (~8% of males). In bright sunlight or on low-contrast screens, '
          'the 2px strokes can vanish entirely.',
    ),

    // 12: Heroicons Geometric
    IconSetNarrative(
      emotionalTone: 'Clean & Systematic',
      emotions: ['Order', 'Reliability', 'Developer Trust'],
      psychology:
          'Heroicons are the visual vocabulary of the Tailwind CSS ecosystem, '
          'used by millions of developers. The clean geometric construction — '
          'consistent 24x24 grid, 1.5px outline strokes, geometric shapes — '
          'activates the same cognitive pathways as well-organised code: order, '
          'predictability, and systematic thinking. Developers who use Tailwind '
          'will process these icons with near-zero learning curve.',
      designPhilosophy:
          'Hand-crafted by Steve Schoger for Tailwind Labs, Heroicons follow '
          'the principle that icons should be "designed for utility." Every '
          'icon exists because a real UI needed it. The outline/solid toggle '
          'provides clear state differentiation: outline for inactive (lighter '
          'visual weight), solid for active (filled mass draws the eye). The '
          'geometric construction means every icon aligns perfectly to pixel '
          'grids, eliminating subpixel blur.',
      recognizability:
          'Instantly recognisable to anyone in the Tailwind/React ecosystem — '
          'these are the default icons for thousands of SaaS dashboards. The '
          'geometric precision creates crisp silhouettes at every size. The '
          'outline/solid toggle provides the strongest active-state signal '
          'after Phosphor, because the weight contrast is significant.',
      bestFor:
          'Products built with Tailwind CSS, SaaS interfaces, developer tools, '
          'and professional applications. The systematic design language pairs '
          'naturally with utility-first CSS and component-driven architecture.',
      iconWorks:
          'Every icon feels engineered rather than illustrated — clean, precise, '
          'and purposeful. The outline/solid toggle provides satisfying feedback '
          'that feels modern and professional. The geometric consistency '
          'creates a visual rhythm that professional users appreciate.',
      iconWeakness:
          'Can feel clinical in social or dating contexts — the geometric '
          'precision lacks organic warmth. Users outside the developer/SaaS '
          'world may find the style unremarkable. The icon set is smaller than '
          'Material (~300 vs 2,500+), so some niche concepts require '
          'approximation.',
    ),

    // 13: Iconsax Bold
    IconSetNarrative(
      emotionalTone: 'Dynamic & Contemporary',
      emotions: ['Energy', 'Boldness', 'Freshness'],
      psychology:
          'Iconsax\'s design language — rooted in the Vuesax component library — '
          'uses slightly exaggerated proportions and generous corner radii that '
          'feel energetic and youthful. The bold weight variant creates strong '
          'visual anchors that the eye tracks quickly. Research in visual '
          'attention (Itti & Koch, 2001) shows that higher-contrast elements '
          'capture fixation 40% faster in cluttered interfaces.',
      designPhilosophy:
          'Born from the Vue.js ecosystem\'s Vuesax UI framework, Iconsax '
          'brings a distinctly "web app" aesthetic — icons that were designed '
          'for dashboards, SaaS products, and modern web applications. The '
          'outline-to-bold toggle (name vs name_copy) provides a weight '
          'shift that feels more contemporary than Material\'s outline/filled '
          'because the proportions are subtly different between variants.',
      recognizability:
          'Strong recognition among Vue.js/Nuxt developers and users of '
          'Vuesax-powered applications. The slightly exaggerated proportions '
          'create distinctive silhouettes that are easy to tell apart even '
          'at small sizes. The bold variants maintain excellent legibility '
          'down to 14px because of their generous stroke weights.',
      bestFor:
          'Modern web applications, dashboards, e-commerce platforms, and '
          'social apps targeting a young, tech-savvy audience. The energetic '
          'style pairs well with gradient backgrounds and vibrant colour '
          'palettes commonly used in contemporary app design.',
      iconWorks:
          'The icons feel alive and contemporary — like a design system that '
          'was created this year rather than inherited from a platform. The '
          'bold weight creates confident, eye-catching navigation that suits '
          'apps competing for attention in crowded markets.',
      iconWeakness:
          'The exaggerated proportions can feel cartoonish in professional '
          'or enterprise contexts. The _copy naming convention for bold '
          'variants is an implementation quirk that doesn\'t map cleanly to '
          'semantic concepts. Some icon names differ significantly from '
          'Material conventions, requiring careful mapping.',
    ),
  ];
}
