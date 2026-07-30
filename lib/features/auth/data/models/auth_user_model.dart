import '../../domain/entities/auth_user.dart';

/// Data Transfer Object — maps the JSON from the backend to a domain entity.
/// Backend payload: { accessToken, refreshToken, name, email, role }
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.accessToken,
    required super.refreshToken,
    required super.name,
    required super.email,
    required super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'name': name,
        'email': email,
        'role': role,
      };
}
