import 'package:dio/dio.dart';
import 'package:smarttask/core/api/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_local_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;

  AuthInterceptor(this._localDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _localDataSource.getAuthToken();

    if (token != null) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';

      debugPrint('token: $token');
    }

    options.headers.addAll({
      ApiConstants.contentType: ApiConstants.applicationJson,
      ApiConstants.accept: ApiConstants.applicationJson,
      ApiConstants.apiKey: ApiConstants.apiKeyValue,
    });

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token expiration
      _localDataSource.clearAuthToken();
    }
    handler.next(err);
  }
}
