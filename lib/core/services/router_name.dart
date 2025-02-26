import 'package:smarttask/core/common/presentation/pages/main_page.dart';

class AppRouteName {
  AppRouteName._();

  // Auth Routes
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String sso = 'sso';

  // Main Routes
  static const String home = 'home';
  static const String tasks = 'tasks';
  static const String profile = 'profile';
  static const String calendar = 'calendar';
  static const String workspaces = 'workspaces';
  static const String signIn = 'sign-in';
  static const String signUp = 'sign-up';
  static const String createRole = 'create-role';
  static const String onBoardFirstPage = 'on-board-first-page';
  static const String mainPage = 'main-page';
  static const String notifications = 'notifications';
  static const String sendUsd = 'send-usd';
  static const String recipientAccountNumber = 'recipient-account-number';
  static const String addAmount = 'add-amount';
  static const String addAmountBankTransfer = 'add-amount-bank-tranfer';
  static const String confirmationSendUsd = 'confirmation-send-usd';
  static const String confirmationSendEtb = 'confirmation-send-etb';
  static const String sendMoneySuccess = 'send-money-success';
  static const String loadToWallet = 'load-to-wallet';
  static const String paymentPage = 'payment-page';
  static const String successPage = 'payment-success-page';
  static const String failurePage = 'failure-page';
  static const String transferToWalletUsd = 'transfer-to-wallet-usd';
  static const String addAmountTransfer = 'add-amount-transfer';
  static const String confirmTransfer = 'confirm-transfer';
  static const String transferSuccess = 'transfer-success';
  static const String transferToWalletBirr = 'transfer-to-wallet-birr';
  static const String addAmountTransferBirr = 'add-amount-transfer-birr';
  static const String confirmTransferBirr = 'confirm-transfer-birr';
  static const String transferSuccessBirr = 'transfer-success-birr';
  static const String changeToBirr = 'change-to-birr';
  static const String confirmChangeToBirr = 'confirm-change-to-birr';
  static const String changeSuccess = 'change-success';
  static const String sendEtb = 'send-etb';
  static const String addAmountEtb = 'add-amount-etb';
  static const String verifyOtp = 'verify-otp';
  static const String changePin = 'change-pin';
  static const String profileInfo = 'profile-info';
  static const String privacyPolicy = 'privacy-policy';
  static const String termsAndConditions = 'terms-and-conditions';
  static const String customerSupport = 'customer-support';
  static const String faq = 'faq';
  static const String contacts = 'contacts';
  static const String verifyEmail = 'verify-email';
  static const String createPin = 'create-pin';
  static const String tokenDeviceLogin = 'token-device-login';
  static const String quickWalletTransfer = 'quick-wallet-transfer';
  static const String loadDetail = 'load-detail';
  static const String myLoads = 'my-loads';
  static const String agreements = 'agreements';
  static const String agreementsConfirmation = 'agreements-confirmation';
  static const String deliveryOrderConfirmation = 'deliveryOrder-confirmation';
  static const String orderTrackingScreen = 'order-tracking';
  static const String onboarding = 'onboarding';
  static const String createOrder = 'create-order';
  static const String createOrderNext = 'create-order-next';
  static const String loadDetailOrder = 'load-detail-order';
  static const String paymentMethod = 'payment-method';
  static const String truckInfo = 'truck-info';
  static const String truckDetails = 'truck-details';
  static const String addTruck = 'add-truck';
  static const String successPages = 'success-page';
  static const String loadDetailShipper = 'load-detail-shipper';
  static const String loadDetailShipperOrder = 'load-detail-shipper-order';

  // Collaboration Routes
  static const String teamWorkspace = 'team-workspace';
  static const String members = 'members';
  static const String realtime = 'realtime';
  static const String activity = 'activity';

  // Profile Routes
  static const String settings = 'settings';

  static const String verification = 'verification';
  static const String support = 'support';
  static const String referral = 'referral';
  static const String legal = 'legal';
  static const String themeMode = 'themeMode';
}

class RouterName {
  RouterName._();

  static const String main = '/';
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String calendar = '/calendar';
}
