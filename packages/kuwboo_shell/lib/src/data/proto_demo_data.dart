/// Extended demo data for prototype screens beyond the existing demo_data.dart

// ─── YoYo enums ─────────────────────────────────────────────────────

enum EncounterType { passby, nearby }
enum ConsentStatus { pending, shared, declined, expired }
enum RelationshipType { stranger, friend, partner, family }
enum DistanceCategory { veryNear, nearby, passing }
enum VisibilityTier { public, friendsOnly, familyOnly, private }

// ─── YoYo models ────────────────────────────────────────────────────

class DemoEncounter {
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
  const DemoEncounter({
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

class DemoWave {
  final String name;
  final String imageUrl;
  final String timeAgo;
  final bool isIncoming;
  final EncounterType encounterType;
  final ConsentStatus consentStatus;
  const DemoWave({
    required this.name,
    required this.imageUrl,
    required this.timeAgo,
    required this.isIncoming,
    required this.encounterType,
    required this.consentStatus,
  });
}

class DemoConnection {
  final String name;
  final String imageUrl;
  final String timeAgo;
  final bool isIncoming;
  final EncounterType howMet;
  final List<String> mutualInterests;
  const DemoConnection({
    required this.name,
    required this.imageUrl,
    required this.timeAgo,
    required this.isIncoming,
    required this.howMet,
    required this.mutualInterests,
  });
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
  const DemoEvent({required this.title, required this.date, required this.time, required this.location, required this.imageUrl, required this.goingCount, required this.distance});
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
    DemoEvent(title: 'Street Food Festival', date: 'Sat, Mar 8', time: '12:00 PM', location: 'Brick Lane', imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=200&fit=crop', goingCount: 234, distance: '0.8 km'),
    DemoEvent(title: 'Open Mic Night', date: 'Fri, Mar 7', time: '8:00 PM', location: 'The Jazz Cafe', imageUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=200&fit=crop', goingCount: 89, distance: '1.2 km'),
    DemoEvent(title: 'Art Exhibition', date: 'Sun, Mar 9', time: '10:00 AM', location: 'Tate Modern', imageUrl: 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=400&h=200&fit=crop', goingCount: 512, distance: '2.1 km'),
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

  // ─── YoYo demo data ───────────────────────────────────────────────

  static const encounters = [
    // 3 nearby (dwell)
    DemoEncounter(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', interests: ['music', 'coffee', 'yoga'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.friend, distanceCategory: DistanceCategory.veryNear, ageRange: '25-30', isOnline: true, encounterTime: '2m ago'),
    DemoEncounter(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', interests: ['tech', 'photography'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.nearby, ageRange: '28-35', isOnline: true, encounterTime: '5m ago'),
    DemoEncounter(name: 'Sam', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', interests: ['cooking', 'travel', 'nature'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.pending, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.veryNear, encounterTime: '8m ago'),
    // 4 pass-by (brief)
    DemoEncounter(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', interests: ['art', 'reading'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.pending, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.passing, ageRange: '22-28', encounterTime: '12m ago'),
    DemoEncounter(name: 'Alex', imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop', interests: ['music', 'tech', 'coffee'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.declined, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.passing, encounterTime: '20m ago'),
    DemoEncounter(name: 'Charlie', imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop', interests: ['hiking', 'photography'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.expired, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.nearby, encounterTime: '45m ago'),
    DemoEncounter(name: 'Ava', imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop', interests: ['yoga', 'nature', 'art'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.declined, relationship: RelationshipType.stranger, distanceCategory: DistanceCategory.passing, ageRange: '30-35', encounterTime: '1h ago'),
    // 3 friends/partner
    DemoEncounter(name: 'Kai', imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=100&h=100&fit=crop', interests: ['coffee', 'music', 'travel'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.partner, distanceCategory: DistanceCategory.veryNear, isOnline: true, encounterTime: '1m ago'),
    DemoEncounter(name: 'Taylor', imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop', interests: ['design', 'cooking'], encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared, relationship: RelationshipType.friend, distanceCategory: DistanceCategory.nearby, isOnline: true, encounterTime: '10m ago'),
    DemoEncounter(name: 'Luca', imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&h=100&fit=crop', interests: ['tech', 'reading', 'coffee'], encounterType: EncounterType.passby, consentStatus: ConsentStatus.expired, relationship: RelationshipType.family, distanceCategory: DistanceCategory.passing, encounterTime: '2h ago'),
  ];

  static const waves = [
    DemoWave(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', timeAgo: '2m ago', isIncoming: true, encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared),
    DemoWave(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', timeAgo: '15m ago', isIncoming: false, encounterType: EncounterType.passby, consentStatus: ConsentStatus.pending),
    DemoWave(name: 'Sam', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', timeAgo: '1h ago', isIncoming: true, encounterType: EncounterType.nearby, consentStatus: ConsentStatus.shared),
    DemoWave(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', timeAgo: '3h ago', isIncoming: false, encounterType: EncounterType.passby, consentStatus: ConsentStatus.expired),
  ];

  static const connections = [
    DemoConnection(name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', timeAgo: '5m ago', isIncoming: true, howMet: EncounterType.nearby, mutualInterests: ['music', 'coffee']),
    DemoConnection(name: 'Jordan', imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', timeAgo: '1h ago', isIncoming: false, howMet: EncounterType.passby, mutualInterests: ['tech']),
    DemoConnection(name: 'Sam', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', timeAgo: '3h ago', isIncoming: true, howMet: EncounterType.nearby, mutualInterests: ['cooking', 'travel', 'nature']),
    DemoConnection(name: 'Riley', imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', timeAgo: '1d ago', isIncoming: false, howMet: EncounterType.passby, mutualInterests: ['art']),
  ];

  static const stories = [
    DemoStory(author: 'Your Story', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop', isLive: false, segmentCount: 0),
    DemoStory(author: 'Maya', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', isLive: true, segmentCount: 3),
    DemoStory(author: 'Jordan', avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop', isLive: false, segmentCount: 5),
    DemoStory(author: 'Sam', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', isLive: false, segmentCount: 2),
    DemoStory(author: 'Riley', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', isLive: false, segmentCount: 4),
  ];
}
