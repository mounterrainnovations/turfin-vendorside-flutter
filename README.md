# TurfIn Vendor

The vendor-side Flutter app in the TurfIn ecosystem. Turf and sports facility owners use this app to manage their fields, bookings, slots, KYC, and earnings.

## Ecosystem

| App | Role |
|---|---|
| **TurfIn Vendor** (this repo) | Turf owners — manage fields, check in customers, track earnings |
| **TurfIn Client** | Customers — browse and book turfs |
| **Admin Portal** | Internal — platform management |

Shared backend: NestJS API + Supabase. Same Razorpay integration (vendor app uses payouts, not checkout).

## Tech Stack

- Flutter + Dart (sdk ^3.9.0)
- State: Riverpod (`flutter_riverpod`)
- Auth: JWT via `flutter_secure_storage` (keys prefixed `vendor_`)
- Fonts: Manrope via `google_fonts`
- QR scanner: `mobile_scanner`

## Design System

See [DESIGN.md](DESIGN.md) for the complete design specification.

**TL;DR rules that must never break:**
1. Three base colors only: `AppColors.primary` (#CCFF00 neon), `AppColors.black` (#000000), `AppColors.white` (#FFFFFF)
2. Dark mode only — `ThemeMode.dark`, no toggle
3. All CTAs are pill-shaped: `BorderRadius.circular(30)`
4. Neon glow on exactly ONE element per screen
5. Never `.withOpacity()` — use `const Color(0xAARRGGBB)` constants
6. Never hardcode colors in widgets — always `AppColors.*` or `AppThemeColors.of(context).*`
7. `AppColors.error` (#EF4444) only for errors and destructive actions

## Screens

```
SplashScreen → VendorLoginScreen
             → VendorHomeScreen
                 ├── DashboardTab
                 ├── BookingsTab → BookingDetailScreen
                 ├── FieldsTab → AddFieldScreen / EditFieldScreen / SlotManagementScreen
                 └── ProfileTab → KycScreen / EarningsScreen
               FAB → ScannerScreen
```

## Getting Started

```bash
flutter pub get
flutter run
```

Bundle ID: `com.turfin.vendor` | App name: `TurfIn Vendor`
