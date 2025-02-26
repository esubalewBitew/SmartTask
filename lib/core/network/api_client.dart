import 'package:smarttask/core/api/constants/api_constants.dart';
import 'package:smarttask/core/network/api_interception.dart';
import 'package:dio/dio.dart';
import 'package:smarttask/core/network/api_exception.dart';
import 'package:flutter/material.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ));

    _dio.interceptors.addAll([
      ApiInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => obj.toString(),
      ),
    ]);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  ApiException _createApiException(Response response) {
    return ApiException(
      message: _getErrorMessage(response),
      statusCode: response.statusCode,
      data: response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'error': response.data},
    );
  }

  String _getDioErrorMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again';
      case DioExceptionType.badCertificate:
        return 'Invalid certificate. Please contact support';
      case DioExceptionType.badResponse:
        return 'Invalid response from server';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred';
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('response api client  path: ${ApiConstants.baseUrl + path}');
      final response = await _dio.post(
        ApiConstants.baseUrl + path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'Content-Type': 'application/json',
            ...?options?.headers,
          },
        ),
      );
      debugPrint('response api client: ${response.data}');

      if (response.statusCode != null && response.statusCode! >= 400) {
        debugPrint('API Error Response Data: ${response.data}');
        debugPrint('API Error Status Code: ${response.statusCode}');

        final errorMessage = response.statusCode == 422
            ? 'Validation Error: ${response.data?['message'] ?? response.data?['error'] ?? 'Invalid data submitted'}'
            : (response.data?['message'] ?? 'Request failed').toString();

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          data: response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'error': response.data},
        );
      }

      return _handleResponse<T>(response);
    } on ApiException catch (e) {
      debugPrint('response api client error Status Code: ${e.statusCode}');
      throw ApiException(
        message: e.toString() ?? 'Server error',
        statusCode: e.statusCode ?? 500,
        data: {'error': e.toString()},
      );
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  T _handleResponse<T>(Response response) {
    try {
      final responseData = response.data;
      // debugPrint('response api client data: ${responseData}');

      if (responseData is Map<String, dynamic>) {
        //debugPrint('response api client data inside if: ${responseData}');
        // If T is Map<String, dynamic>, return the entire response
        if (T.toString() == 'Map<String, dynamic>') {
          return responseData as T;
        }

        // Handle nested data structure
        if (responseData.containsKey('data')) {
          //debugPrint('response api client data inside if 2: ${responseData}');
          return responseData['data'] as T;
        }

        // If no data key exists, try other common keys
        if (responseData.containsKey('result')) {
          //debugPrint('response api client data inside if 3: ${responseData}');
          return responseData['result'] as T;
        }

        // If no known keys exist, return the whole response
        return responseData as T;
      }

      return responseData as T;
    } catch (e) {
      throw ApiException(
        message: 'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode ?? 500,
        data: response.data as Map<String, dynamic>?,
      );
    }
  }

  String _getErrorMessage(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'].toString() ??
            data['error'].toString() ??
            data['error_message'].toString() ??
            _getDefaultErrorMessage(response.statusCode);
      }
      return _getDefaultErrorMessage(response.statusCode);
    } catch (_) {
      return _getDefaultErrorMessage(response.statusCode);
    }
  }

  String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 500:
        return 'Server error';
      default:
        return 'Something went wrong';
    }
  }
}
