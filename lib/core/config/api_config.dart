import 'package:flutter/foundation.dart';
import 'package:smarttask/core/api/constants/api_constants.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kReleaseMode) {
      return ApiConstants.baseUrl;
    } else if (kProfileMode) {
      return ApiConstants.baseUrlStaging;
    } else {
      return ApiConstants.baseUrlDev;
    }
  }

  static Map<String, String> get defaultHeaders => {
        ApiConstants.contentType: ApiConstants.applicationJson,
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        ApiConstants.authorization: '${ApiConstants.bearer} $token',
      };

  static Duration get timeout => const Duration(
        milliseconds: ApiConstants.connectionTimeout,
      );

  static Duration get receiveTimeout => const Duration(
        milliseconds: ApiConstants.receiveTimeout,
      );
}
