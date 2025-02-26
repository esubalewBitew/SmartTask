import 'package:smarttask/core/errors/exceptions.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  Failure({
    required this.message,
    required this.statusCode,
    this.errorCode,
    this.details,
    this.timestamp,
  });

  final String message;
  final int statusCode;
  final String? errorCode;
  final String? details;
  final String? timestamp;

  String get errorMessage =>
      '$statusCode${errorCode != null ? ' - $errorCode' : ''}: $message';

  @override
  List<Object?> get props =>
      [message, statusCode, errorCode, details, timestamp];
}

// 400 - Bad Request
class ValidationFailure extends Failure {
  ValidationFailure({
    required String message,
    Map<String, dynamic>? errors,
  }) : super(
          message: message,
          statusCode: 400,
          errorCode: 'VALIDATION_ERROR',
          details: errors?.toString(),
        );

  ValidationFailure.fromException(ValidationException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
          details: exception.errors?.toString(),
        );
}

// 401 - Unauthorized
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({
    String message = 'Authentication failed',
  }) : super(
          message: message,
          statusCode: 401,
          errorCode: 'AUTH_ERROR',
        );

  UnauthorizedFailure.fromException(UnauthorizedException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

// 403 - Forbidden
class DeviceFailure extends Failure {
  DeviceFailure({
    String message = 'Device not linked/authorized',
    String? deviceStatus,
  }) : super(
          message: message,
          statusCode: 403,
          errorCode: 'DEVICE_ERROR',
          details: deviceStatus,
        );

  DeviceFailure.fromException(DeviceException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
          details: exception.deviceStatus,
        );
}

// 429 - Too Many Requests
class RateLimitFailure extends Failure {
  RateLimitFailure({
    String message = 'Rate limit exceeded',
    String? details,
  }) : super(
          message: message,
          statusCode: 429,
          errorCode: 'RATE_LIMIT_ERROR',
          details: details,
        );
}

// 500 - Server Error
class ServerFailure extends Failure {
  ServerFailure({
    String message = 'Internal server error',
  }) : super(
          message: message,
          statusCode: 500,
          errorCode: 'SERVER_ERROR',
        );

  ServerFailure.fromException(ServerException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode as int,
        );
}

// Network Related Failures
class NetworkFailure extends Failure {
  NetworkFailure({
    String message = 'No internet connection',
  }) : super(
          message: message,
          statusCode: 503,
          errorCode: 'NETWORK_ERROR',
        );

  NetworkFailure.fromException(NetworkException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

// Cache Related Failures
class CacheFailure extends Failure {
  CacheFailure({
    required String message,
  }) : super(
          message: message,
          statusCode: 500,
          errorCode: 'CACHE_ERROR',
        );

  CacheFailure.fromException(CacheException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

class AuthFailure extends Failure {
  AuthFailure({
    required String message,
  }) : super(
          message: message,
          statusCode: 401,
          errorCode: 'AUTH_ERROR',
        );

  AuthFailure.fromException(BiometricException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

class NotFoundFailure extends Failure {
  NotFoundFailure({
    String message = 'Resource not found',
  }) : super(
          message: message,
          statusCode: 404,
          errorCode: 'NOT_FOUND_ERROR',
        );

  NotFoundFailure.fromException(NotFoundException exception)
      : super(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}
