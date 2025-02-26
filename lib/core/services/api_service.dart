import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarttask/core/network/api_client.dart';

class ApiResponse {
  final String body;
  final int statusCode;

  const ApiResponse({required this.body, required this.statusCode});
}

class ApiService {
  final ApiClient _apiClient;

  ApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<dynamic> get(String endpoint) async {
    return _apiClient.get(endpoint);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    return _apiClient.post(endpoint, data: body);
  }

  void dispose() {
    // Dispose logic if needed
  }
}
