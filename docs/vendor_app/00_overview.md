# TurfIn Vendor App — Master Overview

This folder contains the complete step-by-step build guide for the **TurfIn Vendor App** —
a dedicated Flutter application for turf owners and operators. Read every file in order
before writing a single line of code.

---

## File Index (Read in This Order)

| # | File | What It Covers |
|---|---|---|
| 1 | [00_overview.md](./00_overview.md) | This file — context, app purpose, architecture decision |
| 2 | [01_project_setup.md](./01_project_setup.md) | Repo init, pubspec.yaml, folder structure, dependencies |
| 3 | [02_theme_and_design_system.md](./02_theme_and_design_system.md) | Colors, typography, ThemeData, component rules |
| 4 | [03_auth_flow.md](./03_auth_flow.md) | Vendor login, JWT storage, routing, AuthNotifier |
| 5 | [04_screens_step_by_step.md](./04_screens_step_by_step.md) | Every screen — layout, widgets, state, navigation |
| 6 | [05_backend_api_reference.md](./05_backend_api_reference.md) | All backend endpoints the vendor app consumes |
| 7 | [06_feedback_and_checklist.md](./06_feedback_and_checklist.md) | Screen-by-screen QA checklist and feedback loop |

---

## What Is the Vendor App?

The **TurfIn Vendor App** (`turfin-vendor-flutter`) is the operational companion to the
consumer app (`turfin-clientside-flutter`). It is used by **turf owners** (vendors) to:

- Log in with a `vendor_owner` role account
- View today's bookings and earnings on a dashboard
- Manage their turf fields (add, edit, set operating hours, pricing)
- Generate and manage time slots for each field
- Scan customer QR codes at check-in
- Complete KYC (identity + business verification)
- View payment history and payout status
- Receive push notifications for new bookings, cancellations, and payouts

---

## Why a Separate App (Not the Same App)

1. **Different UX mental model** — Vendors manage inventory. Customers browse and book. These
   are fundamentally different journeys and cannot share the same navigation structure.
2. **Database enforces it** — `trg_users_single_role` and `trg_vendors_single_role` triggers in
   Supabase prevent an identity from being both `end_user` and `vendor_owner`. The schema was
   designed for two separate apps from day one.
3. **Different distribution** — Consumer app goes to Play Store / App Store for mass download.
   Vendor app is onboarded (invite-only or direct APK) to specific business operators.
4. **Different update cadences** — Vendor operational features change independently of consumer
   booking features. Separate repos = separate pipelines.

---

## Shared Infrastructure (Do Not Duplicate)

Both apps share:

| Resource | Where It Lives |
|---|---|
| NestJS Backend | `turfin-backend` repo — `http://[IP]:3000/api/v1` |
| Supabase Postgres | Project `kkliofrrmvnohrabowxj` |
| Supabase Storage | `avatars` bucket (profile photos) |
| Design system | Same 3-color palette, Manrope font, dark theme |
| JWT auth scheme | Same `accessToken` + `refreshToken` — different role (`vendor_owner`) |
| Razorpay | Same test/live keys — vendor app uses payout features, not checkout |

---

## Tech Stack Decision

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter (Dart) | Same as consumer app — one team, one skill set |
| State management | Riverpod (`flutter_riverpod: ^2.6.1`) | Same as consumer app — proven, type-safe |
| HTTP | `http: ^1.2.2` | Same as consumer app |
| Auth token storage | `flutter_secure_storage: ^9.2.4` | Same as consumer app |
| Camera / QR scan | `mobile_scanner: ^5.x` | Best-in-class, active maintenance |
| Image upload | `image_picker` + `flutter_image_compress` | Same as consumer app |
| Maps | Not required in v1 | Vendor app is operational, not discovery |
| Notifications | `firebase_messaging` + OneSignal | OneSignal player ID already in DB schema |

---

## Vendor App vs Consumer App — Feature Matrix

| Feature | Consumer App | Vendor App |
|---|---|---|
| Browse turfs | YES | NO |
| Book a slot | YES | NO |
| View my bookings | YES | NO |
| Dashboard (revenue, bookings) | NO | YES |
| Manage fields | NO | YES |
| Generate slots | NO | YES |
| Scan QR at check-in | NO | YES |
| KYC submission | NO | YES |
| Earnings / payouts | NO | YES |
| Auth (login/logout) | YES | YES |
| Profile | YES | YES |
| Push notifications | YES | YES |

---

## Backend Readiness Map

The NestJS backend currently has these modules as stubs (not implemented):
`vendors`, `fields`, `slots`, `bookings`, `payments`, `kyc`, `notifications`.

As you build each screen, the corresponding backend endpoint will need to be implemented
alongside it. [05_backend_api_reference.md](./05_backend_api_reference.md) lists every
endpoint the vendor app requires, with the expected request/response shape so the backend
team can implement them in parallel.

---

## App Name & Bundle ID

| Property | Value |
|---|---|
| App name (display) | `TurfIn Vendor` |
| Flutter project name | `turfin_vendor_flutter` |
| Android bundle ID | `com.turfin.vendor` |
| iOS bundle ID | `com.turfin.vendor` |
| Logo | Same TurfIn neon-green mark — add "VENDOR" badge in white 70% below it |

---

## Navigation Structure (High Level)

```
SplashScreen
  └── VendorLoginScreen (if not authenticated)
        └── VendorHomeScreen (bottom nav — 4 tabs)
              ├── DashboardTab          ← revenue, bookings today, quick stats
              ├── BookingsTab           ← list of all bookings for vendor's fields
              ├── FieldsTab             ← manage fields, slots, pricing
              └── ProfileTab            ← account, KYC, earnings, settings, logout

VendorHomeScreen → BookingDetailScreen
VendorHomeScreen → ScannerScreen (FAB)
FieldsTab → AddFieldScreen / EditFieldScreen
FieldsTab → SlotManagementScreen
ProfileTab → KycScreen
ProfileTab → EarningsScreen
```

---

## Build Order (Recommended Sequence)

Build in this order — each step is a checkpoint you can ship and test independently:

1. **Project scaffold** — repo, pubspec, folder structure, theme files
2. **Splash screen** — app launch, check auth, route
3. **Login screen** — vendor login via backend JWT
4. **App shell** — `VendorHomeScreen` with bottom nav (empty tabs)
5. **Dashboard tab** — mock data first, then wire to backend
6. **Bookings tab** — list + detail screen
7. **Scanner screen** — QR scan modal (FAB)
8. **Fields tab** — field list + add/edit field
9. **Slot management screen** — per-field slot grid
10. **Profile tab** — account info, settings
11. **KYC screen** — document upload flow
12. **Earnings screen** — payment history + payout status
13. **Notifications** — push notification wiring
14. **Backend integration** — swap mock data for real API calls
15. **QA + polish** — run checklist in `06_feedback_and_checklist.md`
