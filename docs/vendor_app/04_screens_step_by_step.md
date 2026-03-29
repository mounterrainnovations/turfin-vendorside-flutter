# 04 — Screens Step by Step

Every screen the vendor app needs. Build them in this exact order.
Each screen has: purpose, data model, state, UI layout, and navigation wiring.

---

## SCREEN 1 — VendorHomeScreen (App Shell)

**File:** `lib/features/home/presentation/pages/vendor_home_screen.dart`
**Purpose:** Bottom-nav shell with 4 tabs. Acts as the root of the authenticated flow.

### STEP 19 — home_tab_notifier.dart

```dart
// lib/features/home/data/home_tab_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeTabProvider = StateProvider<int>((ref) => 0);
```

### STEP 20 — vendor_home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/home_tab_notifier.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/bookings_tab.dart';
import '../widgets/fields_tab.dart';
import '../widgets/profile_tab.dart';
import '../../../scanner/presentation/pages/scanner_screen.dart';

class VendorHomeScreen extends ConsumerWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(homeTabProvider);

    final tabs = [
      const DashboardTab(),
      const BookingsTab(),
      const FieldsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      body: IndexedStack(
        index: currentTab,
        children: tabs,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScannerScreen()),
        ),
        child: const Icon(Icons.qr_code_scanner, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: currentTab,
        onTap: (i) => ref.read(homeTabProvider.notifier).state = i,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      (Icons.calendar_today_outlined, Icons.calendar_today, 'Bookings'),
      (Icons.sports_soccer_outlined, Icons.sports_soccer, 'Fields'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.black95,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // First 2 tabs
              ...List.generate(2, (i) => Expanded(child: _NavItem(
                icon: items[i].$1,
                activeIcon: items[i].$2,
                label: items[i].$3,
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              ))),
              // Space for FAB
              const SizedBox(width: 64),
              // Last 2 tabs
              ...List.generate(2, (i) => Expanded(child: _NavItem(
                icon: items[i + 2].$1,
                activeIcon: items[i + 2].$2,
                label: items[i + 2].$3,
                isActive: currentIndex == i + 2,
                onTap: () => onTap(i + 2),
              ))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Neon pill indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primary : AppColors.white50,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.white50,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## SCREEN 2 — DashboardTab

**File:** `lib/features/home/presentation/widgets/dashboard_tab.dart`
**Purpose:** Today's snapshot — revenue, booking count, upcoming check-ins.
**State:** Mock first, then `GET /dashboard/vendor` (Phase 2).

### STEP 21 — DashboardTab layout

Layout (top to bottom, all inside `SingleChildScrollView`):

```
[Screen Header]
  "Good morning, {vendorName}" (titleLarge, white)
  "{businessName}" (bodySmall, white60)

[Today's Summary Row] — 3 stat cards side by side
  Card 1: "TODAY'S REVENUE"  →  "₹4,200"  (displayMedium, neon green, glowing)
  Card 2: "BOOKINGS"         →  "7"        (displayMedium, white)
  Card 3: "OCCUPANCY"        →  "82%"      (displayMedium, white)

[Quick Actions Row] — 2 outlined buttons
  [+ Add Slot]   [View All Bookings]

[Upcoming Check-ins Section]
  SectionLabel("NEXT CHECK-INS")
  List of BookingMiniCard (next 3 bookings by start time)
    - Customer name
    - Field name
    - Start time chip (neon green)
    - StatusChip(confirmed)
    - "Scan" icon button (opens ScannerScreen)

[Recent Bookings Section]
  SectionLabel("RECENT BOOKINGS")
  List of BookingMiniCard (last 5 bookings)
    Same card as above but with time passed

[Bottom padding 32px]
```

### DashboardTab mock data model

```dart
// Inline mock — replace with real API in Phase 2
class _DashboardSummary {
  final String vendorName;
  final String businessName;
  final int todayRevenuePaise;
  final int todayBookings;
  final int occupancyPct;

  const _DashboardSummary({
    required this.vendorName,
    required this.businessName,
    required this.todayRevenuePaise,
    required this.todayBookings,
    required this.occupancyPct,
  });
}

// Mock
const _mockSummary = _DashboardSummary(
  vendorName: 'Rajesh',
  businessName: 'Champions Arena',
  todayRevenuePaise: 420000,  // ₹4,200
  todayBookings: 7,
  occupancyPct: 82,
);
```

### Stat Card widget (inline, DashboardTab only)

```dart
Widget _buildStatCard(String label, String value, {bool neon = false}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: neon
            ? [const BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
            color: AppColors.sectionLabel, fontSize: 9,
            fontWeight: FontWeight.bold, letterSpacing: 1.5,
          )),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            color: neon ? AppColors.primary : AppColors.white,
            fontSize: 22, fontWeight: FontWeight.w800,
          )),
        ],
      ),
    ),
  );
}
```

---

## SCREEN 3 — BookingsTab

**File:** `lib/features/home/presentation/widgets/bookings_tab.dart`
**Purpose:** Full list of bookings for this vendor's fields. Filter by status.

### STEP 22 — vendor_booking_model.dart

```dart
// lib/features/bookings/domain/models/vendor_booking_model.dart

enum VendorBookingStatus { confirmed, cancelled, completed, noShow, pending }

class VendorBookingModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String fieldName;
  final DateTime bookingDate;
  final String startTime;    // "07:00 AM"
  final String endTime;      // "09:00 AM"
  final int totalAmountPaise;
  final VendorBookingStatus status;
  final String? qrCodeData;  // JSON string from booking creation

  const VendorBookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.fieldName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmountPaise,
    required this.status,
    this.qrCodeData,
  });

  String get formattedAmount => '₹${(totalAmountPaise / 100).toStringAsFixed(0)}';

  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${bookingDate.day} ${_month(bookingDate.month)}';
  }

  static String _month(int m) => const [
    '', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ][m];
}
```

### STEP 23 — mock_bookings_repository.dart

```dart
// lib/features/bookings/data/mock_bookings_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/vendor_booking_model.dart';

final mockVendorBookingsProvider = Provider<List<VendorBookingModel>>((ref) {
  final now = DateTime.now();
  return [
    VendorBookingModel(
      id: 'BK001',
      customerName: 'Arjun Mehta',
      customerPhone: '9876543210',
      fieldName: 'Field A — Football',
      bookingDate: now,
      startTime: '07:00 AM',
      endTime: '09:00 AM',
      totalAmountPaise: 120000,
      status: VendorBookingStatus.confirmed,
    ),
    VendorBookingModel(
      id: 'BK002',
      customerName: 'Priya Sharma',
      customerPhone: '9812345678',
      fieldName: 'Field B — Cricket',
      bookingDate: now,
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      totalAmountPaise: 80000,
      status: VendorBookingStatus.confirmed,
    ),
    VendorBookingModel(
      id: 'BK003',
      customerName: 'Rahul Singh',
      customerPhone: '9898989898',
      fieldName: 'Field A — Football',
      bookingDate: now.subtract(const Duration(days: 1)),
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      totalAmountPaise: 120000,
      status: VendorBookingStatus.completed,
    ),
    VendorBookingModel(
      id: 'BK004',
      customerName: 'Divya Nair',
      customerPhone: '9900000011',
      fieldName: 'Field B — Cricket',
      bookingDate: now.subtract(const Duration(days: 1)),
      startTime: '08:00 AM',
      endTime: '10:00 AM',
      totalAmountPaise: 80000,
      status: VendorBookingStatus.cancelled,
    ),
    VendorBookingModel(
      id: 'BK005',
      customerName: 'Karan Patel',
      customerPhone: '9111222333',
      fieldName: 'Field A — Football',
      bookingDate: now.add(const Duration(days: 1)),
      startTime: '06:00 AM',
      endTime: '08:00 AM',
      totalAmountPaise: 120000,
      status: VendorBookingStatus.confirmed,
    ),
  ];
});
```

### STEP 24 — BookingsTab layout

```
[Screen Header]
  "Bookings" (titleLarge)

[Filter Pills — horizontal scroll]
  All | Confirmed | Completed | Cancelled | No Show

[Booking List — ListView]
  For each booking:
    VendorCard(
      child: Row(
        Left: Column(
          customerName (bodyLarge, white, bold)
          fieldName (bodySmall, white60)
          "${dateLabel} · ${startTime} – ${endTime}" (bodySmall, white50)
        )
        Right: Column(
          StatusChip(status)
          SizedBox(height: 8)
          Text(formattedAmount, style: neon green, bold, 16px)
        )
      )
      onTap: → BookingDetailScreen(booking)
    )
```

---

## SCREEN 4 — BookingDetailScreen

**File:** `lib/features/bookings/presentation/pages/booking_detail_screen.dart`
**Purpose:** Full detail of one booking. Allows vendor to mark no-show.

### STEP 25 — Layout

```
[Custom Header]
  Back button | "Booking Detail" | StatusChip

[Booking Ref Card]
  SectionLabel("BOOKING REFERENCE")
  "#BK001" (displaySmall, white, bold)
  QR code display area (if qrCodeData present — show 160×160 QR image)
  Note: Use `qr_flutter` package for QR rendering OR show placeholder

[Customer Details Card]
  SectionLabel("CUSTOMER")
  Row: avatar circle (initials) + name + phone
  "Call Customer" → url_launcher tel: link (outlined button)

[Field & Time Card]
  SectionLabel("BOOKING DETAILS")
  Row icon + "Field A — Football"
  Row icon + "${dateLabel}"
  Row icon + "${startTime} – ${endTime}"
  Row icon + "₹{formattedAmount}" (neon green)

[Actions — only if status == confirmed && bookingDate == today]
  ElevatedButton "MARK AS CHECKED IN"  → shows confirmation dialog
  OutlinedButton "MARK NO SHOW"        → shows confirmation dialog (red destructive)
```

> Add `qr_flutter: ^4.1.0` to pubspec.yaml for QR rendering.

---

## SCREEN 5 — ScannerScreen

**File:** `lib/features/scanner/presentation/pages/scanner_screen.dart`
**Purpose:** Camera-based QR scanner for customer check-in at the field.

### STEP 26 — scanner_screen.dart

```dart
// lib/features/scanner/presentation/pages/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _scanned = true);
    _controller.stop();

    final raw = barcode!.rawValue!;
    _showResultSheet(raw);
  }

  void _showResultSheet(String raw) {
    // Parse booking JSON from QR
    // Expected format: {"bookingId":"BK001","customerName":"Arjun Mehta","fieldName":"Field A","startTime":"07:00 AM","endTime":"09:00 AM"}
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScanResultSheet(raw: raw, onDismiss: () {
        Navigator.pop(context);   // close sheet
        Navigator.pop(context);   // close scanner
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Dark overlay with scan window cutout
          _ScanOverlay(),

          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: AppColors.black80,
              padding: const EdgeInsets.fromLTRB(4, 48, 4, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Scan Customer QR',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (_, state, __) => Icon(
                        state.torchState == TorchState.on
                            ? Icons.flash_on : Icons.flash_off,
                        color: AppColors.white,
                      ),
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // Instruction text
          Positioned(
            bottom: 120, left: 0, right: 0,
            child: Text(
              'Point camera at the customer\'s booking QR code',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xAA000000);
    const windowSize = 260.0;
    final left   = (size.width  - windowSize) / 2;
    final top    = (size.height - windowSize) / 2 - 40;
    final rect   = Rect.fromLTWH(left, top, windowSize, windowSize);
    final full   = Rect.fromLTWH(0, 0, size.width, size.height);
    final path   = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Neon corner lines
    final linePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const c = 24.0;
    // Top-left
    canvas.drawLine(Offset(left, top + c), Offset(left, top));
    canvas.drawLine(Offset(left, top), Offset(left + c, top));
    // Top-right
    canvas.drawLine(Offset(left + windowSize - c, top), Offset(left + windowSize, top));
    canvas.drawLine(Offset(left + windowSize, top), Offset(left + windowSize, top + c));
    // Bottom-left
    canvas.drawLine(Offset(left, top + windowSize - c), Offset(left, top + windowSize));
    canvas.drawLine(Offset(left, top + windowSize), Offset(left + c, top + windowSize));
    // Bottom-right
    canvas.drawLine(Offset(left + windowSize - c, top + windowSize), Offset(left + windowSize, top + windowSize));
    canvas.drawLine(Offset(left + windowSize, top + windowSize - c), Offset(left + windowSize, top + windowSize));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ScanResultSheet extends StatelessWidget {
  final String raw;
  final VoidCallback onDismiss;
  const _ScanResultSheet({required this.raw, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    // In Phase 2: parse raw JSON and show booking details + call PATCH /bookings/:id/checkin
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.white20, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(32)),
            child: const Icon(Icons.check_circle, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text('QR Scanned', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Booking ID: $raw', style: const TextStyle(color: AppColors.white60), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(onPressed: onDismiss, child: const Text('DONE')),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

---

## SCREEN 6 — FieldsTab

**File:** `lib/features/home/presentation/widgets/fields_tab.dart`
**Purpose:** List vendor's fields. Add / edit / manage slots.

### STEP 27 — field_model.dart

```dart
// lib/features/fields/domain/models/field_model.dart

enum FieldStatus { active, inactive, pending, maintenance, suspended }

class FieldModel {
  final String id;
  final String name;
  final List<String> sports;
  final List<String> amenities;
  final String surfaceType;
  final int capacity;
  final int standardPricePaise;
  final String weekdayOpen;    // "06:00 AM"
  final String weekdayClose;   // "11:00 PM"
  final String weekendOpen;
  final String weekendClose;
  final FieldStatus status;

  const FieldModel({
    required this.id,
    required this.name,
    required this.sports,
    required this.amenities,
    required this.surfaceType,
    required this.capacity,
    required this.standardPricePaise,
    required this.weekdayOpen,
    required this.weekdayClose,
    required this.weekendOpen,
    required this.weekendClose,
    required this.status,
  });

  String get formattedPrice => '₹${(standardPricePaise / 100).toStringAsFixed(0)}/hr';
}
```

### STEP 28 — mock_fields_repository.dart

```dart
// lib/features/fields/data/mock_fields_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/field_model.dart';

final mockFieldsProvider = Provider<List<FieldModel>>((ref) => [
  const FieldModel(
    id: 'F001',
    name: 'Field A',
    sports: ['football', 'cricket'],
    amenities: ['parking', 'flood_lights', 'changing_room'],
    surfaceType: 'artificial_turf',
    capacity: 22,
    standardPricePaise: 60000,   // ₹600/hr
    weekdayOpen: '06:00 AM',
    weekdayClose: '11:00 PM',
    weekendOpen: '06:00 AM',
    weekendClose: '11:00 PM',
    status: FieldStatus.active,
  ),
  const FieldModel(
    id: 'F002',
    name: 'Field B',
    sports: ['cricket'],
    amenities: ['parking', 'cafeteria'],
    surfaceType: 'natural_grass',
    capacity: 22,
    standardPricePaise: 40000,   // ₹400/hr
    weekdayOpen: '06:00 AM',
    weekdayClose: '10:00 PM',
    weekendOpen: '06:00 AM',
    weekendClose: '10:00 PM',
    status: FieldStatus.active,
  ),
]);
```

### STEP 29 — FieldsTab layout

```
[Screen Header]
  "My Fields" (titleLarge)
  IconButton(Icons.add) → AddFieldScreen

[Field Cards — ListView]
  For each field:
    VendorCard(
      child: Column(
        Row(
          Column(
            field.name (titleLarge, white)
            field.sports.join(', ') (bodySmall, white60)
          )
          Spacer
          StatusChip(field.status)
        )
        SizedBox(height: 12)
        Row(
          _pill(Icons.attach_money, field.formattedPrice)
          SizedBox(width: 8)
          _pill(Icons.group, '${field.capacity} players')
          SizedBox(width: 8)
          _pill(Icons.grass, field.surfaceType)
        )
        Divider(height: 24, color: AppColors.white10)
        Row(
          TextButton("Manage Slots" → SlotManagementScreen(field))
          Spacer
          IconButton(Icons.edit_outlined → EditFieldScreen(field))
        )
      )
    )

[FAB-style "Add Field" button at bottom if list is empty]
```

---

## SCREEN 7 — AddFieldScreen

**File:** `lib/features/fields/presentation/pages/add_field_screen.dart`
**Purpose:** Multi-step form to add a new turf field.

### STEP 30 — AddFieldScreen layout (3-step PageView)

**Step 1 — Basic Info**
```
SectionLabel("STEP 1 OF 3 — FIELD DETAILS")
CustomTextField(hint: 'Field Name', e.g. "Field A")
SectionLabel("SPORTS OFFERED")
Multi-select chips: Football | Cricket | Tennis | Badminton | Basketball | Hockey | Volleyball | Kabaddi
  Tap to select (neon green selected, white10 unselected)
SectionLabel("SURFACE TYPE")
Radio-style select: Artificial Turf | Natural Grass | Concrete | Wooden | Synthetic
CustomTextField(hint: 'Capacity (players)', keyboardType: number)
[Next →] ElevatedButton
```

**Step 2 — Operating Hours & Pricing**
```
SectionLabel("STEP 2 OF 3 — HOURS & PRICING")
SectionLabel("WEEKDAY HOURS")
Row(TimePicker "Opens", TimePicker "Closes")
SectionLabel("WEEKEND HOURS")
Row(TimePicker "Opens", TimePicker "Closes")
SectionLabel("STANDARD PRICE (per hour)")
CustomTextField(hint: '600', prefixIcon: "₹", keyboardType: number)
SectionLabel("CANCELLATION WINDOW")
CustomTextField(hint: '24', suffix: 'hours before booking')
[← Back]  [Next →]
```

**Step 3 — Amenities**
```
SectionLabel("STEP 3 OF 3 — AMENITIES")
Checkbox grid (2 columns):
  ☐ Parking      ☐ Flood Lights
  ☐ Changing Room  ☐ Cafeteria
  ☐ Equipment Rental ☐ First Aid
  ☐ WiFi           ☐ CCTV
  ☐ Drinking Water
[← Back]  [SAVE FIELD] ElevatedButton
```

On save: show loading overlay → POST /fields → on success: show SnackBar "Field added!" → navigate back to FieldsTab.

---

## SCREEN 8 — SlotManagementScreen

**File:** `lib/features/fields/presentation/pages/slot_management_screen.dart`
**Purpose:** View and manage time slots for a specific field on a specific day.

### STEP 31 — slot_model.dart (vendor side)

```dart
// lib/features/fields/domain/models/slot_model.dart

enum VendorSlotStatus { available, booked, blocked, maintenance }

class VendorSlotModel {
  final String id;
  final String fieldId;
  final DateTime slotDate;
  final String startTime;  // "07:00 AM"
  final String endTime;    // "08:00 AM"
  final int pricePaise;
  final VendorSlotStatus status;
  final String? blockReason;

  const VendorSlotModel({
    required this.id,
    required this.fieldId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.pricePaise,
    required this.status,
    this.blockReason,
  });

  String get formattedPrice => '₹${(pricePaise / 100).toStringAsFixed(0)}';
}
```

### STEP 32 — SlotManagementScreen layout

```
[Custom Header]
  Back | "Slot Management" | field.name subtitle

[7-Day Date Strip — horizontal scroll]
  7 date chips from today, tap to switch day
  Active chip: neon green bg, black text
  Inactive: surface bg, white60 text

[Generate Slots Button — if no slots for this day]
  OutlinedButton "GENERATE SLOTS FOR THIS DAY"
  → calls fn_generate_slots via POST /slots/generate { fieldId, date }

[Slots Grid — Wrap widget]
  All slots for selected day in a Wrap
  Cell width: (screen - 32 - gaps) / 3

  Cell variants:
    Available: white10 bg, white60 text, tap → BottomSheet to block or edit price
    Booked:    primaryGlow bg, primary text, tap → show booking mini-detail
    Blocked:   white10 bg, white20 border, white30 text strikethrough, tap → unblock

[Legend Row at bottom]
  ● Available  ● Booked  ● Blocked

[Sticky bottom bar — only when 1+ slots selected]
  "{n} slots selected"
  [Block Selected]  [Set Custom Price]
```

---

## SCREEN 9 — ProfileTab

**File:** `lib/features/home/presentation/widgets/profile_tab.dart`
**Purpose:** Vendor account info, business details, quick links.

### STEP 33 — ProfileTab layout

```
[Screen Header]
  "Profile" (titleLarge)
  IconButton(Icons.settings_outlined) — future settings screen

[Business Card]
  Avatar circle (96×96) — initials fallback, tap to upload photo
  businessName (displaySmall, white, bold)
  vendorStatusChip  (confirmed / pending / suspended)
  ownerFullName (bodyMedium, white60)

[Account Sections]

  SectionLabel("BUSINESS")
  SettingRow("Business Details"  → EditFieldScreen or EditVendorScreen)
  SettingRow("My Fields"         → FieldsTab)
  SettingRow("Earnings"          → EarningsScreen)

  SectionLabel("VERIFICATION")
  SettingRow("KYC Status"        → KycScreen)
    trailing: StatusChip(kycStatus)

  SectionLabel("SUPPORT")
  SettingRow("Help & Support"    → SnackBar "Coming soon")
  SettingRow("Contact TurfIn"    → url_launcher email)

[Logout Button]
  Container with red border (AppColors.error)
  Text "SIGN OUT" in red
  Confirmation dialog before logout
  On confirm: authNotifierProvider.notifier.signOut()
```

### SettingRow widget (inline, ProfileTab only)

```dart
Widget _buildSettingRow(String label, VoidCallback onTap, {Widget? trailing}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.white10)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 15))),
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.white50, size: 20),
        ],
      ),
    ),
  );
}
```

---

## SCREEN 10 — KycScreen

**File:** `lib/features/kyc/presentation/pages/kyc_screen.dart`
**Purpose:** KYC document upload flow. Business + identity verification.

### STEP 34 — kyc_model.dart

```dart
// lib/features/kyc/domain/models/kyc_model.dart

enum KycStatus { notStarted, pending, inReview, verified, rejected }

class KycModel {
  final String vendorId;
  final KycStatus status;
  final Map<String, String?> documents;  // key: docType, value: storageUrl
  final String? reviewerNotes;

  const KycModel({
    required this.vendorId,
    required this.status,
    required this.documents,
    this.reviewerNotes,
  });

  bool get isVerified => status == KycStatus.verified;
  bool get canEdit => status == KycStatus.notStarted || status == KycStatus.rejected;
}
```

### STEP 35 — KycScreen layout

```
[Custom Header]
  Back | "KYC Verification"

[Status Banner]
  If notStarted: white10 bg, "Complete KYC to start accepting bookings"
  If pending/inReview: white10 bg, "Documents under review — usually 24–48 hours"
  If verified: primaryGlow bg, primary text, "Verified ✓"
  If rejected: error tint bg, red text, reviewerNotes

[Document Upload Sections]

  SectionLabel("IDENTITY DOCUMENTS")
  _DocUploadCard("PAN Card",       'pan_card')
  _DocUploadCard("Aadhaar Card",   'aadhaar_front')
  _DocUploadCard("Aadhaar Back",   'aadhaar_back')

  SectionLabel("BUSINESS DOCUMENTS")
  _DocUploadCard("GST Certificate",  'gst_certificate')     — optional
  _DocUploadCard("Shop & Est. Cert", 'shop_establishment')  — optional
  _DocUploadCard("Bank Passbook",    'bank_passbook')

  SectionLabel("BANKING DETAILS")
  CustomTextField(hint: 'Account Holder Name')
  CustomTextField(hint: 'Account Number')
  CustomTextField(hint: 'IFSC Code')
  CustomTextField(hint: 'Bank Name')

[Submit Button — only if canEdit && required docs uploaded]
  ElevatedButton "SUBMIT FOR REVIEW"
  → POST /kyc with all document URLs + banking details
```

### _DocUploadCard widget

```dart
Widget _buildDocUploadCard(String label, String docKey, String? existingUrl, VoidCallback onUpload) {
  final uploaded = existingUrl != null;
  return VendorCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: uploaded ? AppColors.primaryGlow : AppColors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            uploaded ? Icons.check : Icons.upload_file_outlined,
            color: uploaded ? AppColors.primary : AppColors.white50,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(uploaded ? 'Uploaded' : 'Tap to upload',
              style: TextStyle(color: uploaded ? AppColors.primary : AppColors.white50, fontSize: 12)),
          ],
        )),
        if (!uploaded)
          IconButton(icon: const Icon(Icons.add, color: AppColors.white50), onPressed: onUpload),
      ],
    ),
  );
}
```

---

## SCREEN 11 — EarningsScreen

**File:** `lib/features/earnings/presentation/pages/earnings_screen.dart`
**Purpose:** Payment history, payout status, revenue summary.

### STEP 36 — payout_model.dart

```dart
// lib/features/earnings/domain/models/payout_model.dart

enum PayoutStatus { pending, processing, paid, failed }

class PayoutModel {
  final String id;
  final int amountPaise;
  final PayoutStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;

  const PayoutModel({
    required this.id,
    required this.amountPaise,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  String get formattedAmount => '₹${(amountPaise / 100).toStringAsFixed(0)}';
}
```

### STEP 37 — EarningsScreen layout

```
[Custom Header]
  Back | "Earnings"

[Summary Card — neon glow]
  SectionLabel("TOTAL EARNINGS")
  "₹42,000" (displayLarge, neon green, bold)
  Row: "This Month: ₹12,400" | "Last Month: ₹18,200"

[Payout Cycle Info]
  SectionLabel("PAYOUT CYCLE")
  "Monthly — Next payout on 1st April 2026"
  Linked bank account: "HDFC Bank ****4321"

[Transaction History]
  SectionLabel("TRANSACTION HISTORY")
  Filter: All | Received | Pending | Failed

  For each payment:
    VendorCard(
      Row(
        Column(
          "Booking #BK001" (bodyMedium, white)
          "27 Mar 2026 · 07:00 AM – 09:00 AM" (bodySmall, white50)
        )
        Spacer
        Column(
          "+₹1,200" (bodyLarge, neon green, bold)
          StatusChip(captured → confirmed)
        )
      )
    )
```

---

## SCREEN 12 — EditFieldScreen

**File:** `lib/features/fields/presentation/pages/edit_field_screen.dart`
**Purpose:** Edit an existing field's details. Same layout as AddFieldScreen but pre-filled.

### STEP 38

Reuse the `AddFieldScreen` form structure exactly. Pass the existing `FieldModel` as a
constructor parameter. Pre-fill all controllers from the model on `initState`.
Change the submit button to "SAVE CHANGES" and call `PATCH /fields/:id`.

---

## Navigation Summary

```
VendorHomeScreen
  ├── DashboardTab
  │     └── BookingMiniCard → BookingDetailScreen
  ├── BookingsTab
  │     └── BookingCard → BookingDetailScreen
  ├── FieldsTab
  │     ├── AppBar+ button → AddFieldScreen
  │     ├── EditField icon → EditFieldScreen
  │     └── "Manage Slots" → SlotManagementScreen
  ├── ProfileTab
  │     ├── KYC row → KycScreen
  │     └── Earnings row → EarningsScreen
  └── FAB (scanner) → ScannerScreen

All screens push via Navigator.push(MaterialPageRoute(...))
```

---

## Checkpoint 4 ✓

At this point you have:
- All 12 screens implemented with mock data
- Bottom nav with 4 tabs + scanner FAB
- Full booking detail flow
- QR scanner with overlay
- Field management (add/edit/slots)
- KYC upload UI
- Earnings screen
- All navigation wired

**Next: [05_backend_api_reference.md](./05_backend_api_reference.md)**
