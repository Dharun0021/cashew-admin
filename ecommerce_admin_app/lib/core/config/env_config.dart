/// Environment configuration for local and production environments
class EnvConfig {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'local');

  // API Base URLs
  static String get apiBaseUrl {
    if (environment == 'production') {
      return 'https://cashnew-backend.onrender.com/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Category Endpoints
  static String get createCategoryEndpoint => '$apiBaseUrl/category/create';
  static String get listCategoriesEndpoint => '$apiBaseUrl/category/list';

  // Product Endpoints (for future use)
  static String get createProductEndpoint => '$apiBaseUrl/product/create';
  static String get listProductsEndpoint => '$apiBaseUrl/product/list';

  // Order Endpoints (for future use)
  static String get listOrdersEndpoint => '$apiBaseUrl/order/list';
  static String get getOrderDetailsEndpoint => '$apiBaseUrl/order';

  // Customer Endpoints (for future use)
  static String get listCustomersEndpoint => '$apiBaseUrl/customer/list';

  // Notification Endpoints (for future use)
  static String get listNotificationsEndpoint => '$apiBaseUrl/notification/list';

  // API Timeout (in seconds)
  static const int apiTimeout = 30;

  // Debugging
  static const bool enableLogging = true;

  static void printConfig() {
    print('=== Environment Configuration ===');
    print('Environment: $environment');
    print('API Base URL: $apiBaseUrl');
    print('API Timeout: ${apiTimeout}s');
    print('Logging Enabled: $enableLogging');
    print('===================================');
  }
}
