class AuthResponse {
  final String userId;
  final String email;
  final String? name;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.userId,
    required this.email,
    this.name,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      // Accept userId as either a String or an int from the backend.
      userId: (json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: json['name'] as String?,
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class AuthUser {
  final String userId;
  final String email;
  final String? name;
  final String accessToken;

  AuthUser({
    required this.userId,
    required this.email,
    this.name,
    required this.accessToken,
  });

  factory AuthUser.fromAuthResponse(AuthResponse response) {
    return AuthUser(
      userId: response.userId,
      email: response.email,
      name: response.name,
      accessToken: response.accessToken,
    );
  }
}
