/// Demo data for design exploration
/// Uses free image sources for realistic previews

class DemoProfile {
  final String name;
  final int age;
  final String distance;
  final String bio;
  final List<String> tags;
  final int compatibility;
  final bool verified;
  final String imageUrl;
  final List<String> additionalImages;

  const DemoProfile({
    required this.name,
    required this.age,
    required this.distance,
    required this.bio,
    required this.tags,
    required this.compatibility,
    required this.verified,
    required this.imageUrl,
    this.additionalImages = const [],
  });
}

class NearbyUser {
  final String name;
  final String distance;
  final String imageUrl;
  final bool isNew;
  final bool isOnline;
  final List<String> interests;
  final bool isFriend;

  const NearbyUser({
    required this.name,
    required this.distance,
    required this.imageUrl,
    required this.isNew,
    this.isOnline = false,
    this.interests = const [],
    this.isFriend = false,
  });

  /// Parse the numeric km value from the distance string (e.g. "0.3 km" → 0.3).
  double get distanceKm {
    final match = RegExp(r'[\d.]+').firstMatch(distance);
    return match != null ? double.tryParse(match.group(0)!) ?? 1.0 : 1.0;
  }
}

/// Demo profiles for dating cards
/// Images from RandomUser.me - free API for random user photos
class DemoData {
  // All profiles combined into a single deck for the card stack
  static List<DemoProfile> get allProfiles => [mainProfile, ...alternativeProfiles];

  // Main profile shown on dating card
  static const mainProfile = DemoProfile(
    name: 'Maya',
    age: 24,
    distance: '2.3 km',
    bio: 'Designer by day, DJ by night. I make things look good and sound better. Not here for small talk.',
    tags: ['Design', 'Music', 'Coffee', 'Art'],
    compatibility: 87,
    verified: true,
    imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=600&fit=crop',
    additionalImages: [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400&h=600&fit=crop',
    ],
  );

  // Alternative profiles for variety
  static const alternativeProfiles = [
    DemoProfile(
      name: 'Alex',
      age: 28,
      distance: '0.8 km',
      bio: 'Software engineer who loves hiking and craft beer. Looking for someone to explore the city with.',
      tags: ['Tech', 'Hiking', 'Beer', 'Travel'],
      compatibility: 92,
      verified: true,
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
    ),
    DemoProfile(
      name: 'Jordan',
      age: 26,
      distance: '1.5 km',
      bio: 'Photographer and coffee enthusiast. Always chasing golden hour.',
      tags: ['Photography', 'Coffee', 'Nature', 'Film'],
      compatibility: 78,
      verified: false,
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&h=600&fit=crop',
    ),
    DemoProfile(
      name: 'Sam',
      age: 31,
      distance: '3.2 km',
      bio: 'Chef by profession, foodie by passion. Let me cook for you.',
      tags: ['Cooking', 'Wine', 'Travel', 'Dogs'],
      compatibility: 85,
      verified: true,
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=600&fit=crop',
    ),
  ];

  // Nearby users for Yoyo screen (~20 users to stress-test crowding)
  static const nearbyUsers = [
    NearbyUser(
      name: 'Alex',
      distance: '0.3 km',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: true,
      interests: ['hiking', 'tech', 'beer'],
      isFriend: true,
    ),
    NearbyUser(
      name: 'Maya',
      distance: '0.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['music', 'design', 'coffee'],
      isFriend: true,
    ),
    NearbyUser(
      name: 'Jordan',
      distance: '1.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: false,
      interests: ['photography', 'coffee', 'nature'],
    ),
    NearbyUser(
      name: 'Sam',
      distance: '1.5 km',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['cooking', 'wine', 'travel'],
      isFriend: true,
    ),
    NearbyUser(
      name: 'Riley',
      distance: '2.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: false,
      interests: ['yoga', 'reading', 'art'],
    ),
    NearbyUser(
      name: 'Priya',
      distance: '0.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: true,
      interests: ['music', 'travel', 'coffee'],
      isFriend: true,
    ),
    NearbyUser(
      name: 'Kai',
      distance: '0.6 km',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['tech', 'photography'],
    ),
    NearbyUser(
      name: 'Luna',
      distance: '1.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: false,
      interests: ['art', 'yoga', 'nature'],
    ),
    NearbyUser(
      name: 'Marco',
      distance: '2.5 km',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: true,
      interests: ['cooking', 'beer', 'travel'],
    ),
    NearbyUser(
      name: 'Zara',
      distance: '3.0 km',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['design', 'music'],
    ),
    NearbyUser(
      name: 'Toby',
      distance: '3.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: false,
      interests: ['hiking', 'nature', 'beer'],
      isFriend: true,
    ),
    NearbyUser(
      name: 'Ava',
      distance: '4.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: false,
      interests: ['reading', 'coffee'],
    ),
    NearbyUser(
      name: 'Dex',
      distance: '4.9 km',
      imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['tech', 'wine'],
    ),
    NearbyUser(
      name: 'Nina',
      distance: '6.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: false,
      interests: ['yoga', 'art', 'travel'],
    ),
    NearbyUser(
      name: 'Finn',
      distance: '7.5 km',
      imageUrl: 'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: true,
      interests: ['photography', 'hiking'],
    ),
    NearbyUser(
      name: 'Cleo',
      distance: '9.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: false,
      interests: ['music', 'design', 'coffee'],
    ),
    NearbyUser(
      name: 'Oscar',
      distance: '12.0 km',
      imageUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['cooking', 'travel'],
    ),
    NearbyUser(
      name: 'Iris',
      distance: '15.3 km',
      imageUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=100&h=100&fit=crop',
      isNew: true,
      isOnline: false,
      interests: ['nature', 'reading', 'yoga'],
    ),
    NearbyUser(
      name: 'Ravi',
      distance: '20.0 km',
      imageUrl: 'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: true,
      interests: ['tech', 'beer', 'hiking'],
    ),
    NearbyUser(
      name: 'Lea',
      distance: '25.0 km',
      imageUrl: 'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=100&h=100&fit=crop',
      isNew: false,
      isOnline: false,
      interests: ['art', 'wine', 'travel'],
    ),
  ];

  // Map marker positions (relative to screen)
  static const mapMarkers = [
    {'name': 'Alex', 'x': 0.2, 'y': 0.3},
    {'name': 'Maya', 'x': 0.7, 'y': 0.25},
    {'name': 'Jordan', 'x': 0.3, 'y': 0.65},
    {'name': 'Sam', 'x': 0.8, 'y': 0.7},
  ];
}

// ─── Video feed demo data ───

class DemoVideo {
  final String creator;
  final String caption;
  final String musicTrack;
  final int likes;
  final int comments;
  final int shares;
  final String avatarUrl;

  const DemoVideo({
    required this.creator,
    required this.caption,
    required this.musicTrack,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.avatarUrl,
  });
}

// ─── Social feed demo data ───

enum DemoMediaType { image, video }

class DemoMediaItem {
  final String url;
  final DemoMediaType type;
  final double aspectRatio; // width / height (e.g. 16/9 = 1.78, 3/4 = 0.75)
  final String? durationLabel; // e.g. "0:32" for videos

  const DemoMediaItem({
    required this.url,
    this.type = DemoMediaType.image,
    this.aspectRatio = 4 / 3,
    this.durationLabel,
  });

  bool get isVideo => type == DemoMediaType.video;

  /// Clamp ratio to Instagram-style bounds: 4:5 portrait to 1.91:1 landscape
  double get clampedRatio => aspectRatio.clamp(0.8, 1.91);
}

class DemoPost {
  final String author;
  final String text;
  final List<DemoMediaItem> media;
  final int reactions;
  final int comments;
  final String timeAgo;
  final String avatarUrl;
  final String? repostAuthor;
  final String? repostText;
  final String? repostVideoCreator;
  final String? repostVideoCaption;
  final int? repostVideoIndex;
  final String contentType;

  const DemoPost({
    required this.author,
    required this.text,
    this.media = const [],
    required this.reactions,
    required this.comments,
    required this.timeAgo,
    required this.avatarUrl,
    this.repostAuthor,
    this.repostText,
    this.repostVideoCreator,
    this.repostVideoCaption,
    this.repostVideoIndex,
    this.contentType = 'Post',
  });
}

// ─── Marketplace demo data ───

class DemoProduct {
  final String title;
  final double price;
  final String seller;
  final String condition;
  final String imageUrl;

  const DemoProduct({
    required this.title,
    required this.price,
    required this.seller,
    required this.condition,
    required this.imageUrl,
  });
}

extension DemoDataExtended on DemoData {
  static const videos = [
    DemoVideo(
      creator: '@mayabeats',
      caption: 'New mix dropping this weekend 🎵 #djlife #electronic',
      musicTrack: 'Midnight — DJ Maya',
      likes: 12400,
      comments: 342,
      shares: 89,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@alexhikes',
      caption: 'Found the most insane viewpoint 🏔️',
      musicTrack: 'original sound — alexhikes',
      likes: 8700,
      comments: 156,
      shares: 234,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@samcooks',
      caption: 'Wait for it... 🍳 #cooking #foodie',
      musicTrack: 'Cooking Vibes — LoFi Kitchen',
      likes: 23100,
      comments: 891,
      shares: 1200,
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@lilyrunner',
      caption: 'Morning 5K in the rain hits different 🌧️ #fitness #running #motivation',
      musicTrack: 'Eye of the Tiger — Survivor',
      likes: 9800,
      comments: 213,
      shares: 178,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@devjosh',
      caption: 'Built this in a weekend. No frameworks. #coding #webdev #100daysofcode',
      musicTrack: 'Synthwave Beats — RetroWave',
      likes: 15200,
      comments: 487,
      shares: 612,
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@zoeart',
      caption: 'Fluid pour technique — watch the colours merge ✨ #art #acrylicpour',
      musicTrack: 'Clair de Lune — Debussy',
      likes: 31400,
      comments: 724,
      shares: 1890,
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@natgeo_kai',
      caption: 'This fox walked right up to the lens 🦊 #wildlife #nature #photography',
      musicTrack: 'original sound — natgeo_kai',
      likes: 67300,
      comments: 1420,
      shares: 4500,
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@djnova',
      caption: 'When the drop hits at 3AM 🔊 #djlife #nightlife #edm',
      musicTrack: 'Levels — Avicii (Nova Remix)',
      likes: 19600,
      comments: 356,
      shares: 890,
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@bakewithluna',
      caption: 'Sourdough day 14 — the crumb reveal 🍞 #sourdough #baking #breadtok',
      musicTrack: 'Butter — BTS',
      likes: 42100,
      comments: 1105,
      shares: 2340,
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@skatemax',
      caption: 'Finally landed the kickflip to 50-50 🛹 #skateboarding #skatelife',
      musicTrack: 'original sound — skatemax',
      likes: 7200,
      comments: 198,
      shares: 145,
      avatarUrl: 'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@travelnikki',
      caption: 'Sunrise in Cappadocia from a hot air balloon 🎈 #travel #turkey #bucketlist',
      musicTrack: 'Dreams — Fleetwood Mac',
      likes: 54800,
      comments: 2310,
      shares: 5670,
      avatarUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=100&h=100&fit=crop',
    ),
    DemoVideo(
      creator: '@comedydan',
      caption: 'POV: You explain your job to your parents for the 100th time 😂 #comedy #relatable',
      musicTrack: 'Funny Song — Cavendish Music',
      likes: 88900,
      comments: 3450,
      shares: 7800,
      avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=100&h=100&fit=crop',
    ),
  ];

  static const posts = [
    // 1. Video repost — shows as shared video with thumbnail + play overlay
    DemoPost(
      author: 'Alex',
      text: 'This recipe is insane, you have to try it',
      media: [
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=600&h=450&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 4 / 3,
          durationLabel: '1:24',
        ),
      ],
      reactions: 12,
      comments: 4,
      timeAgo: '15m ago',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
    ),

    // 2. Multiple landscape photos (carousel, all 4:3)
    DemoPost(
      author: 'Jordan Lee',
      text: 'Golden hour at the pier was absolutely unreal today. Sometimes you just have to stop and take it all in.',
      media: [
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=450&fit=crop', aspectRatio: 4 / 3),
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=600&h=450&fit=crop', aspectRatio: 4 / 3),
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=600&h=450&fit=crop', aspectRatio: 4 / 3),
      ],
      reactions: 47,
      comments: 12,
      timeAgo: '2h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
    ),

    // 3. Single portrait photo (3:4 ratio)
    DemoPost(
      author: 'Priya Sharma',
      text: 'New mural just went up on Brick Lane. Street art in this city never disappoints.',
      media: [
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=450&h=600&fit=crop', aspectRatio: 3 / 4),
      ],
      reactions: 63,
      comments: 9,
      timeAgo: '1h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
    ),

    // 4. Text-only (no media — existing)
    DemoPost(
      author: 'Riley Chen',
      text: 'Anyone else going to the food festival this weekend? Looking for recommendations!',
      reactions: 23,
      comments: 31,
      timeAgo: '4h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
    ),

    // 5. Single landscape video (16:9)
    DemoPost(
      author: 'Kai Nakamura',
      text: 'Caught this sunset time-lapse from the rooftop. 45 minutes in 30 seconds.',
      media: [
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=800&h=450&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 16 / 9,
          durationLabel: '0:32',
        ),
      ],
      reactions: 112,
      comments: 24,
      timeAgo: '3h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
    ),

    // 6. Text repost (existing)
    DemoPost(
      author: 'Maya Ali',
      text: 'This is such a vibe!',
      repostAuthor: 'Sam Torres',
      repostText: 'Just tried the new ramen place on 5th. The tonkotsu broth is life-changing.',
      reactions: 34,
      comments: 8,
      timeAgo: '5h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
    ),

    // 7. Single portrait video (9:16 — clamped to 4:5)
    DemoPost(
      author: 'Luna Park',
      text: 'POV: finding the perfect coffee spot on a rainy afternoon',
      media: [
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=450&h=600&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 9 / 16,
          durationLabel: '0:18',
        ),
      ],
      reactions: 78,
      comments: 15,
      timeAgo: '5h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
    ),

    // 8. Single landscape image (wide 16:9 — existing ramen post)
    DemoPost(
      author: 'Sam Torres',
      text: 'Just tried the new ramen place on 5th. The tonkotsu broth is life-changing.',
      media: [
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&h=450&fit=crop', aspectRatio: 16 / 9),
      ],
      reactions: 89,
      comments: 18,
      timeAgo: '6h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
    ),

    // 9. Mixed photos + videos in carousel
    DemoPost(
      author: 'Marco Davis',
      text: 'Weekend market haul — the ceramics stall had some unreal pieces this time.',
      media: [
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=600&h=450&fit=crop', aspectRatio: 4 / 3),
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=450&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 4 / 3,
          durationLabel: '0:14',
        ),
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=600&h=450&fit=crop', aspectRatio: 4 / 3),
      ],
      reactions: 56,
      comments: 7,
      timeAgo: '8h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
    ),

    // 10. Multiple videos carousel (all 16:9 landscape)
    DemoPost(
      author: 'Finn Hayes',
      text: 'Three angles of the same kickflip. Which one\'s the keeper?',
      media: [
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800&h=450&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 16 / 9,
          durationLabel: '0:08',
        ),
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=800&h=450&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 16 / 9,
          durationLabel: '0:06',
        ),
        DemoMediaItem(
          url: 'https://images.unsplash.com/photo-1621544402532-78c290378588?w=800&h=450&fit=crop',
          type: DemoMediaType.video,
          aspectRatio: 16 / 9,
          durationLabel: '0:11',
        ),
      ],
      reactions: 83,
      comments: 19,
      timeAgo: '9h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=100&h=100&fit=crop',
    ),

    // 11. Multiple portrait photos
    DemoPost(
      author: 'Zara Okonkwo',
      text: 'Finally got the film back from last month. Something about 35mm just hits different.',
      media: [
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=450&h=600&fit=crop', aspectRatio: 3 / 4),
        DemoMediaItem(url: 'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=450&h=600&fit=crop', aspectRatio: 3 / 4),
      ],
      reactions: 91,
      comments: 14,
      timeAgo: '10h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
    ),
  ];

  static const products = [
    DemoProduct(
      title: 'Vintage Polaroid Camera',
      price: 45.00,
      seller: 'Maya',
      condition: 'Good',
      imageUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=200&h=200&fit=crop',
    ),
    DemoProduct(
      title: 'Handmade Ceramic Mug',
      price: 18.50,
      seller: 'Jordan',
      condition: 'New',
      imageUrl: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=200&h=200&fit=crop',
    ),
    DemoProduct(
      title: 'Leather Weekend Bag',
      price: 89.00,
      seller: 'Alex',
      condition: 'Like New',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200&h=200&fit=crop',
    ),
    DemoProduct(
      title: 'Vinyl Record Collection',
      price: 120.00,
      seller: 'Sam',
      condition: 'Good',
      imageUrl: 'https://images.unsplash.com/photo-1539375665275-f9de415ef9ac?w=200&h=200&fit=crop',
    ),
  ];
}

/// ChatGPT/DALL-E prompts for generating custom profile photos
/// Use these if you want AI-generated images instead of stock photos
class ImagePrompts {
  static const prompts = [
    // Female profiles
    '''
    Portrait photo of a stylish 24-year-old woman with natural makeup,
    warm smile, casual urban clothing, soft natural lighting,
    shallow depth of field, professional quality, candid feel
    ''',
    '''
    Portrait of a 28-year-old woman at a coffee shop,
    holding a latte, cozy sweater, genuine laugh,
    warm afternoon light through window, lifestyle photography
    ''',
    // Male profiles
    '''
    Portrait photo of a 27-year-old man in a casual button-up shirt,
    confident smile, outdoor setting with blurred city background,
    golden hour lighting, professional headshot quality
    ''',
    '''
    Candid portrait of a 31-year-old man cooking in a modern kitchen,
    chef's apron, genuine expression, natural lighting,
    lifestyle photography, warm tones
    ''',
    // Non-binary/diverse
    '''
    Portrait of a 26-year-old person with creative style,
    colorful clothing, artistic background, confident pose,
    studio lighting with colorful accents, modern aesthetic
    ''',
  ];

  static const styleGuide = '''
  For dating app photos, generate images that are:
  - Authentic and natural (not overly posed)
  - Well-lit (natural light preferred)
  - Showing personality through clothing/setting
  - High quality but not obviously AI-generated
  - Diverse in ethnicity, style, and body type
  - Appropriate for a dating app (no explicit content)

  Avoid:
  - Perfect symmetry (looks uncanny)
  - Over-filtered skin
  - Generic stock photo poses
  - Obvious AI artifacts (extra fingers, weird backgrounds)
  ''';
}
