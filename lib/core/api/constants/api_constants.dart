class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = 'https://api-smart-task/api';
  static const String baseUrlDev = 'https://api-smart-task/api';
  static const String baseUrlStaging =
      'https://api-load-link.gafatrading.com/api';

  // API Versions
  static const String apiVersion = 'v1.0';

  // API Endpoints
  static const String createMember = '/members/create';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000;

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String accept = 'Accept';
  static const String apiKey = 'X-API-Key';
  static const String apiKeyValue =
      'your-api-key-here'; // Replace with your actual API key

  // Error Messages
  static const String connectionError = 'Connection error';
  static const String unauthorizedError = 'Unauthorized access';
  static const String somethingWentWrong = 'Something went wrong';
}
