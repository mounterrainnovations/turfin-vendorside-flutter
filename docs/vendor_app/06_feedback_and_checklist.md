# 06 — Feedback Loop & Build Checklist

Use this file as your running QA log. After completing each screen or phase,
check off the items here. If something fails, write the issue and fix under the
relevant section. This file is a living document — update it as you build.

---

## How to Use This File

1. After finishing a screen, go through its checklist
2. For each item: mark `[x]` if passing, `[!]` if failing, `[-]` if skipped/NA
3. Write any bugs or issues in the **Issues Log** section at the bottom
4. Before moving to the next screen, all `[ ]` must be either `[x]` or `[-]`

---

## Phase 1 — Project Setup Checklist

From [01_project_setup.md](./01_project_setup.md)

```
[ ] flutter create completed with correct org (com.turfin) and name (turfin_vendor_flutter)
[ ] pubspec.yaml has all dependencies
[ ] flutter pub get runs without errors
[ ] android minSdk = 21 in build.gradle.kts
[ ] android applicationId = "com.turfin.vendor"
[ ] AndroidManifest.xml has CAMERA + INTERNET permissions
[ ] ios Info.plist has NSCameraUsageDescription + NSPhotoLibraryUsageDescription
[ ] Full folder tree created under lib/
[ ] main.dart has ProviderScope, ThemeMode.dark, SystemChrome portrait lock
[ ] api_config.dart has all endpoint constants
[ ] analysis_options.yaml created
[ ] flutter analyze — ZERO errors
[ ] flutter run — app opens (black screen is correct)
```

---

## Phase 2 — Theme & Design System Checklist

From [02_theme_and_design_system.md](./02_theme_and_design_system.md)

```
[ ] app_colors.dart created — all constants present, no hardcoded colors elsewhere
[ ] app_typography.dart created — Manrope loaded via google_fonts
[ ] app_theme.dart created — darkTheme only, no lightTheme
[ ] main.dart uses AppTheme.darkTheme + ThemeMode.dark
[ ] custom_text_field.dart created
[ ] status_chip.dart created — all 5 variants correct colors
[ ] section_label.dart created — slate color #94A3B8, ALL CAPS, letterSpacing 2.0
[ ] loading_overlay.dart created
[ ] vendor_card.dart created — border always visible (borderDefault)
[ ] Hot reload: app background is pure black (#000000)
[ ] Hot reload: scaffold shows neon green CircularProgressIndicator
[ ] No withOpacity() or withAlpha() calls anywhere in codebase
[ ] flutter analyze — ZERO errors
```

---

## Phase 3 — Auth Flow Checklist

From [03_auth_flow.md](./03_auth_flow.md)

```
[ ] SplashScreen created — shows logo + "VENDOR" badge + spinner
[ ] SplashScreen visible during auth resolution (async state = loading)
[ ] auth_notifier.dart created — AuthState, AuthNotifier, providers
[ ] Token storage keys use "vendor_" prefix (not "backend_" from consumer app)
[ ] app_router.dart watches authNotifierProvider — routes correctly
[ ] vendor_login_screen.dart created

Login Screen UI:
[ ] Logo mark + "TurfIn" + "VENDOR PORTAL" badge visible
[ ] "Welcome back." heading in displaySmall white
[ ] Subtitle text in white60
[ ] Email field with correct keyboard type
[ ] Password field with show/hide toggle
[ ] Error box appears in red tint when credentials wrong
[ ] Sign In button is neon green, full width, 56px height
[ ] Footer note in white30

Auth behavior:
[ ] Correct email + correct vendor password → navigates to VendorHomeScreen
[ ] Wrong password → shows "Incorrect email or password." error
[ ] Banned account → shows correct error
[ ] Non-vendor account (end_user role) → shows "not a vendor" message
[ ] App restart with valid stored token → skips login, goes to VendorHomeScreen
[ ] App restart with no token → shows VendorLoginScreen
[ ] Sign-out from ProfileTab → clears tokens + routes back to VendorLoginScreen
[ ] flutter analyze — ZERO errors
```

---

## Phase 4 — App Shell Checklist

From [04_screens_step_by_step.md](./04_screens_step_by_step.md) — Screen 1

```
[ ] VendorHomeScreen created with IndexedStack (4 tabs)
[ ] Bottom nav has 4 items + center space for FAB
[ ] FAB is neon green, qr_code_scanner icon, opens ScannerScreen
[ ] Tab 0: Dashboard active icon = Icons.dashboard
[ ] Tab 1: Bookings active icon = Icons.calendar_today
[ ] Tab 2: Fields active icon = Icons.sports_soccer
[ ] Tab 3: Profile active icon = Icons.person
[ ] Active tab: neon green icon + neon pill above + bold label
[ ] Inactive tab: white50 icon + no pill + regular weight label
[ ] Switching tabs is instant (IndexedStack preserves state)
[ ] Bottom nav top border: borderSubtle (#222222)
[ ] Bottom nav background: black95 (#F2000000)
[ ] SafeArea wraps bottom nav correctly on iPhone notch
[ ] flutter analyze — ZERO errors
```

---

## Phase 5 — DashboardTab Checklist

```
[ ] DashboardTab renders without errors (mock data)
[ ] "Good morning, {name}" heading visible
[ ] businessName subtitle in white60
[ ] 3 stat cards in a row with equal width
[ ] Revenue card has neon glow shadow
[ ] Revenue number is neon green, 22px bold
[ ] Bookings and Occupancy numbers are white, 22px bold
[ ] Section labels are slate (#94A3B8), ALL CAPS, letterSpacing 1.5
[ ] "NEXT CHECK-INS" section shows 3 upcoming bookings
[ ] Each check-in card shows: customer name, field, time chip, StatusChip(confirmed)
[ ] Scan icon on each check-in opens ScannerScreen
[ ] "RECENT BOOKINGS" section shows last 5
[ ] Scroll works (SingleChildScrollView)
[ ] flutter analyze — ZERO errors
```

---

## Phase 6 — BookingsTab Checklist

```
[ ] BookingsTab renders full list from mockVendorBookingsProvider
[ ] Filter pills horizontally scrollable
[ ] Default filter: "All" — shows all bookings
[ ] "Confirmed" filter shows only confirmed bookings
[ ] "Completed" filter shows only completed
[ ] "Cancelled" filter shows only cancelled
[ ] Booking card: customer name (bold white), field name (white60), date + time (white50)
[ ] Booking card: StatusChip correct variant for each status
[ ] Booking card: amount in neon green bold on right
[ ] Tapping a card navigates to BookingDetailScreen
[ ] Empty state shown when filter returns 0 results
[ ] flutter analyze — ZERO errors
```

---

## Phase 7 — BookingDetailScreen Checklist

```
[ ] Custom header with back button + "Booking Detail" title + StatusChip
[ ] Booking reference "#BK001" in displaySmall bold
[ ] QR code area visible (placeholder or real qr_flutter widget)
[ ] Customer section: initials avatar + name + phone
[ ] "Call Customer" outlined button opens tel: link via url_launcher
[ ] Field & Time card: field name, date, time range, amount (neon green)
[ ] "MARK AS CHECKED IN" button visible when status=confirmed and date=today
[ ] "MARK NO SHOW" outlined destructive button visible same condition
[ ] Confirmation dialog appears for both actions
[ ] After confirming check-in: button disappears or changes to "Checked In"
[ ] flutter analyze — ZERO errors
```

---

## Phase 8 — ScannerScreen Checklist

```
[ ] Camera opens when ScannerScreen navigated to
[ ] Dark overlay with 260×260 cutout visible
[ ] Neon green corner lines on scan window
[ ] Torch toggle button works
[ ] Close button returns to previous screen
[ ] Instruction text below scan window visible
[ ] Scanning a QR code triggers _showResultSheet
[ ] Result sheet shows booking ID / raw data
[ ] "DONE" button on sheet closes sheet and scanner
[ ] Only first scan processed (_scanned flag works)
[ ] flutter analyze — ZERO errors
```

---

## Phase 9 — FieldsTab Checklist

```
[ ] FieldsTab renders 2 mock fields from mockFieldsProvider
[ ] Field card: name (titleLarge), sports list (white60), StatusChip
[ ] Field card pills: price, capacity, surface type
[ ] "Manage Slots" text button navigates to SlotManagementScreen
[ ] Edit icon navigates to EditFieldScreen
[ ] "+ Add Field" icon in header navigates to AddFieldScreen
[ ] Empty state shown when no fields
[ ] flutter analyze — ZERO errors
```

---

## Phase 10 — AddFieldScreen Checklist

```
[ ] 3-step PageView renders correctly
[ ] Step 1: field name input, sports multi-select, surface type select, capacity input
[ ] Sports chips: tap to toggle neon green / white10
[ ] Surface type: radio-style single-select
[ ] "Next" validates: name required, at least 1 sport selected
[ ] Step 2: weekday hours, weekend hours, price, cancellation window
[ ] TimePicker (showTimePicker) works for open/close hours
[ ] Price input: numeric keyboard, ₹ prefix
[ ] Step 3: amenities checkbox grid (9 options)
[ ] "Save Field" shows loading overlay
[ ] On success: SnackBar "Field added!" + pop back
[ ] On error: SnackBar with error message
[ ] Back button on steps 2/3 goes to previous step (not Navigator.pop)
[ ] flutter analyze — ZERO errors
```

---

## Phase 11 — SlotManagementScreen Checklist

```
[ ] 7-day date strip scrollable horizontally
[ ] Active date: neon green bg, black text
[ ] Inactive dates: surface bg, white60 text
[ ] "Generate Slots" button shown when no slots for selected day
[ ] Slots grid renders in Wrap layout (3 per row)
[ ] Available slot: white10 bg, white60 text
[ ] Booked slot: primaryGlow bg, primary text (non-tappable action)
[ ] Blocked slot: white10 bg, strikethrough white30 text
[ ] Tapping available slot: BottomSheet with block/edit price options
[ ] Tapping blocked slot: shows unblock option
[ ] Legend row at bottom visible
[ ] flutter analyze — ZERO errors
```

---

## Phase 12 — ProfileTab Checklist

```
[ ] Business card: avatar circle (initials), businessName, vendorStatusChip, ownerFullName
[ ] Avatar tap opens image picker (future: upload to storage)
[ ] Section labels: "BUSINESS", "VERIFICATION", "SUPPORT"
[ ] Setting rows have chevron icons and correct navigation
[ ] "KYC Status" row has StatusChip(kycStatus) as trailing
[ ] Sign Out button: red border, red text
[ ] Confirmation dialog appears before logout
[ ] On confirm: tokens cleared + routes to VendorLoginScreen
[ ] flutter analyze — ZERO errors
```

---

## Phase 13 — KycScreen Checklist

```
[ ] Status banner correct for each KycStatus variant
[ ] "not_started" banner: white10 bg, instructions text
[ ] "verified" banner: primaryGlow bg, neon green text, checkmark
[ ] "rejected" banner: red tint bg, red text, reviewerNotes shown
[ ] Document upload cards: 6 cards (3 identity + 3 business)
[ ] Uploaded card: neon check icon, "Uploaded" text in primary
[ ] Not-uploaded card: white upload icon, "Tap to upload" in white50
[ ] Tapping upload card: image picker opens
[ ] Banking details: 4 text fields
[ ] "Submit for Review" only enabled when required docs uploaded
[ ] Loading overlay during submission
[ ] On success: banner updates to "pending" state
[ ] flutter analyze — ZERO errors
```

---

## Phase 14 — EarningsScreen Checklist

```
[ ] Summary card: total earnings in displayLarge neon green with glow
[ ] "This Month" and "Last Month" figures visible in white60
[ ] Payout cycle info card visible
[ ] Transaction list renders (mock data)
[ ] Amount in neon green with "+" prefix
[ ] StatusChip correct per payment status
[ ] Filter pills work (All / Received / Pending / Failed)
[ ] flutter analyze — ZERO errors
```

---

## Phase 15 — Backend Integration Checklist

Replace mock data with real API calls, module by module.

```
[ ] GET /vendors/me — ProfileTab shows real vendor name + status
[ ] GET /vendors/me — DashboardTab shows real vendor name
[ ] GET /fields — FieldsTab shows real fields from backend
[ ] POST /fields — AddFieldScreen creates real field
[ ] PATCH /fields/:id — EditFieldScreen updates real field
[ ] GET /slots?fieldId&date — SlotManagementScreen shows real slots
[ ] POST /slots/generate — Generate button creates real slots
[ ] PATCH /slots/:id — Block/unblock individual slots
[ ] PATCH /slots/bulk — Bulk block works
[ ] GET /bookings/vendor — BookingsTab shows real bookings
[ ] GET /bookings/vendor — DashboardTab shows real upcoming check-ins
[ ] PATCH /bookings/:id/checkin — QR scan check-in confirmed in DB
[ ] GET /payments/vendor — EarningsScreen shows real payment history
[ ] GET /dashboard/vendor — DashboardTab stats from real aggregation
[ ] GET /kyc — KycScreen shows real KYC status
[ ] POST /kyc/submit — KYC submission creates real record
[ ] 401 handling: expired token → auto-refresh → retry → logout if refresh fails
[ ] flutter analyze — ZERO errors
[ ] No mock repositories imported anywhere in production code
```

---

## Phase 16 — Final Polish Checklist

```
[ ] App name "TurfIn Vendor" shows in recent apps
[ ] Status bar icons are light (white) on black background
[ ] Safe area respected on iPhone notch and Android gesture bar
[ ] Keyboard doesn't overlap input fields (resizeToAvoidBottomInset: true)
[ ] All loading states show CircularProgressIndicator (neon green)
[ ] All error states show readable error message (not stack trace)
[ ] Network error shows "No internet connection. Please check your network."
[ ] All "Coming Soon" features show SnackBar (no empty taps)
[ ] Back navigation works on all screens
[ ] App doesn't crash when camera permission denied (ScannerScreen shows error)
[ ] App doesn't crash when photo library permission denied (KYC upload shows error)
[ ] Large text accessibility: no text overflow on any screen at font scale 1.5×
[ ] flutter analyze — ZERO errors
[ ] flutter test — all tests pass
[ ] flutter build apk — builds successfully
[ ] Install on physical Android device and smoke test all flows
```

---

## Issues Log

Use this section to record bugs as you find them.
Format: `[SCREEN] Description → Fix applied`

```
Example:
[ScannerScreen] App crashes when camera permission denied → Added try/catch around
  MobileScannerController init, show error SnackBar if PlatformException thrown.

[Your issues go here]
```

---

## Prompts for AI-Assisted Development

When you're building each screen with Claude Code, use these prompt templates for
consistency. Copy-paste and fill in the `[...]` parts.

### Starting a new screen:
```
I'm building the [ScreenName] for the TurfIn Vendor app.
Read docs/vendor_app/04_screens_step_by_step.md for the layout spec.
Read docs/vendor_app/02_theme_and_design_system.md for all component rules.
The screen file should go at lib/features/[feature]/presentation/pages/[screen_name].dart.
Use AppColors, AppTypography, VendorCard, StatusChip, SectionLabel from core/widgets/.
Data model is [ModelName] from lib/features/[feature]/domain/models/.
Mock data provider is [providerName] from lib/features/[feature]/data/.
```

### After completing a screen:
```
I've finished [ScreenName]. Check the screen against the checklist in
docs/vendor_app/06_feedback_and_checklist.md — Phase [N].
Run flutter analyze and fix any issues found.
```

### Wiring a real API endpoint:
```
Replace the mock data in [ScreenName] with a real API call.
The endpoint is [METHOD] [path] — see docs/vendor_app/05_backend_api_reference.md.
Use the authNotifierProvider.notifier.getAccessToken() for the Bearer token.
Handle loading state with AsyncValue, show CircularProgressIndicator while loading,
show error message if failed.
```

### Debugging a UI issue:
```
[ScreenName] has this issue: [describe exactly what looks wrong].
Read the current file at lib/features/[...].dart.
Check it against the spec in docs/vendor_app/04_screens_step_by_step.md Step [N].
The issue is likely [color / spacing / widget sizing / missing SafeArea / etc.].
Fix it and run flutter analyze.
```

---

## Definition of Done

A feature is **done** when:
1. All checklist items for that screen are `[x]`
2. `flutter analyze` reports zero errors
3. Screen has been tested on both Android (physical device) and iOS (simulator or device)
4. No hardcoded colors, text styles, or magic numbers
5. All navigation paths work (forward and back)
6. Error states are handled gracefully

A phase is **done** when:
1. All screens in that phase are done (per above)
2. The Issues Log has no open items for that phase
3. PROGRESS.md in the vendor app repo has been updated
