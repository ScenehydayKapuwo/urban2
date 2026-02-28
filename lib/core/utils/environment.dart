// lib/core/utils/environment.dart
enum Environment {
  development,  // Changed from 'dev' to 'development'
  staging,
  production,
}

class AppConfig {
  static late String baseUrl;
  static late Environment environment;

  static void initialize({required Environment env}) {  // Changed from 'init' to 'initialize'
    environment = env;

    switch (env) {
      case Environment.development:
        baseUrl = 'http://10.222.176.20:5000';
        break;
      case Environment.staging:
        baseUrl = 'https://staging.your-api.com';
        break;
      case Environment.production:
        baseUrl = 'https://api.your-app.com';
        break;
    }
  }
}