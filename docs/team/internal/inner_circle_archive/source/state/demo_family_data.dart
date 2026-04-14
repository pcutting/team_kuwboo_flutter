// Archived Inner Circle demo data — extracted from
// packages/kuwboo_shell/lib/src/data/proto_demo_data.dart
// before removal on 2026-04-14.
//
// To restore: paste these classes back into proto_demo_data.dart (alongside
// the other Demo* classes) and re-add the static lists under the
// `ProtoDemoData` class where the V2 encounters are.

// ─── Inner Circle models ─────────────────────────────────────────────

class DemoLocationPing {
  final String time;
  final String? placeName;
  final double x; // 0.0 - 1.0 relative position on map placeholder
  final double y;
  const DemoLocationPing({
    required this.time,
    this.placeName,
    required this.x,
    required this.y,
  });
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
  const DemoCirclePing({
    required this.message,
    required this.timeAgo,
    required this.isIncoming,
    required this.senderName,
    required this.senderImage,
  });
}

// ─── Seed lists (live on ProtoDemoData as static const) ──────────────

const familyMembers = [
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

const circlePings = [
  DemoCirclePing(message: "I'm at school!", timeAgo: '3m ago', isIncoming: true, senderName: 'Emma', senderImage: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop'),
  DemoCirclePing(message: 'Coming home soon', timeAgo: '12m ago', isIncoming: true, senderName: 'Jake', senderImage: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop'),
  DemoCirclePing(message: 'Heading to lunch', timeAgo: '25m ago', isIncoming: true, senderName: 'Sarah', senderImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop'),
  DemoCirclePing(message: "I'm here", timeAgo: '1h ago', isIncoming: false, senderName: 'You', senderImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
];

// familyConversations — these use DemoConversation from the non-IC part of
// proto_demo_data.dart, so they do NOT move with the archive. The original
// list is:
//
//   DemoConversation(name: 'Emma', lastMessage: 'Can you pick me up at 4?', timeAgo: '3m', unreadCount: 1, moduleContext: 'Family', avatarUrl: '...'),
//   DemoConversation(name: 'Sarah', lastMessage: 'Dinner at 7 tonight?', timeAgo: '25m', unreadCount: 0, moduleContext: 'Family', avatarUrl: '...'),
//   DemoConversation(name: 'Jake', lastMessage: "I'm home now", timeAgo: '1h', unreadCount: 0, moduleContext: 'Family', avatarUrl: '...'),
//   DemoConversation(name: 'Family Group', lastMessage: 'Sarah: Weekend plans?', timeAgo: '2h', unreadCount: 3, moduleContext: 'Family', avatarUrl: '...'),
//
// Re-add these to `ProtoDemoData.familyConversations` when restoring.
