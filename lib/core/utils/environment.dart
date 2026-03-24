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
        baseUrl = 'https://2scenehyday.pythonanywhere.com';
        break;
      case Environment.staging:
        baseUrl = 'https://2scenehyday.pythonanywhere.com';
        break;

      case Environment.production:
        baseUrl = 'https://2scenehyday.pythonanywhere.com';
        break;
    }
  }
}