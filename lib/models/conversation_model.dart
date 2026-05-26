import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, dynamic> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id, {String? currentUid}) {
    // unreadCount is stored as a Map<String, int> in Firestore {userId: count}
    int unreadCount = 0;
    final unreadData = map['unreadCount'];
    if (unreadData is Map && currentUid != null) {
      unreadCount = (unreadData[currentUid] ?? 0) as int;
    }

    return ConversationModel(
      id: id,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participants: Map<String, dynamic>.from(map['participants'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime:
      (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> otherParticipant(String currentUid) {
    final otherId = participantIds.firstWhere(
          (id) => id != currentUid,
      orElse: () => '',
    );

    // If no otherId, return Unknown
    if (otherId.isEmpty) {
      return {'name': 'Unknown', 'profilePic': null};
    }

    // If participants map is empty or key is missing, return Unknown
    final otherData = participants[otherId];
    if (otherData == null) {
      return {'name': 'Unknown', 'profilePic': null};
    }

    return Map<String, dynamic>.from(otherData);
  }
}