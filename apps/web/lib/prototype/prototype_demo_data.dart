/// Extended demo data for prototype screens beyond the existing demo_data.dart

// ─── V2 YoYo enums ──────────────────────────────────────────────────

enum EncounterType { passby, nearby }
enum ConsentStatus { pending, shared, declined, expired }
enum RelationshipType { stranger, friend, partner, family }
enum DistanceCategory { veryNear, nearby, passing }
enum VisibilityTier { public, friendsOnly, familyOnly, private }

// ─── V2 YoYo models ─────────────────────────────────────────────────

class DemoV2Encounter {
  final String name;
  final String imageUrl;
  final List<String> interests;
  final EncounterType encounterType;
  final ConsentStatus consentStatus;
  final RelationshipType relationship;
  final DistanceCategory distanceCategory;
  final String? ageRange;
  final bool isOnline;
  final String encounterTime;
  const DemoV2Encounter({
    required this.name,
    required this.imageUrl,
    required this.interests,
    required this.encounterType,
    required this.consentStatus,
    required this.relationship,
    required this.distanceCategory,
    this.ageRange,
    this.isOnline = false,
    required this.encounterTime,
  });
}

class DemoV2Wave {
  final String name;
  final String imageUrl;
  final String timeAgo;
  final bool isIncoming;
  final EncounterType encounterType;
  final ConsentStatus consentStatus;
  const DemoV2Wave({
    required this.name,
    required this.imageUrl,
    required this.timeAgo,
    required this.isIncoming,
    required this.encounterType,
    required this.consentStatus,
  });
}

class DemoV2Connection {
  final String name;
  final String imageUrl;
  final String timeAgo;
  final bool isIncoming;
  final EncounterType howMet;
  final List<String> mutualInterests;
  const DemoV2Connection({
    required this.name,
    required this.imageUrl,
    required this.timeAgo,
    required this.isIncoming,
    required this.howMet,
    required this.mutualInterests,
  });
}

// ─── Inner Circle models ─────────────────────────────────────────────

class DemoLocationPing {
  final String time;
  final String? placeName;
  final double x; // 0.0 - 1.0 relative position on map placeholder
  final double y;
  const DemoLocationPing({required this.time, this.placeName, required this.x, required this.y});
}

class DemoFamilyMember {
  final String name;
  final String imageUrl;
  final String relationship;
  final String currentPlace;
  final String lastUpdate;
  final bool isOnline;
  final List<DemoLocationPing> pings;
  const DemoFamilyMember({
    required this.name,
    required this.imageUrl,
    required this.relationship,
    required this.currentPlace,
    required this.lastUpdate,
    required this.isOnline,
    required this.pings,
  });
}

class DemoCirclePing {
  final String message;
  final String timeAgo;
  final bool isIncoming;
  final String senderName;
  final String senderImage;
  const DemoCirclePing({required this.message, required this.timeAgo, required this.isIncoming, required this.senderName, required this.senderImage});
}

// ─── Existing models ─────────────────────────────────────────────────

class DemoComment {
  final String author;
  final String text;
  final int likes;
  final String timeAgo;
  final String avatarUrl;
  const DemoComment({required this.author, required this.text, required this.likes, required this.timeAgo, required this.avatarUrl});
}

class DemoMatch {
  final String name;
  final String imageUrl;
  final String? lastMessage;
  final String timeAgo;
  final bool isNew;
  const DemoMatch({required this.name, required this.imageUrl, this.lastMessage, required this.timeAgo, required this.isNew});
}

class DemoConversation {
  final String name;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;
  final String moduleContext;
  final String avatarUrl;
  const DemoConversation({required this.name, required this.lastMessage, required this.timeAgo, required this.unreadCount, required this.moduleContext, required this.avatarUrl});
}

class DemoMessage {
  final String text;
  final String timeAgo;
  final bool isMine;
  const DemoMessage({required this.text, required this.timeAgo, required this.isMine});
}

class DemoEvent {
  final String title;
  final String date;
  final String time;
  final String location;
  final String imageUrl;
  final int goingCount;
  final String distance;
  final String description;
  final String hostName;
  final String hostAvatarUrl;
  final String? cost;
  final String? ticketUrl;
  final List<String> attendeeAvatars;
  final double latitude;
  final double longitude;
  final String category;
  final bool isPromoted;
  const DemoEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.goingCount,
    required this.distance,
    this.description = '',
    this.hostName = 'Organiser',
    this.hostAvatarUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
    this.cost,
    this.ticketUrl,
    this.attendeeAvatars = const [],
    this.latitude = 51.5074,
    this.longitude = -0.1278,
    this.category = 'Meetup',
    this.isPromoted = false,
  });
}

class DemoBid {
  final String bidder;
  final double amount;
  final String timeAgo;
  const DemoBid({required this.bidder, required this.amount, required this.timeAgo});
}

class DemoInterest {
  final String name;
  final bool isSelected;
  const DemoInterest({required this.name, this.isSelected = false});
}

class DemoStory {
  final String author;
  final String avatarUrl;
  final bool isLive;
  final int segmentCount;
  const DemoStory({required this.author, required this.avatarUrl, required this.isLive, required this.segmentCount});
}

class ProtoDemoData {
  static const currentUserAvatar = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop';

  static const comments = [
    DemoComment(author: 'Maya', text: 'This is incredible!', likes: 42, timeAgo: '2m', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'),
    DemoComment(author: 'Jordan', text: 'Love the vibe', likes: 18, timeAgo: '5m', avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop'),
    DemoComment(author: 'Sam', text: 'Where is this? Need to visit', likes: 7, timeAgo: '12m', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop'),
    DemoComment(author: 'Riley', text: 'Following for more!', likes: 3, timeAgo: '15m', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop'),
    DemoComment(author: 'Alex', text: 'The lighting is perfect', likes: 29, timeAgo: '20m', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
  ];

  static const matches = [
    DemoMatch(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', timeAgo: 'Just now', isNew: true),
    DemoMatch(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', lastMessage: 'Hey! How are you?', timeAgo: '2h', isNew: false),
    DemoMatch(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', lastMessage: 'That sounds great!', timeAgo: '1d', isNew: false),
  ];

  static const conversations = [
    DemoConversation(name: 'Maya', lastMessage: 'See you there!', timeAgo: '5m', unreadCount: 2, moduleContext: 'Dating', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Alex', lastMessage: 'Is the camera still available?', timeAgo: '1h', unreadCount: 1, moduleContext: 'Market', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Sam', lastMessage: 'Great recipe, thanks!', timeAgo: '3h', unreadCount: 0, moduleContext: 'Social', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Riley', lastMessage: 'Friday works for me', timeAgo: '1d', unreadCount: 0, moduleContext: 'YoYo', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Jordan', lastMessage: 'Cool shot!', timeAgo: '2d', unreadCount: 0, moduleContext: 'Video', avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop'),
  ];

  static const messages = [
    DemoMessage(text: 'Hey! Loved your latest video', timeAgo: '10:30 AM', isMine: false),
    DemoMessage(text: 'Thanks! Took ages to edit', timeAgo: '10:32 AM', isMine: true),
    DemoMessage(text: 'The transition at 0:15 was so smooth', timeAgo: '10:33 AM', isMine: false),
    DemoMessage(text: 'I used a new plugin for that!', timeAgo: '10:35 AM', isMine: true),
    DemoMessage(text: 'What plugin? I need it', timeAgo: '10:36 AM', isMine: false),
    DemoMessage(text: 'See you there!', timeAgo: '10:40 AM', isMine: true),
  ];

  static const events = [
    DemoEvent(
      title: 'Street Food Festival',
      date: 'Sat, 8 Mar',
      time: '12:00 PM',
      location: 'Brick Lane, Shoreditch',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=200&fit=crop',
      goingCount: 234,
      distance: '0.8 km',
      description: 'Sample cuisines from over 40 street food vendors across East London. Live music, craft drinks, and family-friendly activities all afternoon.',
      hostName: 'East London Eats',
      hostAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
      attendeeAvatars: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
      ],
      latitude: 51.5215,
      longitude: -0.0715,
      category: 'Food',
    ),
    DemoEvent(
      title: 'Open Mic Night',
      date: 'Fri, 7 Mar',
      time: '8:00 PM',
      location: 'The Jazz Cafe, Camden',
      imageUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=200&fit=crop',
      goingCount: 89,
      distance: '1.2 km',
      description: 'Bring your instrument or just your voice. Sign-up sheet opens at 7 PM. All genres welcome — jazz, folk, spoken word, comedy.',
      hostName: 'Camden Sounds',
      hostAvatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
      cost: '£5',
      attendeeAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      ],
      latitude: 51.5392,
      longitude: -0.1426,
      category: 'Music',
    ),
    DemoEvent(
      title: 'Art Exhibition: New Perspectives',
      date: 'Sun, 9 Mar',
      time: '10:00 AM',
      location: 'Tate Modern, Bankside',
      imageUrl: 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=400&h=200&fit=crop',
      goingCount: 512,
      distance: '2.1 km',
      description: 'A curated showcase of emerging British artists exploring identity, place and digital culture. Guided tours at 11 AM and 2 PM.',
      hostName: 'Tate Modern',
      hostAvatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop',
      cost: '£15',
      ticketUrl: 'https://tate.org.uk/tickets',
      attendeeAvatars: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1463453091185-61582044d556?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop',
      ],
      latitude: 51.5076,
      longitude: -0.0994,
      category: 'Art',
      isPromoted: true,
    ),
    DemoEvent(
      title: 'Saturday Morning 5K Run',
      date: 'Sat, 8 Mar',
      time: '8:00 AM',
      location: 'Victoria Park, Hackney',
      imageUrl: 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=400&h=200&fit=crop',
      goingCount: 67,
      distance: '1.5 km',
      description: 'Weekly community run for all levels. Meet at the bandstand. Warm-up at 7:45, run starts at 8 sharp. Coffee after!',
      hostName: 'Hackney Runners',
      hostAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
      attendeeAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
      ],
      latitude: 51.5363,
      longitude: -0.0421,
      category: 'Sports',
    ),
    DemoEvent(
      title: 'Rooftop DJ Set & Cocktails',
      date: 'Fri, 14 Mar',
      time: '9:00 PM',
      location: 'Skyline Bar, Shoreditch',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=200&fit=crop',
      goingCount: 156,
      distance: '0.5 km',
      description: 'House and disco from resident DJs. Two-for-one cocktails before 10 PM. Dress code: smart casual. Over 21s only.',
      hostName: 'Skyline Events',
      hostAvatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=100&h=100&fit=crop',
      cost: 'From £20',
      ticketUrl: 'https://skylinebar.co.uk/events',
      attendeeAvatars: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&h=100&fit=crop',
      ],
      latitude: 51.5233,
      longitude: -0.0774,
      category: 'Nightlife',
      isPromoted: true,
    ),
    DemoEvent(
      title: 'Tech Founders Meetup',
      date: 'Wed, 12 Mar',
      time: '6:30 PM',
      location: 'WeWork, Moorgate',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400&h=200&fit=crop',
      goingCount: 43,
      distance: '3.0 km',
      description: 'Monthly networking for early-stage founders. Lightning talks, Q&A panel, and pizza. This month: "Finding product-market fit in 2026".',
      hostName: 'London Startup Club',
      hostAvatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&h=100&fit=crop',
      attendeeAvatars: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
        'https://images.unsplash.com/photo-1463453091185-61582044d556?w=100&h=100&fit=crop',
      ],
      latitude: 51.5180,
      longitude: -0.0886,
      category: 'Meetup',
    ),
  ];

  static const bids = [
    DemoBid(bidder: 'Alex', amount: 95.00, timeAgo: '2m ago'),
    DemoBid(bidder: 'Maya', amount: 85.00, timeAgo: '15m ago'),
    DemoBid(bidder: 'Sam', amount: 75.00, timeAgo: '1h ago'),
    DemoBid(bidder: 'Jordan', amount: 65.00, timeAgo: '3h ago'),
  ];

  static const interests = [
    DemoInterest(name: 'Music', isSelected: true),
    DemoInterest(name: 'Travel', isSelected: true),
    DemoInterest(name: 'Photography', isSelected: true),
    DemoInterest(name: 'Cooking'),
    DemoInterest(name: 'Fitness'),
    DemoInterest(name: 'Gaming'),
    DemoInterest(name: 'Art'),
    DemoInterest(name: 'Reading'),
    DemoInterest(name: 'Coffee'),
    DemoInterest(name: 'Movies'),
    DemoInterest(name: 'Nature'),
    DemoInterest(name: 'Tech'),
    DemoInterest(name: 'Fashion'),
    DemoInterest(name: 'Dogs'),
    DemoInterest(name: 'Yoga'),
    DemoInterest(name: 'Nightlife'),
  ];

  // ─── Inner Circle demo data ──────────────────────────────────────

  static const familyMembers = [
    DemoFamilyMember(
      name: 'Emma',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
      relationship: 'Daughter',
      currentPlace: 'Oakfield School',
      lastUpdate: '3m ago',
      isOnline: true,
      pings: [
        DemoLocationPing(time: '8:00 AM', placeName: 'Home', x: 0.3, y: 0.7),
        DemoLocationPing(time: '8:45 AM', placeName: 'School', x: 0.7, y: 0.3),
        DemoLocationPing(time: '3:15 PM', placeName: 'Park', x: 0.5, y: 0.5),
        DemoLocationPing(time: '4:00 PM', placeName: 'Home', x: 0.3, y: 0.7),
      ],
    ),
    DemoFamilyMember(
      name: 'Jake',
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
      relationship: 'Son',
      currentPlace: 'Home',
      lastUpdate: '12m ago',
      isOnline: true,
      pings: [
        DemoLocationPing(time: '8:00 AM', placeName: 'Home', x: 0.3, y: 0.7),
        DemoLocationPing(time: '10:00 AM', placeName: "Friend's house", x: 0.8, y: 0.6),
        DemoLocationPing(time: '1:00 PM', placeName: 'Home', x: 0.3, y: 0.7),
      ],
    ),
    DemoFamilyMember(
      name: 'Sarah',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      relationship: 'Partner',
      currentPlace: 'Office',
      lastUpdate: '1m ago',
      isOnline: true,
      pings: [
        DemoLocationPing(time: '7:30 AM', placeName: 'Home', x: 0.3, y: 0.7),
        DemoLocationPing(time: '8:30 AM', placeName: 'Office', x: 0.2, y: 0.2),
        DemoLocationPing(time: '12:15 PM', placeName: 'Lunch spot', x: 0.4, y: 0.35),
        DemoLocationPing(time: '1:00 PM', placeName: 'Office', x: 0.2, y: 0.2),
      ],
    ),
  ];

  static const circlePings = [
    DemoCirclePing(message: "I'm at school!", timeAgo: '3m ago', isIncoming: true, senderName: 'Emma', senderImage: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop'),
    DemoCirclePing(message: 'Coming home soon', timeAgo: '12m ago', isIncoming: true, senderName: 'Jake', senderImage: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop'),
    DemoCirclePing(message: 'Heading to lunch', timeAgo: '25m ago', isIncoming: true, senderName: 'Sarah', senderImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop'),
    DemoCirclePing(message: "I'm here", timeAgo: '1h ago', isIncoming: false, senderName: 'You', senderImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
  ];

  static const familyConversations = [
    DemoConversation(name: 'Emma', lastMessage: 'Can you pick me up at 4?', timeAgo: '3m', unreadCount: 1, moduleContext: 'Family', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Sarah', lastMessage: 'Dinner at 7 tonight?', timeAgo: '25m', unreadCount: 0, moduleContext: 'Family', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Jake', lastMessage: "I'm home now", timeAgo: '1h', unreadCount: 0, moduleContext: 'Family', avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop'),
    DemoConversation(name: 'Family Group', lastMessage: 'Sarah: Weekend plans?', timeAgo: '2h', unreadCount: 3, moduleContext: 'Family', avatarUrl: 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=100&h=100&fit=crop'),
  ];

  // ─── V2 YoYo demo data ────────────────────────────────────────────

  static const v2Encounters = [
    // 3 nearby (dwell)
    DemoV2Encounter(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', interests: ['music', 'coffee', 'yoga'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.friend, distanceCategory: DistanceCategory.veryNear, ageRange: '25-30', isOnline: true, encounterTime: '2m ago'),
    DemoV2Encounter(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', interests: ['tech', 'photography'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.nearby, ageRange: '28-35', isOnline: true, encounterTime: '5m ago'),
    DemoV2Encounter(name: 'Sam', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', interests: ['cooking', 'travel', 'nature'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.pending, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.veryNear, encounterTime: '8m ago'),
    // 4 pass-by (brief)
    DemoV2Encounter(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', interests: ['art', 'reading'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.pending, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.passing, ageRange: '22-28', encounterTime: '12m ago'),
    DemoV2Encounter(name: 'Alex', imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop', interests: ['music', 'tech', 'coffee'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.declined, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.passing, encounterTime: '20m ago'),
    DemoV2Encounter(name: 'Charlie', imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop', interests: ['hiking', 'photography'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.expired, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.nearby, encounterTime: '45m ago'),
    DemoV2Encounter(name: 'Ava', imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop', interests: ['yoga', 'nature', 'art'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.declined, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.passing, ageRange: '30-35', encounterTime: '1h ago'),
    // 3 friends/partner
    DemoV2Encounter(name: 'Kai', imageUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=100&h=100&fit=crop', interests: ['coffee', 'music', 'travel'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.partner, distanceCategory: DistanceCategory.veryNear, isOnline: true, encounterTime: '1m ago'),
    DemoV2Encounter(name: 'Taylor', imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop', interests: ['design', 'cooking'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.friend, distanceCategory: DistanceCategory.nearby, isOnline: true, encounterTime: '10m ago'),
    DemoV2Encounter(name: 'Luca', imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&h=100&fit=crop', interests: ['tech', 'reading', 'coffee'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.expired, relationship: RelationshipType.family, distanceCategory: DistanceCategory.passing, encounterTime: '2h ago'),
  ];

  static const v2Waves = [
    DemoV2Wave(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', timeAgo: '2m ago', isIncoming: true, encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared),
    DemoV2Wave(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', timeAgo: '15m ago', isIncoming: false, encounterType: EncounterType.passby, consentStatus: ConsentStatus.pending),
    DemoV2Wave(name: 'Sam', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', timeAgo: '1h ago', isIncoming: true, encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared),
    DemoV2Wave(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', timeAgo: '3h ago', isIncoming: false, encounterType: EncounterType.passby, consentStatus: ConsentStatus.expired),
  ];

  static const v2Connections = [
    DemoV2Connection(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', timeAgo: '5m ago', isIncoming: true, howMet: EncounterType.nearby, mutualInterests: ['music', 'coffee']),
    DemoV2Connection(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', timeAgo: '1h ago', isIncoming: false, howMet: EncounterType.passby, mutualInterests: ['tech']),
    DemoV2Connection(name: 'Sam', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', timeAgo: '3h ago', isIncoming: true, howMet: EncounterType.nearby, mutualInterests: ['cooking', 'travel', 'nature']),
    DemoV2Connection(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', timeAgo: '1d ago', isIncoming: false, howMet: EncounterType.passby, mutualInterests: ['art']),
  ];

  static const stories = [
    DemoStory(author: 'Your Story', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop', isLive: false, segmentCount: 0),
    DemoStory(author: 'Maya', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', isLive: true, segmentCount: 3),
    DemoStory(author: 'Jordan', avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', isLive: false, segmentCount: 5),
    DemoStory(author: 'Sam', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', isLive: false, segmentCount: 2),
    DemoStory(author: 'Riley', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', isLive: false, segmentCount: 4),
  ];
}
