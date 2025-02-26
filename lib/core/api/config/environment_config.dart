enum Environment {
  dev,
  staging,
  prod,
}

class EnvironmentConfig {
  static Environment _environment = Environment.dev;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.prod;

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev.eaglelionsystems.com/v1.0/cbrs-api';
      case Environment.staging:
        return 'https://staging.eaglelionsystems.com/v1.0/cbrs-api';
      case Environment.prod:
        return 'https://eaglelionsystems.com/v1.0/cbrs-api';
    }
  }
}
