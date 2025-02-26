import 'package:dio/dio.dart';
import 'package:smarttask/core/errors/api_error_handler.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    throw ApiErrorHandler.handleError(err);
  }
}
