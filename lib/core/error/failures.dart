import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    super.message, {
    super.statusCode,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [
        message,
        statusCode,
        fieldErrors,
      ];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    String message = 'Invalid credentials. Please try again.',
  ]) : super(
          message,
          statusCode: 401,
        );
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    String message = 'Your account is not verified yet.',
  ]) : super(
          message,
          statusCode: 403,
        );
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    String message = 'User account not found.',
  ]) : super(
          message,
          statusCode: 404,
        );
}

class ConflictFailure extends Failure {
  const ConflictFailure([
    String message = 'An account with this email already exists.',
  ]) : super(
          message,
          statusCode: 409,
        );
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([
    String message = 'Too many attempts. Please try again later.',
  ]) : super(
          message,
          statusCode: 429,
        );
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'No internet connection. Please check your network.',
  ]) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    String message = 'An unexpected error occurred.',
  ]) : super(message);
}