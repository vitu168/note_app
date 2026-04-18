class ChatMessengerMessage {
  final int id;
  final int conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMessengerMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessengerMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessengerMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      conversationId: (json['conversationId'] as num?)?.toInt() ?? 0,
      senderId: (json['senderId'] ?? '').toString().trim(),
      receiverId: (json['receiverId'] ?? '').toString().trim(),
      content: (json['content'] ?? '').toString(),
      messageType: (json['messageType'] ?? 'TextChat').toString(),
      isRead: (json['isRead'] as bool?) ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  ChatMessengerMessage copyWith({bool? isRead, String? content}) {
    return ChatMessengerMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: content ?? this.content,
      messageType: messageType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}

class ChatMessengerResponse {
  final List<ChatMessengerMessage> items;
  final int totalCount;

  const ChatMessengerResponse({required this.items, required this.totalCount});

  factory ChatMessengerResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ChatMessengerResponse(
      items: rawItems
          .map((e) => ChatMessengerMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? rawItems.length,
    );
  }
}

class UnreadCountResponse {
  final String receiverId;
  final int unreadCount;

  const UnreadCountResponse({required this.receiverId, required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      receiverId: (json['receiverId'] ?? '').toString(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
