class NoteInfo {
  final int id;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final bool isFavorites;

  const NoteInfo({
    required this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.isFavorites = false,
  });

  factory NoteInfo.fromJson(Map<String, dynamic> json) {
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
      isFavorites: json['isFavorites'] as bool? ?? false,
    );
  }

  NoteInfo copyWith({
    String? name,
    String? description,
    bool? isFavorites,
    DateTime? updatedAt,
  }) {
    return NoteInfo(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId,
      isFavorites: isFavorites ?? this.isFavorites,
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
      'isFavorites': isFavorites,
    };
  }
}
