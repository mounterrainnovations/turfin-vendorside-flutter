// lib/core/config/api_config.dart

class ApiConfig {
  // Change to your machine's local IP when testing on a physical device
  // For Android emulator use: http://10.0.2.2:3000/api/v1
  static const String baseUrl = 'http://192.168.1.4:3000/api/v1';

  // Auth
  static const String signIn  = '$baseUrl/auth/signin';
  static const String signOut = '$baseUrl/auth/signout';
  static const String refresh = '$baseUrl/auth/refresh';

  // Vendor profile
  static const String vendorMe = '$baseUrl/vendors/me';

  // Fields
  static const String fields = '$baseUrl/fields';

  // Slots
  static const String slots = '$baseUrl/slots';

  // Bookings
  static const String bookings = '$baseUrl/bookings/vendor';

  // KYC
  static const String kyc = '$baseUrl/kyc';

  // Earnings / payments
  static const String earnings = '$baseUrl/payments/vendor';

  // Dashboard
  static const String dashboard = '$baseUrl/dashboard/vendor';
}
