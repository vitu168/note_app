class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
  });

  // Optional: Add a factory constructor to create from JSON if needed
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
