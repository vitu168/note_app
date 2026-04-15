class UserProfile {
  final String id;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final String? email;
  final bool? isNote;

  const UserProfile({
    required this.id,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.email,
    this.isNote,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      email: json['email'] as String?,
      isNote: json['isNote'] as bool?,
    );
  }

  UserProfile copyWith({
    String? name,
    String? avatarUrl,
    String? email,
    bool? isNote,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      email: email ?? this.email,
      isNote: isNote ?? this.isNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'email': email,
      'isNote': isNote,
    };
  }
}
