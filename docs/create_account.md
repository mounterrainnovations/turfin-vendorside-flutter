# Vendor Create Account — Feature Documentation

## Overview

This document describes the end-to-end vendor account creation flow in the Turfin Vendor app. A new vendor fills a 4-page signup form, their account is created via the backend API, and they are directed to the onboarding flow to complete turf setup.

---

## Screen Flow

```
VendorWelcomeScreen
       │ tap CREATE ACCOUNT
       ▼
VendorSignupScreen (4 pages)
  ├─ Page 1: Account Details  (email, password, confirm password)
  ├─ Page 2: Business Info    (owner name, business name, type, phone)
  ├─ Page 3: Address          (type, city, state, pin code, country)
  └─ Page 4: Banking Details  (bank name, account holder, account number, IFSC)
       │ tap CREATE ACCOUNT (on page 4)
       │ → POST /api/v1/auth/signup
       ▼
VendorOtpScreen  ← MOCK — no real OTP sent
       │ tap VERIFY
       ▼
AccountCreatedScreen
       │ tap CONTINUE TO ONBOARDING
       ▼
VendorOnboardingScreen (existing flow)
```

---

## API Endpoint

**POST** `/api/v1/auth/signup`

- Authentication: None (public route)
- No backend changes were made

### Request Payload

```json
{
  "email": "vendor@example.com",
  "password": "securepass123",
  "role": "vendor_owner",
  "firstName": "Rajesh Kumar",
  "displayName": "Rajesh Kumar",
  "vendorProfile": {
    "ownerFullName": "Rajesh Kumar",
    "businessName": "Green Turf Arena",
    "businessType": "individual",
    "phone": "+919876543210",
    "address": {
      "type": "work",
      "city": "Pune",
      "state": "Maharashtra",
      "pinCode": "411001",
      "country": "India"
    },
    "bankingDetails": {
      "bankName": "HDFC Bank",
      "accountHolderName": "Rajesh Kumar",
      "accountNumber": "00012345678901",
      "ifsc": "HDFC0001234"
    }
  }
}
```

### Field-to-Screen Mapping

| Request Field | Collected From | Screen | Page |
|---------------|---------------|--------|------|
| `email` | User input | VendorSignupScreen | 1 |
| `password` | User input | VendorSignupScreen | 1 |
| `role` | Fixed: `"vendor_owner"` | Code | — |
| `firstName` | Same as ownerFullName | Code | — |
| `displayName` | Same as ownerFullName | Code | — |
| `vendorProfile.ownerFullName` | User input | VendorSignupScreen | 2 |
| `vendorProfile.businessName` | User input | VendorSignupScreen | 2 |
| `vendorProfile.businessType` | User selection | VendorSignupScreen | 2 |
| `vendorProfile.phone` | User input | VendorSignupScreen | 2 |
| `vendorProfile.address.type` | User selection | VendorSignupScreen | 3 |
| `vendorProfile.address.city` | User input | VendorSignupScreen | 3 |
| `vendorProfile.address.state` | User input | VendorSignupScreen | 3 |
| `vendorProfile.address.pinCode` | User input | VendorSignupScreen | 3 |
| `vendorProfile.address.country` | User input (default: India) | VendorSignupScreen | 3 |
| `vendorProfile.bankingDetails.bankName` | User input | VendorSignupScreen | 4 |
| `vendorProfile.bankingDetails.accountHolderName` | User input | VendorSignupScreen | 4 |
| `vendorProfile.bankingDetails.accountNumber` | User input | VendorSignupScreen | 4 |
| `vendorProfile.bankingDetails.ifsc` | User input (auto-uppercased) | VendorSignupScreen | 4 |

### Response Shape

```json
{
  "data": {
    "accessToken": "<jwt>",
    "refreshToken": "<jwt>",
    "identity": {
      "id": "uuid",
      "email": "vendor@example.com",
      "roles": ["vendor_owner"],
      "permissions": [],
      "profileCompleted": true
    }
  }
}
```

On success, `accessToken`, `refreshToken`, `identityId`, and `email` are stored in `FlutterSecureStorage`.

---

## Client-Side Validation Rules

| Field | Rule |
|-------|------|
| Email | Non-empty, must contain `@` |
| Password | Min 8 characters |
| Confirm Password | Must match password exactly |
| Owner Full Name | Non-empty |
| Business Name | Non-empty |
| Business Type | Selected from dropdown |
| Phone | Non-empty |
| City | Non-empty |
| State | Non-empty |
| Pin Code | Non-empty |
| Country | Non-empty (default: India) |
| Bank Name | Non-empty |
| Account Holder Name | Non-empty |
| Account Number | Non-empty |
| IFSC Code | Non-empty (auto-uppercased) |

---

## Error Codes & Messages

| Backend Error Code | User-Facing Message |
|-------------------|---------------------|
| `AUTH_EMAIL_ALREADY_EXISTS` | An account with this email already exists. |
| `AUTH_INVALID_CREDENTIALS` | Incorrect email or password. |
| `IDENTITY_BANNED` | Your account has been suspended. Contact support. |
| `IDENTITY_INACTIVE` | Your account is inactive. Contact support. |
| `AUTH_SIGNUP_FAILED` | Signup failed. Please try again. |
| *(any other)* | Something went wrong. Please try again. |

---

## DB Records Created on Success

| Table | What's written |
|-------|---------------|
| `identities` | Email, status = active |
| `identity_roles` | role = vendor_owner |
| `vendors` | All business, address, banking fields; status = pending |
| `vendor_kyc` | Empty KYC record (status = not_started) |

---

## Known Limitations

| Limitation | Status |
|-----------|--------|
| OTP verification is mock (no SMS sent) | Pending — needs SMS/OTP provider integration |
| Password reset not implemented | Out of scope for this phase |
| Google / Apple sign-in | Placeholder buttons on login screen only |

---

## Files Changed

| File | Change |
|------|--------|
| `lib/core/config/api_config.dart` | Fixed IP to `192.168.1.5`; added `signUp` URL |
| `lib/features/auth/data/auth_notifier.dart` | Added `SignupFormData` class + `signUp()` method; added `AUTH_EMAIL_ALREADY_EXISTS` error mapping |
| `lib/core/routing/app_router.dart` | Added `pendingPhoneProvider`; added routes for `signup`, `otp`, `account_created` |
| `lib/features/auth/presentation/pages/vendor_welcome_screen.dart` | Wired CREATE ACCOUNT button to navigate to signup screen |
| `lib/features/auth/presentation/pages/vendor_signup_screen.dart` | **NEW** — 4-page signup form |
| `lib/features/auth/presentation/pages/vendor_otp_screen.dart` | **NEW** — mock OTP screen |
| `lib/features/auth/presentation/pages/account_created_screen.dart` | **NEW** — success screen |
| `docs/create_account.md` | **NEW** — this document |
