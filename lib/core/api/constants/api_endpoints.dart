class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String registerDriver = '/register-driver';
  static const String driverLogin = '/drivers';
  static const String verifyEmail = '/members/verify';
  static const String verifyOtp = '/verify-otp';
  static const String refreshToken = '/members/refresh-token';
  static const String createPassword = '/create-new-password';
  static const String forgotPassword = '/forgot-password';
  static const String verifyPassword = '/verify-password';
  static const String resetPassword = '/reset-password';
  static const String resendOtp = '/resend-otp';
  static const String unlinkDevice = '/unlink-device';
  static const String logout = '/logout';
  static const String loginWithPin = '/login-with-pin';
  static const String verifyPin = '/verify-pin';
  static const String createPin = '/create-pin';
  static const String forgotPin = '/forgot-pin';
  static const String forgotPinWithPhone = '/forgot-pin-with-phone';
  static const String resetPin = '/reset-pin';
  static const String driverOrders = '/driver-orders';

  // User endpoints
  static const String userProfile = '/update-profile';
  static const String updateProfile = '/user/profile/update';
  static const String changePassword = '/change-password';
  static const String profile = '/profile';

  // Transaction endpoints
  static const String transactions = '/transactions';
  static const String transactionDetails = '/transactions/';
  static const String createTransaction = '/transactions/create';

  // Contact endpoints
  static const String contacts = '/contacts';
  static const String contactDetails = '/contacts/';
  static const String addContact = '/contacts/add';
}
