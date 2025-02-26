import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smarttask/core/api/constants/api_constants.dart';
import 'package:smarttask/core/api/interceptors/auth_interceptor.dart';
import 'package:smarttask/core/api/interceptors/error_interceptor.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_local_datasource.dart';

class ApiConfig {
  static Dio? _dio;
  final AuthLocalDataSource _localDataSource;

  ApiConfig({required AuthLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  Dio get client {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
      headers: defaultHeaders,
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.interceptors.addAll([
      AuthInterceptor(_localDataSource),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  String _getBaseUrl() {
    if (kReleaseMode) {
      return ApiConstants.baseUrl;
    } else if (kProfileMode) {
      return ApiConstants.baseUrlStaging;
    }
    return ApiConstants.baseUrlDev;
  }

  static Map<String, String> get defaultHeaders => {
        ApiConstants.contentType: ApiConstants.applicationJson,
        ApiConstants.accept: ApiConstants.applicationJson,
        ApiConstants.apiKey: ApiConstants.apiKeyValue,
      };

  void dispose() {
    if (_dio != null) {
      _dio!.close();
      _dio = null;
    }
  }
}
