import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note_app/core/models/chat_message.dart';

class ChatService {
  ChatService._();

  static final _db = Supabase.instance.client;

  static String _generateId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}'
        '-${hex(bytes[4])}${hex(bytes[5])}'
        '-${hex(bytes[6])}${hex(bytes[7])}'
        '-${hex(bytes[8])}${hex(bytes[9])}'
        '-${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }

  // ── Conversations ────────────────────────────────────────────────────────

  /// Gets or creates a conversation between two users. Returns the conversation id.
  static Future<String> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    // Look for existing conversation (either direction)
    final existing = await _db
        .from('conversations')
        .select('id')
        .or('and(user1_id.eq.$currentUserId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$currentUserId)')
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // Create new conversation
    final id = _generateId();
    await _db.from('conversations').insert({
      'id': id,
      'user1_id': currentUserId,
      'user2_id': otherUserId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return id;
  }

  // ── Messages ─────────────────────────────────────────────────────────────

  /// Loads recent messages for a conversation (newest first).
  static Future<List<ChatMessage>> loadMessages(
    String conversationId, {
    int limit = 50,
    String? beforeId,
  }) async {
    var query = _db
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(limit);

    final rows = await query;
    return rows
        .map((r) => ChatMessage.fromJson(r))
        .toList();
  }

  /// Sends a text message.
  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String? replyToId,
    String? replyToText,
    String? replyToSenderName,
  }) async {
    final id = _generateId();
    final now = DateTime.now().toUtc();
    final payload = {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'text': text,
      'status': 'sent',
      'reactions': [],
      'reply_to_id': replyToId,
      'reply_to_text': replyToText,
      'reply_to_sender_name': replyToSenderName,
      'created_at': now.toIso8601String(),
      'is_deleted': false,
    };
    final row = await _db.from('messages').insert(payload).select().single();
    return ChatMessage.fromJson(row);
  }

  /// Adds or removes a reaction on a message.
  static Future<void> toggleReaction({
    required String messageId,
    required String conversationId,
    required String userId,
    required String emoji,
    required List<MessageReaction> currentReactions,
  }) async {
    final existing = currentReactions.indexWhere(
      (r) => r.userId == userId && r.emoji == emoji,
    );
    final updated = List<MessageReaction>.from(currentReactions);
    if (existing >= 0) {
      updated.removeAt(existing);
    } else {
      // Remove any other reaction by same user first
      updated.removeWhere((r) => r.userId == userId);
      updated.add(MessageReaction(userId: userId, emoji: emoji));
    }
    await _db.from('messages').update({
      'reactions': updated.map((r) => r.toJson()).toList(),
    }).eq('id', messageId);
  }

  /// Soft-deletes a message.
  static Future<void> deleteMessage(String messageId) async {
    await _db.from('messages').update({
      'is_deleted': true,
      'text': null,
    }).eq('id', messageId);
  }

  /// Marks messages as read by current user.
  static Future<void> markRead(
    String conversationId,
    String currentUserId,
  ) async {
    await _db
        .from('messages')
        .update({'status': 'read'})
        .eq('conversation_id', conversationId)
        .neq('sender_id', currentUserId)
        .neq('status', 'read');
  }

  // ── Real-time subscription ───────────────────────────────────────────────

  /// Subscribes to new messages in a conversation. Returns the channel.
  static RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(ChatMessage message) onInsert,
    void Function(ChatMessage message) onUpdate,
  ) {
    return _db
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final msg = ChatMessage.fromJson(
                payload.newRecord);
            onInsert(msg);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final msg = ChatMessage.fromJson(
                payload.newRecord);
            onUpdate(msg);
          },
        )
        .subscribe();
  }

  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await _db.removeChannel(channel);
  }
}
