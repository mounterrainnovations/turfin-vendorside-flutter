// lib/core/config/api_config.dart

class ApiConfig {
  // Change to your machine's local IP when testing on a physical device
  // For Android emulator use: http://10.0.2.2:3000/api/v1
  static const String baseUrl = 'http://192.168.56.1:3000/api/v1';

  // Auth
  static const String signUp  = '$baseUrl/auth/signup';
  static const String signIn  = '$baseUrl/auth/signin';
  static const String signOut = '$baseUrl/auth/signout';
  static const String refresh = '$baseUrl/auth/refresh';

  // Vendor profile
  static const String vendorMe = '$baseUrl/vendors/me';

  // Fields
  static const String fields       = '$baseUrl/fields';
  static const String vendorTurfs  = '$baseUrl/vendors/turfs';
  static const String vendorArenas = '$baseUrl/vendors/arenas';

  // Slots
  static const String slots = '$baseUrl/slots';

  // Bookings
  static const String bookings = '$baseUrl/bookings/vendor';

  // KYC
  static const String kycSubmit = '$baseUrl/kyc/me/submit';
  static const String kycMe     = '$baseUrl/kyc/me';

  // Storage
  static const String storageUploadUrl = '$baseUrl/storage/upload-url';
  static const String storageViewUrl   = '$baseUrl/storage/view-url';

  // Earnings / payments
  static const String earnings = '$baseUrl/payments/vendor';

  // Dashboard
  static const String dashboard = '$baseUrl/dashboard/vendor';

  // Onboarding options
  static const String sports    = '$baseUrl/sports';
  static const String amenities = '$baseUrl/amenities';
}
