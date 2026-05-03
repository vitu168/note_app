class NoteInfo {
  final int id;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final List<String> userIds;
  final bool isFavorites;
  final DateTime? reminder;

  const NoteInfo({
    required this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userIds = const [],
    this.isFavorites = false,
    this.reminder,
  });

  factory NoteInfo.fromJson(Map<String, dynamic> json) {
    final rawIds = json['userIds'];
    final ids = rawIds is List
        ? rawIds.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList()
        : <String>[];
    return NoteInfo(
      id: json['id'] as int,
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      userId: json['userId']?.toString(),
      userIds: ids,
      isFavorites: json['isFavorites'] as bool? ?? false,
      reminder: json['reminder'] != null
          ? DateTime.tryParse(json['reminder'].toString())
          : null,
    );
  }

  NoteInfo copyWith({
    String? name,
    String? description,
    bool? isFavorites,
    DateTime? updatedAt,
    List<String>? userIds,
    DateTime? reminder,
    bool clearReminder = false,
  }) {
    return NoteInfo(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId,
      userIds: userIds ?? this.userIds,
      isFavorites: isFavorites ?? this.isFavorites,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'userIds': userIds,
      'isFavorites': isFavorites,
      'reminder': reminder?.toIso8601String(),
    };
  }
}
