import 'package:smarttask/core/api/constants/api_constants.dart';
import 'package:smarttask/core/errors/exceptions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity;

  ConnectivityInterceptor(this._connectivity);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: NetworkException(
            message: ApiConstants.connectionError,
            statusCode: 503,
          ),
        ),
      );
    }

    return handler.next(options);
  }
}
