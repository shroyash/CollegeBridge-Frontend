import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';

/// Sealed state class for the Auth feature.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no action taken yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state — an API call is in flight.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state — user is authenticated.
final class AuthSuccess extends AuthState {
  final AuthUser user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Failure state — an error occurred.
final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
