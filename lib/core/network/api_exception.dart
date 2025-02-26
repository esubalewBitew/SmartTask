import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(message: 'Connection timeout');
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Server not responding');
      case DioExceptionType.badResponse:
        return ApiException(
          message: error.response?.data['message'].toString() ?? 'Server error',
          statusCode: error.response?.statusCode,
          data: error.response?.data as Map<String, dynamic>?,
        );
      default:
        return ApiException(message: 'Something went wrong');
    }
  }
}
