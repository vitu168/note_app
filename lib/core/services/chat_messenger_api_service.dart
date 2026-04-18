import 'package:note_app/core/models/chat_messenger_message.dart';
import 'package:note_app/core/services/api_service.dart';

class ChatMessengerApiService {
  final ApiService _api = ApiService();

  static const String _base = '/api/ChatMessenger';

  /// Fetch messages. Filters by [senderId], [receiverId] and optionally [page]/[pageSize].
  Future<ChatMessengerResponse> getMessages({
    String? senderId,
    String? receiverId,
    int? conversationId,
    bool? isRead,
    String? search,
    int page = 1,
    int? pageSize,
  }) async {
    final params = <String, dynamic>{
      'Page': page,
    };
    if (pageSize != null) params['PageSize'] = pageSize;
    if (senderId != null) params['SenderId'] = senderId;
    if (receiverId != null) params['ReceiverId'] = receiverId;
    if (conversationId != null) params['ConversationId'] = conversationId;
    if (isRead != null) params['IsRead'] = isRead;
    if (search != null && search.isNotEmpty) params['Search'] = search;

    final response = await _api.get(_base, queryParameters: params);
    return ChatMessengerResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Send a new message.
  Future<ChatMessengerMessage> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String messageType = 'TextChat',
  }) async {
    final response = await _api.post(
      _base,
      data: {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType,
        'isRead': false,
      },
    );
    return ChatMessengerMessage.fromJson(response as Map<String, dynamic>);
  }

  /// Get a single message by id.
  Future<ChatMessengerMessage> getMessageById(int id) async {
    final response = await _api.get('$_base/$id');
    return ChatMessengerMessage.fromJson(response as Map<String, dynamic>);
  }

  /// Update (edit) a message. Requires the full message payload.
  Future<ChatMessengerMessage> updateMessage(
    int id, {
    required String senderId,
    required String receiverId,
    required String content,
    required String messageType,
    required bool isRead,
  }) async {
    final response = await _api.put(
      '$_base/$id',
      data: {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType,
        'isRead': isRead,
      },
    );
    return ChatMessengerMessage.fromJson(response as Map<String, dynamic>);
  }

  /// Delete a message by id.
  Future<void> deleteMessage(int id) async {
    await _api.delete('$_base/$id');
  }

  /// Get the unread message count for a receiver.
  /// Calls GET /api/ChatMessenger/unread-count/{receiverId}
  Future<int> getUnreadCount(String receiverId) async {
    final response = await _api.get('$_base/unread-count/$receiverId');
    final json = response as Map<String, dynamic>;
    return (json['unreadCount'] as num).toInt();
  }
}
