import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smarttask/core/errors/exceptions.dart';

class ApiErrorHandler {
  static Exception handleError(DioException error) {
    debugPrint('DioException details:');
    debugPrint('Type: ${error.type}');
    debugPrint('Message: ${error.message}');
    debugPrint('Response status: ${error.response?.statusCode}');
    debugPrint('Response data: ${error.response?.data}');

    if (_isTimeoutError(error.type)) {
      return TimeoutException(
        message: 'Connection timed out. Please try again.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'No internet connection. Please check your connection.',
      );
    }

    if (error.type == DioExceptionType.badResponse) {
      return _handleResponseError(error.response);
    }

    return ApiException(
      message: error.message ?? 'An unexpected error occurred',
      statusCode: error.response?.statusCode ?? 500,
    );
  }

  static bool _isTimeoutError(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout;
  }

  static Exception _handleResponseError(Response<dynamic>? response) {
    final message = _extractErrorMessage(response);
    final errors = _extractErrorDetails(response);
    final statusCode = response?.statusCode ?? 500;

    return _createExceptionFromStatus(statusCode, message, errors);
  }

  static String? _extractErrorMessage(Response<dynamic>? response) {
    return response?.data is Map ? response?.data['message'] as String? : null;
  }

  static Map<String, dynamic>? _extractErrorDetails(
      Response<dynamic>? response) {
    return response?.data is Map
        ? response?.data['errors'] as Map<String, dynamic>?
        : null;
  }

  static Exception _createExceptionFromStatus(
    int statusCode,
    String? message,
    Map<String, dynamic>? errors,
  ) {
    switch (statusCode) {
      case 400:
        return ValidationException(message: message, errors: errors);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 429:
        return RateLimitException(message: message);
      case 500:
        return ServerException(
          message: message ?? 'Internal server error',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          message: message ?? 'Unknown error occurred',
          statusCode: statusCode,
        );
    }
  }
}
