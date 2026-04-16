class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final MessageStatus status;
  final List<MessageReaction> reactions;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSenderName;
  final DateTime createdAt;
  final bool isDeleted;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.text,
    this.imageUrl,
    this.status = MessageStatus.sent,
    this.reactions = const [],
    this.replyToId,
    this.replyToText,
    this.replyToSenderName,
    required this.createdAt,
    this.isDeleted = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
      status: MessageStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      reactions: (json['reactions'] as List<dynamic>? ?? [])
          .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
          .toList(),
      replyToId: json['reply_to_id'] as String?,
      replyToText: json['reply_to_text'] as String?,
      replyToSenderName: json['reply_to_sender_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDeleted: (json['is_deleted'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'text': text,
        'image_url': imageUrl,
        'status': status.name,
        'reactions': reactions.map((r) => r.toJson()).toList(),
        'reply_to_id': replyToId,
        'reply_to_text': replyToText,
        'reply_to_sender_name': replyToSenderName,
        'created_at': createdAt.toIso8601String(),
        'is_deleted': isDeleted,
      };

  ChatMessage copyWith({
    String? text,
    String? imageUrl,
    MessageStatus? status,
    List<MessageReaction>? reactions,
    bool? isDeleted,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToSenderName: replyToSenderName,
      createdAt: createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageReaction {
  final String userId;
  final String emoji;

  const MessageReaction({required this.userId, required this.emoji});

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      MessageReaction(
        userId: json['user_id'] as String,
        emoji: json['emoji'] as String,
      );

  Map<String, dynamic> toJson() => {'user_id': userId, 'emoji': emoji};
}

class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessageText;

  const Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageText,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        user1Id: json['user1_id'] as String,
        user2Id: json['user2_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'] as String)
            : null,
        lastMessageText: json['last_message_text'] as String?,
      );
}
