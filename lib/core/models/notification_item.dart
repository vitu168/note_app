class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.senderId,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final String? senderId;
  bool isRead;

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        senderId: senderId,
        isRead: isRead ?? this.isRead,
      );
}
