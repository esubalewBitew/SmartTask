import 'package:dio/dio.dart';
import 'package:smarttask/core/services/navigation/navigation_service.dart';
import 'package:smarttask/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token
    final token = await sl<AuthLocalDataSource>().getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add default headers
    options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Handle successful responses
    if (response.statusCode == 200 || response.statusCode == 201) {
      handler.next(response);
    } else {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle token expiration
      await _handleTokenExpiration();
      // Retry original request
      final retryResponse = await _retryRequest(err.requestOptions);
      handler.resolve(retryResponse);
    } else {
      handler.next(err);
    }
  }

  Future<void> _handleTokenExpiration() async {
    // Clear token
    await sl<AuthLocalDataSource>().clearAuthToken();
    // Navigate to login
    // sl<NavigationService>().navigateToLogin();
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return sl<Dio>().request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
