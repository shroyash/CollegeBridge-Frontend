import 'package:equatable/equatable.dart';

/// Core domain entity representing an authenticated user.
/// Independent of any framework or serialization logic.
class AuthUser extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String name;
  final String email;
  final String role;

  const AuthUser({
    required this.accessToken,
    required this.refreshToken,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, name, email, role];
}
