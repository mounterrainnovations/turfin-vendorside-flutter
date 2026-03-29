# 01 — Project Setup

Complete step-by-step instructions to create the `turfin-vendor-flutter` Flutter project
from zero to a running app shell.

---

## STEP 1 — Create the Flutter Project

Open a terminal in the folder where you keep your projects (e.g. `Desktop/Codes/`).

```bash
flutter create --org com.turfin --project-name turfin_vendor_flutter turfin-vendor-flutter
cd turfin-vendor-flutter
```

Verify it runs:
```bash
flutter run -d chrome    # or flutter run -d windows for quick check
```

---

## STEP 2 — Delete Boilerplate

Delete everything inside `lib/` and replace `lib/main.dart` with a blank shell (you will
fill it properly in Step 7).

Also delete:
- `test/widget_test.dart` (replace with your own later)

---

## STEP 3 — pubspec.yaml

Replace the entire `pubspec.yaml` with:

```yaml
name: turfin_vendor_flutter
description: TurfIn Vendor — Turf management app for field owners and operators
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.9.0

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.6.1

  # Typography
  google_fonts: ^8.0.0

  # Icons
  font_awesome_flutter: ^10.8.0

  # HTTP
  http: ^1.2.2

  # Secure token storage
  flutter_secure_storage: ^9.2.4

  # Image handling (KYC + profile photo)
  image_picker: ^1.1.2
  flutter_image_compress: ^2.1.0

  # QR scanner (check-in)
  mobile_scanner: ^5.2.3

  # Network connectivity detection
  connectivity_plus: ^6.0.5

  # URL launcher
  url_launcher: ^6.3.1

  # Lints
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

Then run:
```bash
flutter pub get
```

---

## STEP 4 — Android Configuration

### android/app/build.gradle.kts

Set `minSdk` to 21 (required for `mobile_scanner` and `flutter_secure_storage`):

```kotlin
android {
    compileSdk = 35
    defaultConfig {
        applicationId = "com.turfin.vendor"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

### android/app/src/main/AndroidManifest.xml

Add these permissions inside `<manifest>`:

```xml
<!-- Camera permission (QR scanner) -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Required for flutter_secure_storage on Android <6 -->
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

---

## STEP 5 — iOS Configuration

### ios/Runner/Info.plist

Add inside the `<dict>`:

```xml
<!-- Camera for QR scanner -->
<key>NSCameraUsageDescription</key>
<string>Used to scan booking QR codes for customer check-in</string>

<!-- Photo library for KYC document upload -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to upload KYC documents and profile photo</string>
```

---

## STEP 6 — Folder Structure

Create the full folder tree under `lib/`. Run these commands or create manually:

```
lib/
  main.dart
  core/
    config/
      api_config.dart
    theme/
      app_colors.dart
      app_theme.dart
      app_typography.dart
    routing/
      app_router.dart
    widgets/
      custom_text_field.dart
      status_chip.dart
      section_label.dart
      vendor_card.dart
      loading_overlay.dart
  features/
    auth/
      data/
        auth_notifier.dart
      presentation/
        pages/
          vendor_login_screen.dart
    splash/
      presentation/
        pages/
          splash_screen.dart
    home/
      data/
        home_tab_notifier.dart
      presentation/
        pages/
          vendor_home_screen.dart
        widgets/
          dashboard_tab.dart
          bookings_tab.dart
          fields_tab.dart
          profile_tab.dart
    bookings/
      data/
        bookings_notifier.dart
        mock_bookings_repository.dart
      domain/
        models/
          vendor_booking_model.dart
      presentation/
        pages/
          booking_detail_screen.dart
    scanner/
      presentation/
        pages/
          scanner_screen.dart
    fields/
      data/
        fields_notifier.dart
        mock_fields_repository.dart
      domain/
        models/
          field_model.dart
          slot_model.dart
      presentation/
        pages/
          add_field_screen.dart
          edit_field_screen.dart
          slot_management_screen.dart
    earnings/
      data/
        earnings_notifier.dart
      domain/
        models/
          payout_model.dart
      presentation/
        pages/
          earnings_screen.dart
    kyc/
      data/
        kyc_notifier.dart
      domain/
        models/
          kyc_model.dart
      presentation/
        pages/
          kyc_screen.dart
    profile/
      presentation/
        pages/
          vendor_profile_screen.dart
```

You can create all directories at once on a Mac/Linux machine. On Windows, create them
manually in VS Code or use:

```bash
# PowerShell — run from inside turfin-vendor-flutter/lib
$dirs = @(
  "core/config","core/theme","core/routing","core/widgets",
  "features/auth/data","features/auth/presentation/pages",
  "features/splash/presentation/pages",
  "features/home/data","features/home/presentation/pages","features/home/presentation/widgets",
  "features/bookings/data","features/bookings/domain/models","features/bookings/presentation/pages",
  "features/scanner/presentation/pages",
  "features/fields/data","features/fields/domain/models","features/fields/presentation/pages",
  "features/earnings/data","features/earnings/domain/models","features/earnings/presentation/pages",
  "features/kyc/data","features/kyc/domain/models","features/kyc/presentation/pages",
  "features/profile/presentation/pages"
)
$dirs | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force }
```

---

## STEP 7 — main.dart (Minimal Shell)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode on phones
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: TurfinVendorApp()));
}

class TurfinVendorApp extends ConsumerWidget {
  const TurfinVendorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TurfIn Vendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AppRouter(),
    );
  }
}
```

---

## STEP 8 — api_config.dart

```dart
// lib/core/config/api_config.dart

class ApiConfig {
  // Change to your machine's local IP when testing on a physical device
  // For Android emulator use: http://10.0.2.2:3000/api/v1
  static const String baseUrl = 'http://192.168.1.4:3000/api/v1';

  // Auth
  static const String signIn   = '$baseUrl/auth/signin';
  static const String signOut  = '$baseUrl/auth/signout';
  static const String refresh  = '$baseUrl/auth/refresh';

  // Vendor profile
  static const String vendorMe = '$baseUrl/vendors/me';

  // Fields
  static const String fields   = '$baseUrl/fields';

  // Slots
  static const String slots    = '$baseUrl/slots';

  // Bookings
  static const String bookings = '$baseUrl/bookings/vendor';

  // KYC
  static const String kyc      = '$baseUrl/kyc';

  // Earnings / payments
  static const String earnings = '$baseUrl/payments/vendor';
}
```

---

## STEP 9 — analysis_options.yaml

Replace the content with:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - avoid_print
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - sort_child_properties_last
    - use_key_in_widget_constructors
```

---

## STEP 10 — Verify

Run `flutter analyze`. It should report zero errors (possibly minor warnings on empty files —
ignore those for now).

Run `flutter run`. The app should open a black screen (no routes yet — that is correct).

---

## Checkpoint 1 ✓

At the end of this step you have:
- Clean repo with correct bundle ID (`com.turfin.vendor`)
- All dependencies installed
- Full folder structure ready
- Theme imports wired in `main.dart`
- API config with all endpoint constants
- Zero analyzer errors

**Next: [02_theme_and_design_system.md](./02_theme_and_design_system.md)**
