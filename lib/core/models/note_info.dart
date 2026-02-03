class NoteInfo {
  final int id;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;

  NoteInfo({
    required this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  factory NoteInfo.fromJson(Map<String, dynamic> json) {
    return NoteInfo(
      id: json['id'] as int,
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as String?,
    );
  }

  bool get isFavorite => true;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
    };
  }
}
