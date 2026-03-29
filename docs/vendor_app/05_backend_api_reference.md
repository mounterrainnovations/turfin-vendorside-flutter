# 05 — Backend API Reference

All endpoints the vendor app needs. The NestJS backend currently has stubs for most of
these modules. Implement them module-by-module alongside the Flutter screens.

**Base URL:** `http://[your-ip]:3000/api/v1`
**Auth:** All endpoints (except auth ones) require `Authorization: Bearer {accessToken}` header.
**Response envelope:**
```json
{ "data": { ... } }
```
**Error envelope:**
```json
{ "errorCode": "ERROR_CODE", "message": "Human readable message" }
```

---

## Auth Module (Already Implemented)

### POST /auth/signin
Sign in with email + password.

**Request:**
```json
{ "email": "string", "password": "string" }
```
**Response (200):**
```json
{
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "identity": {
      "id": "uuid",
      "email": "vendor@example.com",
      "roles": ["vendor_owner"],
      "profileCompleted": true
    }
  }
}
```
**Errors:** `AUTH_INVALID_CREDENTIALS`, `IDENTITY_BANNED`, `IDENTITY_INACTIVE`

---

### POST /auth/signout
Revokes refresh token. Best-effort.

**Headers:** `Authorization: Bearer {accessToken}`
**Response (200):** `{ "data": { "success": true } }`

---

### POST /auth/refresh
Get new access + refresh tokens using a valid refresh token.

**Request:**
```json
{ "refreshToken": "eyJ..." }
```
**Response (200):**
```json
{
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ..."
  }
}
```
**Errors:** `AUTH_INVALID_REFRESH_TOKEN`, `AUTH_REFRESH_TOKEN_REVOKED`, `AUTH_REFRESH_TOKEN_EXPIRED`

---

## Vendor Module (Stub — needs implementation)

### GET /vendors/me
Get the authenticated vendor's profile.

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "identityId": "uuid",
    "businessName": "Champions Arena",
    "businessType": "individual",
    "ownerFullName": "Rajesh Kumar",
    "address": {
      "street": "123 MG Road",
      "city": "Bangalore",
      "state": "Karnataka",
      "pincode": "560001"
    },
    "commissionPct": "10.00",
    "payoutCycle": "monthly",
    "status": "active",
    "createdAt": "2026-01-15T10:00:00Z"
  }
}
```

---

### PATCH /vendors/me
Update vendor profile (business name, address, etc.)

**Request:**
```json
{
  "businessName": "string",
  "ownerFullName": "string",
  "address": { "street": "string", "city": "string", "state": "string", "pincode": "string" }
}
```
**Response (200):** Updated vendor object (same shape as GET /vendors/me).

---

## Fields Module (Stub — needs implementation)

### GET /fields
Get all fields for the authenticated vendor.

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "vendorId": "uuid",
      "name": "Field A",
      "sports": ["football", "cricket"],
      "amenities": ["parking", "flood_lights"],
      "surfaceType": "artificial_turf",
      "capacity": 22,
      "sizeFormat": "5-a-side",
      "weekdayOpen": "06:00:00",
      "weekdayClose": "23:00:00",
      "weekendOpen": "06:00:00",
      "weekendClose": "23:00:00",
      "standardPricePaise": 60000,
      "cancellationWindowHrs": 24,
      "status": "active",
      "createdAt": "2026-01-15T10:00:00Z"
    }
  ]
}
```

---

### POST /fields
Create a new field.

**Request:**
```json
{
  "name": "Field A",
  "sports": ["football"],
  "amenities": ["parking", "flood_lights"],
  "surfaceType": "artificial_turf",
  "capacity": 22,
  "sizeFormat": "5-a-side",
  "weekdayOpen": "06:00",
  "weekdayClose": "23:00",
  "weekendOpen": "06:00",
  "weekendClose": "23:00",
  "standardPricePaise": 60000,
  "cancellationWindowHrs": 24,
  "address": {
    "street": "123 MG Road",
    "city": "Bangalore",
    "state": "Karnataka"
  }
}
```
**Response (201):** Created field object.
**Note:** Field status defaults to `pending`. Admin must approve before it appears in consumer app.

---

### PATCH /fields/:id
Update an existing field.

**Request:** Partial field object (any subset of POST /fields body).
**Response (200):** Updated field object.

---

### DELETE /fields/:id
Soft-delete a field (sets status to `inactive`).

**Response (200):** `{ "data": { "success": true } }`

---

## Slots Module (Stub — needs implementation)

### GET /slots
Get all slots for a specific field on a specific date.

**Query params:**
- `fieldId` (required): UUID
- `date` (required): `YYYY-MM-DD`

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "fieldId": "uuid",
      "slotDate": "2026-03-29",
      "startTime": "07:00:00",
      "endTime": "08:00:00",
      "pricePaise": 60000,
      "status": "available",
      "blockReason": null
    }
  ]
}
```

---

### POST /slots/generate
Generate hourly slots for a field for one or more dates.
Calls the `fn_generate_slots` Supabase stored function under the hood.

**Request:**
```json
{
  "fieldId": "uuid",
  "fromDate": "2026-03-29",
  "toDate": "2026-03-29"
}
```
**Response (201):**
```json
{
  "data": {
    "slotsCreated": 17,
    "date": "2026-03-29"
  }
}
```

---

### PATCH /slots/:id
Update a slot (block, unblock, or set custom price).

**Request:**
```json
{
  "status": "blocked",
  "blockReason": "maintenance",
  "pricePaise": 80000
}
```
**Response (200):** Updated slot object.

---

### PATCH /slots/bulk
Update multiple slots at once (block/unblock selected).

**Request:**
```json
{
  "slotIds": ["uuid1", "uuid2"],
  "status": "blocked",
  "blockReason": "private_event"
}
```
**Response (200):** `{ "data": { "updated": 2 } }`

---

## Bookings Module (Stub — needs implementation)

### GET /bookings/vendor
Get all bookings for the authenticated vendor's fields.

**Query params (all optional):**
- `status`: `confirmed | cancelled | completed | no_show | pending`
- `fieldId`: UUID — filter by specific field
- `date`: `YYYY-MM-DD` — filter by booking date
- `page`: integer (default: 1)
- `limit`: integer (default: 20)

**Response (200):**
```json
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "customerName": "Arjun Mehta",
        "customerPhone": "9876543210",
        "fieldId": "uuid",
        "fieldName": "Field A",
        "slots": [
          { "slotDate": "2026-03-29", "startTime": "07:00:00", "endTime": "08:00:00" }
        ],
        "totalAmountPaise": 120000,
        "status": "confirmed",
        "bookedAt": "2026-03-28T10:00:00Z",
        "qrCodeData": "{\"bookingId\":\"uuid\",\"customerName\":\"Arjun Mehta\",...}"
      }
    ],
    "total": 42,
    "page": 1,
    "limit": 20
  }
}
```

---

### PATCH /bookings/:id/checkin
Mark a booking as checked in (triggered by QR scan).

**Request:** No body needed.
**Response (200):** `{ "data": { "success": true, "status": "completed" } }`
**Errors:** `BOOKING_NOT_FOUND`, `BOOKING_ALREADY_CHECKED_IN`, `BOOKING_NOT_TODAY`

---

### PATCH /bookings/:id/no-show
Mark a booking as no-show.

**Request:** No body needed.
**Response (200):** `{ "data": { "success": true, "status": "no_show" } }`

---

## KYC Module (Stub — needs implementation)

### GET /kyc
Get the authenticated vendor's KYC status.

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "vendorId": "uuid",
    "status": "not_started",
    "documents": {
      "pan_card": null,
      "aadhaar_front": null,
      "aadhaar_back": null,
      "gst_certificate": null,
      "shop_establishment": null,
      "bank_passbook": null
    },
    "reviewerNotes": null,
    "submittedAt": null
  }
}
```

---

### POST /kyc/submit
Submit KYC documents for review.

**Request:**
```json
{
  "documents": {
    "pan_card": "https://supabase-storage-url/pan_card.jpg",
    "aadhaar_front": "https://supabase-storage-url/aadhaar_front.jpg",
    "aadhaar_back": "https://supabase-storage-url/aadhaar_back.jpg",
    "bank_passbook": "https://supabase-storage-url/bank_passbook.jpg"
  },
  "bankingDetails": {
    "accountHolderName": "Rajesh Kumar",
    "accountNumber": "123456789012",
    "ifscCode": "HDFC0001234",
    "bankName": "HDFC Bank"
  }
}
```
**Response (201):** Updated KYC object with `status: "pending"`.

---

## Payments / Earnings Module (Stub — needs implementation)

### GET /payments/vendor
Get all payments for the vendor's bookings.

**Query params (all optional):**
- `status`: `pending | captured | failed | refunded`
- `page`: integer
- `limit`: integer

**Response (200):**
```json
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "bookingId": "uuid",
        "amountPaise": 120000,
        "status": "captured",
        "gatewayPaymentId": "pay_abc123",
        "paidAt": "2026-03-27T10:15:00Z",
        "booking": {
          "customerName": "Arjun Mehta",
          "fieldName": "Field A",
          "slots": [{ "startTime": "07:00:00", "endTime": "09:00:00" }]
        }
      }
    ],
    "total": 28,
    "summary": {
      "totalEarningsPaise": 4200000,
      "thisMonthPaise": 1240000,
      "lastMonthPaise": 1820000
    }
  }
}
```

---

## Dashboard Module (Stub — new module needed)

### GET /dashboard/vendor
Aggregated stats for the vendor's dashboard.

**Response (200):**
```json
{
  "data": {
    "vendorName": "Rajesh",
    "businessName": "Champions Arena",
    "today": {
      "revenuePaise": 420000,
      "bookingCount": 7,
      "occupancyPct": 82
    },
    "upcomingCheckIns": [
      {
        "bookingId": "uuid",
        "customerName": "Arjun Mehta",
        "fieldName": "Field A",
        "startTime": "07:00:00",
        "slotDate": "2026-03-29",
        "status": "confirmed"
      }
    ]
  }
}
```

---

## Document Upload (Supabase Storage)

KYC documents and vendor profile photos are uploaded directly to Supabase Storage from
the Flutter app (bypasses the backend, same as consumer app avatar upload).

**Bucket:** `vendor-documents` (create this in Supabase Storage)
**Path pattern:** `{vendorId}/{docType}/{timestamp}.jpg`
**Access:** Private bucket — generate signed URLs on-demand from backend.

```dart
// Upload pattern (reuse from consumer app's auth_notifier.dart)
final supabase = Supabase.instance.client;
final path = '$vendorId/$docType/${DateTime.now().millisecondsSinceEpoch}.jpg';
await supabase.storage.from('vendor-documents').uploadBinary(path, bytes);
final url = supabase.storage.from('vendor-documents').getPublicUrl(path);
```

> Note: For KYC docs use a **private** bucket with RLS. For profile photos use the
> existing `avatars` public bucket.

---

## Error Codes Reference (Vendor-specific additions)

| Code | HTTP | When |
|---|---|---|
| `VENDOR_NOT_FOUND` | 404 | Identity has no vendor profile |
| `FIELD_NOT_FOUND` | 404 | Field doesn't exist or not owned by vendor |
| `SLOT_NOT_FOUND` | 404 | Slot doesn't exist for this field |
| `SLOTS_ALREADY_GENERATED` | 409 | Slots for this date already exist |
| `BOOKING_NOT_FOUND` | 404 | Booking doesn't exist for this vendor |
| `BOOKING_ALREADY_CHECKED_IN` | 409 | Already marked complete |
| `BOOKING_NOT_TODAY` | 422 | Can only check-in on booking date |
| `KYC_ALREADY_SUBMITTED` | 409 | Can't re-submit while in_review or verified |
| `KYC_NOT_FOUND` | 404 | KYC record doesn't exist yet |

---

## Implementation Priority for Backend Team

Build in this order to unblock Flutter development:

1. `GET /vendors/me` — needed for Dashboard + Profile screens
2. `GET /fields` — needed for FieldsTab
3. `POST /fields` + `PATCH /fields/:id` — needed for Add/Edit Field
4. `GET /slots?fieldId&date` — needed for SlotManagementScreen
5. `POST /slots/generate` — needed for slot creation
6. `PATCH /slots/:id` + `PATCH /slots/bulk` — needed for block/unblock
7. `GET /bookings/vendor` — needed for BookingsTab + Dashboard
8. `PATCH /bookings/:id/checkin` — needed for Scanner flow
9. `GET /dashboard/vendor` — needed for DashboardTab (can mock until last)
10. `GET /payments/vendor` — needed for EarningsScreen
11. `GET /kyc` + `POST /kyc/submit` — needed for KycScreen
