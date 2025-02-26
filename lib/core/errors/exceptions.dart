import 'package:equatable/equatable.dart';

/// Exception thrown when there is a server-related error
class ServerException extends Equatable implements Exception {
  const ServerException({
    required this.message,
    required this.statusCode,
  });
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class UnauthorizedException extends Equatable implements Exception {
  const UnauthorizedException({
    required String? message,
    this.statusCode = 401,
  }) : message = message ?? 'Unauthorized access';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class ForbiddenException extends Equatable implements Exception {
  const ForbiddenException({
    String? message,
    this.statusCode = 403,
  }) : message = message ?? 'Access forbidden';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkException extends Equatable implements Exception {
  const NetworkException({
    String? message,
    this.statusCode = 503,
  }) : message = message ?? 'No internet connection';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class CacheException extends Equatable implements Exception {
  const CacheException({
    required String? message,
    this.statusCode = 500,
  }) : message = message ?? 'Cache error';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class DeviceException extends Equatable implements Exception {
  const DeviceException({
    required String? message,
    this.statusCode = 400,
    this.deviceStatus,
  }) : message = message ?? 'Device error';
  
  final String message;
  final int statusCode;
  final String? deviceStatus;
  
  @override
  List<Object?> get props => [message, statusCode, deviceStatus];
}

class ValidationException extends Equatable implements Exception {
  const ValidationException({
    required String? message,
    this.statusCode = 422,
    this.errors,
  }) : message = message ?? 'Validation error';
  
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;
  
  @override
  List<Object?> get props => [message, statusCode, errors];
}

class TimeoutException extends Equatable implements Exception {
  const TimeoutException({
    String? message,
    this.statusCode = 408,
  }) : message = message ?? 'Request timeout';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class ApiException extends Equatable implements Exception {
  const ApiException({
    required String? message,
    required this.statusCode,
  }) : message = message ?? 'API error';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class RateLimitException extends Equatable implements Exception {
  const RateLimitException({
    String? message,
    this.statusCode = 429,
  }) : message = message ?? 'Rate limit exceeded';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class BiometricException extends Equatable implements Exception {
  const BiometricException({
    String? message,
    this.statusCode = 400,
  }) : message = message ?? 'Biometric authentication error';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

class NotFoundException extends Equatable implements Exception {
  const NotFoundException({
    String? message,
    this.statusCode = 404,
  }) : message = message ?? 'Resource not found';
  
  final String message;
  final int statusCode;
  
  @override
  List<Object?> get props => [message, statusCode];
}

