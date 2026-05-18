// lib/features/onboarding/presentation/pages/arena_onboarding_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../features/auth/data/auth_notifier.dart';
import '../../../../features/kyc/data/kyc_notifier.dart';
import '../../data/arena_onboarding_notifier.dart';
import '../../data/onboarding_status_notifier.dart';
import 'map_location_picker_screen.dart';

// ── Enum maps (from backend src/common/types/enums.ts) ───────────────────────

const _kSports = <String, String>{
  'football':    'Football',
  'cricket':     'Cricket',
  'tennis':      'Tennis',
  'badminton':   'Badminton',
  'basketball':  'Basketball',
  'hockey':      'Hockey',
  'volleyball':  'Volleyball',
  'kabaddi':     'Kabaddi',
  'box_cricket': 'Box Cricket',
  'futsal':      'Futsal',
  'pickleball':  'Pickleball',
  'throwball':   'Throwball',
  'netball':     'Netball',
  'handball':    'Handball',
  'dodgeball':   'Dodgeball',
};

const _kSurfaces = <String, String>{
  'artificial_turf': 'Artificial Turf',
  'natural_grass':   'Natural Grass',
  'concrete':        'Concrete',
  'wooden':          'Wooden',
  'synthetic':       'Synthetic',
};

const _kAmenities = <String, String>{
  'parking':          'Parking',
  'flood_lights':     'Flood Lights',
  'washrooms':        'Washrooms',
  'changing_rooms':   'Changing Rooms',
  'showers':          'Showers',
  'drinking_water':   'Drinking Water',
  'cafeteria':        'Cafeteria',
  'equipment_rental': 'Equipment Rental',
  'first_aid':        'First Aid',
  'wifi':             'WiFi',
  'cctv':             'CCTV',
  'power_backup':     'Power Backup',
  'locker_facility':  'Locker Facility',
  'seating_area':     'Seating Area',
  'practice_nets':    'Practice Nets',
  'scoreboard':       'Scoreboard',
  'warm_up_area':     'Warm Up Area',
  'music_system':     'Music System',
  'coaching':         'Coaching',
  'referee':          'Referee',
  'covered_turf':     'Covered Turf',
  'indoor_facility':  'Indoor Facility',
  'outdoor_facility': 'Outdoor Facility',
  'bibs_available':   'Bibs Available',
  'prayer_room':      'Prayer Room',
};

const _kIndianStates = <String>[
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
  'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
  'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
  'West Bengal', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Puducherry',
  'Chandigarh', 'Andaman & Nicobar Islands', 'Lakshadweep',
  'Dadra & Nagar Haveli and Daman & Diu',
];

// ── Controller set per turf group ─────────────────────────────────────────────

class _TurfCtrls {
  final price      = TextEditingController();
  final sizeFormat = TextEditingController();
  void dispose() { price.dispose(); sizeFormat.dispose(); }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ArenaOnboardingScreen extends ConsumerStatefulWidget {
  const ArenaOnboardingScreen({super.key});

  @override
  ConsumerState<ArenaOnboardingScreen> createState() =>
      _ArenaOnboardingScreenState();
}

class _ArenaOnboardingScreenState extends ConsumerState<ArenaOnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  // Page 1 controllers
  final _arenaNameCtrl = TextEditingController();

  // Per-turf controllers — kept in sync with arenaOnboardingProvider.turfGroups
  final List<_TurfCtrls> _turfCtrls = [_TurfCtrls()];

  // Page 2 controllers
  final _fullAddressCtrl   = TextEditingController();
  final _houseNumberCtrl   = TextEditingController();
  final _cityCtrl          = TextEditingController();
  final _pinCodeCtrl       = TextEditingController();
  final _landmarkCtrl      = TextEditingController();
  final _googleMapsLinkCtrl = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _arenaNameCtrl.dispose();
    for (final c in _turfCtrls) { c.dispose(); }
    _fullAddressCtrl.dispose();
    _houseNumberCtrl.dispose();
    _cityCtrl.dispose();
    _pinCodeCtrl.dispose();
    _landmarkCtrl.dispose();
    _googleMapsLinkCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  String? _validatePage(int page) {
    final s = ref.read(arenaOnboardingProvider);
    switch (page) {
      case 0:
        if (s.arenaName.trim().isEmpty) return 'Arena name is required.';
        if (s.weekdayOpen.isEmpty)  return 'Weekday opening time is required.';
        if (s.weekdayClose.isEmpty) return 'Weekday closing time is required.';
        if (s.weekendOpen.isEmpty)  return 'Weekend opening time is required.';
        if (s.weekendClose.isEmpty) return 'Weekend closing time is required.';
        for (int i = 0; i < s.turfGroups.length; i++) {
          final g = s.turfGroups[i];
          if (g.sport.isEmpty)       return 'Turf ${i + 1}: Sport is required.';
          if (g.surfaceType.isEmpty) return 'Turf ${i + 1}: Surface type is required.';
          if (g.priceRupees <= 0)    return 'Turf ${i + 1}: Enter a valid price.';
        }
        return null;

      case 1:
        if (s.latitude == null || s.longitude == null) {
          return 'Please pick your arena location on the map.';
        }
        if (s.fullAddress.trim().isEmpty) return 'Street address is required.';
        if (s.city.trim().isEmpty)        return 'City is required.';
        if (s.state.isEmpty)              return 'State is required.';
        if (!RegExp(r'^\d{6}$').hasMatch(s.pinCode.trim())) {
          return 'Enter a valid 6-digit PIN code.';
        }
        return null;

      case 3:
        final kycState = ref.read(kycProvider).valueOrNull;
        if (kycState == null) return 'KYC status is loading. Please wait.';
        for (final field in KycField.values) {
          final fs = kycState.fieldState(field);
          if (fs.status == FieldUploadStatus.idle ||
              fs.status == FieldUploadStatus.uploading) {
            return 'Please upload ${field.label} before continuing.';
          }
        }
        return null;

      default:
        return null;
    }
  }

  void _onNext() {
    final err = _validatePage(_currentPage);
    if (err != null) { setState(() => _errorMessage = err); return; }
    setState(() => _errorMessage = null);
    if (_currentPage < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _onBack() {
    setState(() => _errorMessage = null);
    if (_currentPage == 0) {
      ref.read(authModeProvider.notifier).state = 'account_created';
    } else {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      // Try refreshing first to ensure we have a valid token
      String? token = await authNotifier.refreshAccessToken();
      token ??= await authNotifier.getAccessToken();
      if (token == null) throw 'Session expired. Please sign in again.';
      await ref.read(arenaOnboardingProvider.notifier).submit(token);
      if (!mounted) return;
      ref.invalidate(onboardingStatusProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  // ── Time helpers ───────────────────────────────────────────────────────────

  Future<void> _pickTime(
    BuildContext context,
    String current,
    void Function(String) onPicked,
  ) async {
    TimeOfDay initial = TimeOfDay.now();
    if (current.isNotEmpty) {
      final parts = current.split(':');
      if (parts.length == 2) {
        initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      onPicked('$hh:00');
    }
  }

  // ── Turf group management ──────────────────────────────────────────────────

  void _addTurfGroup() {
    ref.read(arenaOnboardingProvider.notifier).addTurfGroup();
    setState(() => _turfCtrls.add(_TurfCtrls()));
  }

  void _removeTurfGroup(int index) {
    ref.read(arenaOnboardingProvider.notifier).removeTurfGroup(index);
    setState(() {
      _turfCtrls[index].dispose();
      _turfCtrls.removeAt(index);
    });
  }

  // ── Map picker ─────────────────────────────────────────────────────────────

  void _openMapPicker(BuildContext context) {
    final s = ref.read(arenaOnboardingProvider);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          onConfirm: (lat, lng, address) {
            ref.read(arenaOnboardingProvider.notifier).setLocation(lat, lng);
          },
          initialLat:     s.latitude,
          initialLng:     s.longitude,
          initialAddress: null,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    ref.watch(arenaOnboardingProvider);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _onBack,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: tc.onSurface10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: tc.onSurface, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ['Arena Details', 'Arena Location', 'Amenities', 'KYC Documents'][_currentPage],
                          style: TextStyle(
                            color: tc.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Step ${_currentPage + 1} of 4',
                          style: TextStyle(color: tc.onSurface50, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Progress dots
                  Row(
                    children: List.generate(4, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 6),
                      width: i == _currentPage ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? tc.accentText
                            : tc.onSurface20,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Pages ─────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _Page1Details(
                    arenaNameCtrl: _arenaNameCtrl,
                    turfCtrls: _turfCtrls,
                    onAddGroup: _addTurfGroup,
                    onRemoveGroup: _removeTurfGroup,
                    onPickTime: _pickTime,
                  ),
                  _Page2Location(
                    fullAddressCtrl:    _fullAddressCtrl,
                    houseNumberCtrl:    _houseNumberCtrl,
                    cityCtrl:           _cityCtrl,
                    pinCodeCtrl:        _pinCodeCtrl,
                    landmarkCtrl:       _landmarkCtrl,
                    googleMapsLinkCtrl: _googleMapsLinkCtrl,
                    onOpenMap:          _openMapPicker,
                  ),
                  const _Page3Amenities(),
                  const _Page4Kyc(),
                ],
              ),
            ),

            // ── Error ──────────────────────────────────────────────────────
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── CTA ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onNext,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          _currentPage < 3 ? 'NEXT' : 'CREATE ARENA',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1 — Arena Details ────────────────────────────────────────────────────

class _Page1Details extends ConsumerWidget {
  final TextEditingController arenaNameCtrl;
  final List<_TurfCtrls> turfCtrls;
  final VoidCallback onAddGroup;
  final void Function(int) onRemoveGroup;
  final Future<void> Function(BuildContext, String, void Function(String)) onPickTime;

  const _Page1Details({
    required this.arenaNameCtrl,
    required this.turfCtrls,
    required this.onAddGroup,
    required this.onRemoveGroup,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc      = AppThemeColors.of(context);
    final s       = ref.watch(arenaOnboardingProvider);
    final notifier = ref.read(arenaOnboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Arena name
          _Label('Arena Name', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Ace Sports Arena',
            controller: arenaNameCtrl,
            onChanged: notifier.setArenaName,
          ),

          const SizedBox(height: 24),
          _SectionDivider('OPERATING HOURS', tc),
          const SizedBox(height: 16),

          // Weekday hours
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Weekday Open', tc),
                    const SizedBox(height: 6),
                    _TimeTile(
                      value: s.weekdayOpen,
                      placeholder: '09:00',
                      tc: tc,
                      onTap: () => onPickTime(
                        context, s.weekdayOpen, notifier.setWeekdayOpen),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Weekday Close', tc),
                    const SizedBox(height: 6),
                    _TimeTile(
                      value: s.weekdayClose,
                      placeholder: '22:00',
                      tc: tc,
                      onTap: () => onPickTime(
                        context, s.weekdayClose, notifier.setWeekdayClose),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekend hours
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Weekend Open', tc),
                    const SizedBox(height: 6),
                    _TimeTile(
                      value: s.weekendOpen,
                      placeholder: '08:00',
                      tc: tc,
                      onTap: () => onPickTime(
                        context, s.weekendOpen, notifier.setWeekendOpen),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Weekend Close', tc),
                    const SizedBox(height: 6),
                    _TimeTile(
                      value: s.weekendClose,
                      placeholder: '23:00',
                      tc: tc,
                      onTap: () => onPickTime(
                        context, s.weekendClose, notifier.setWeekendClose),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionDivider('TURF CONFIGURATION', tc),
          const SizedBox(height: 4),

          Text(
            'Add one group per turf type. Count creates that many identical turfs.',
            style: TextStyle(color: tc.onSurface50, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),

          // Turf group cards
          ...List.generate(s.turfGroups.length, (i) {
            final group = s.turfGroups[i];
            return _TurfGroupCard(
              index: i,
              group: group,
              ctrls: turfCtrls[i],
              canRemove: s.turfGroups.length > 1,
              tc: tc,
              onChanged: (updated) =>
                  notifier.setTurfGroup(i, updated),
              onRemove: () => onRemoveGroup(i),
            );
          }),

          const SizedBox(height: 12),

          // Add turf group button
          GestureDetector(
            onTap: onAddGroup,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: tc.accentSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: tc.borderDefault,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded,
                      color: tc.accentText, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+ Add Turf Group',
                    style: TextStyle(
                      color: tc.accentText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Turf group card ───────────────────────────────────────────────────────────

class _TurfGroupCard extends StatelessWidget {
  final int index;
  final TurfGroupData group;
  final _TurfCtrls ctrls;
  final bool canRemove;
  final AppThemeColors tc;
  final void Function(TurfGroupData) onChanged;
  final VoidCallback onRemove;

  const _TurfGroupCard({
    required this.index,
    required this.group,
    required this.ctrls,
    required this.canRemove,
    required this.tc,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header row
          Row(
            children: [
              Text(
                'Turf Group ${index + 1}',
                style: TextStyle(
                  color: tc.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.redAccent, size: 18),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Sport dropdown
          _Label('Sport', tc),
          const SizedBox(height: 6),
          _EnumDropdown<String>(
            value: group.sport.isEmpty ? null : group.sport,
            hint: 'Select sport',
            items: _kSports.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => onChanged(group.copyWith(sport: v ?? '')),
            tc: tc,
          ),

          const SizedBox(height: 14),

          // Surface type dropdown
          _Label('Surface Type', tc),
          const SizedBox(height: 6),
          _EnumDropdown<String>(
            value: group.surfaceType.isEmpty ? null : group.surfaceType,
            hint: 'Select surface',
            items: _kSurfaces.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => onChanged(group.copyWith(surfaceType: v ?? '')),
            tc: tc,
          ),

          const SizedBox(height: 14),

          // Size/Format + Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Size / Format', tc),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrls.sizeFormat,
                      onChanged: (v) =>
                          onChanged(group.copyWith(sizeFormat: v)),
                      style: TextStyle(
                          color: tc.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: '7v7',
                        hintStyle: TextStyle(color: tc.onSurface30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Price / Slot ₹', tc),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrls.price,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => onChanged(
                          group.copyWith(priceRupees: int.tryParse(v) ?? 0)),
                      style: TextStyle(
                          color: tc.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: '500',
                        hintStyle: TextStyle(color: tc.onSurface30),
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                            color: tc.onSurface60,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Count stepper
          Row(
            children: [
              Text(
                'Count',
                style: TextStyle(
                    color: tc.onSurface60,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _CountStepper(
                value: group.count,
                tc: tc,
                onDecrement: () {
                  if (group.count > 1) {
                    onChanged(group.copyWith(count: group.count - 1));
                  }
                },
                onIncrement: () {
                  if (group.count < 10) {
                    onChanged(group.copyWith(count: group.count + 1));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Page 2 — Arena Location ───────────────────────────────────────────────────

class _Page2Location extends ConsumerWidget {
  final TextEditingController fullAddressCtrl;
  final TextEditingController houseNumberCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController pinCodeCtrl;
  final TextEditingController landmarkCtrl;
  final TextEditingController googleMapsLinkCtrl;
  final void Function(BuildContext) onOpenMap;

  const _Page2Location({
    required this.fullAddressCtrl,
    required this.houseNumberCtrl,
    required this.cityCtrl,
    required this.pinCodeCtrl,
    required this.landmarkCtrl,
    required this.googleMapsLinkCtrl,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc      = AppThemeColors.of(context);
    final s       = ref.watch(arenaOnboardingProvider);
    final notifier = ref.read(arenaOnboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Map picker tile — mandatory
          _Label('Location on Map', tc),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => onOpenMap(context),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: s.latitude != null
                    ? tc.accentSurface
                    : tc.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: s.latitude != null
                      ? tc.borderDefault
                      : tc.borderDefault,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_pin,
                    color: s.latitude != null
                        ? tc.accentText
                        : tc.onSurface50,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.latitude != null
                          ? '${s.latitude!.toStringAsFixed(5)}, ${s.longitude!.toStringAsFixed(5)}'
                          : 'Tap to pick arena location on map  (required)',
                      style: TextStyle(
                        color: s.latitude != null
                            ? tc.onSurface
                            : tc.onSurface30,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: tc.onSurface50, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          _Label('Street Address', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Building, Street, Area',
            controller: fullAddressCtrl,
            maxLines: 2,
            onChanged: notifier.setFullAddress,
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('House / Shop No.', tc),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: 'e.g. 12A',
                      controller: houseNumberCtrl,
                      onChanged: notifier.setHouseNumber,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('PIN Code', tc),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: '411001',
                      controller: pinCodeCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: notifier.setPinCode,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _Label('City', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Pune',
            controller: cityCtrl,
            onChanged: notifier.setCity,
          ),

          const SizedBox(height: 16),

          _Label('State', tc),
          const SizedBox(height: 6),
          _EnumDropdown<String>(
            value: s.state.isEmpty ? null : s.state,
            hint: 'Select state',
            items: _kIndianStates
                .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                .toList(),
            onChanged: (v) => notifier.setArenaState(v ?? ''),
            tc: tc,
          ),

          const SizedBox(height: 16),

          _Label('Landmark  (optional)', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Near City Mall',
            controller: landmarkCtrl,
            onChanged: notifier.setLandmark,
          ),

          const SizedBox(height: 16),

          _Label('Google Maps Link  (optional)', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'https://maps.google.com/...',
            controller: googleMapsLinkCtrl,
            keyboardType: TextInputType.url,
            onChanged: notifier.setGoogleMapsLink,
          ),
        ],
      ),
    );
  }
}

// ── Page 3 — Amenities ────────────────────────────────────────────────────────

class _Page3Amenities extends ConsumerWidget {
  const _Page3Amenities();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc      = AppThemeColors.of(context);
    final s       = ref.watch(arenaOnboardingProvider);
    final notifier = ref.read(arenaOnboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the amenities available at your arena.',
            style: TextStyle(color: tc.onSurface60, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _kAmenities.entries.map((entry) {
              final isSelected = s.amenities.contains(entry.key);
              return GestureDetector(
                onTap: () {
                  final updated = List<String>.from(s.amenities);
                  if (isSelected) {
                    updated.remove(entry.key);
                  } else {
                    updated.add(entry.key);
                  }
                  notifier.setAmenities(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tc.accentSurface
                        : tc.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? tc.accentText
                          : tc.borderDefault,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_rounded,
                            color: tc.accentText, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? tc.accentText
                              : tc.onSurface,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Page 4 — KYC Documents ────────────────────────────────────────────────────

class _Page4Kyc extends ConsumerStatefulWidget {
  const _Page4Kyc();

  @override
  ConsumerState<_Page4Kyc> createState() => _Page4KycState();
}

class _Page4KycState extends ConsumerState<_Page4Kyc> {
  Future<void> _pickAndUpload(KycField field) async {
    final source = await _chooseSource();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;
    await ref.read(kycProvider.notifier).uploadField(field, File(picked.path));
  }

  Future<ImageSource?> _chooseSource() {
    final tc = AppThemeColors.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: tc.onSurface),
              title: Text('Take Photo',
                  style: TextStyle(
                      color: tc.onSurface, fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: tc.onSurface),
              title: Text('Choose from Gallery',
                  style: TextStyle(
                      color: tc.onSurface, fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final kycAsync = ref.watch(kycProvider);

    return kycAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text('Failed to load KYC status',
            style: TextStyle(color: tc.onSurface60)),
      ),
      data: (kyc) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            'Upload your KYC documents to verify your identity. These are required for arena approval.',
            style: TextStyle(color: tc.onSurface60, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),

          for (final field in KycField.values) ...[
            _KycDocCard(
              field: field,
              fieldState: kyc.fieldState(field),
              onUpload: () => _pickAndUpload(field),
              tc: tc,
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 4),
          Text(
            'Accepted: JPEG, PNG, WEBP, HEIC, HEIF · Max 10 MB each',
            style: TextStyle(
              color: tc.onSurface30,
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _KycDocCard extends StatelessWidget {
  final KycField field;
  final KycFieldState fieldState;
  final VoidCallback onUpload;
  final AppThemeColors tc;

  const _KycDocCard({
    required this.field,
    required this.fieldState,
    required this.onUpload,
    required this.tc,
  });

  Color get _borderColor => switch (fieldState.status) {
    FieldUploadStatus.verified => const Color(0x3322C55E),
    FieldUploadStatus.rejected => const Color(0x33EF4444),
    FieldUploadStatus.uploaded => const Color(0x333B82F6),
    _                          => tc.borderDefault,
  };

  @override
  Widget build(BuildContext context) {
    final isUploading = fieldState.status == FieldUploadStatus.uploading;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    field.label,
                    style: TextStyle(
                      color: tc.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _KycStatusChip(status: fieldState.status),
              ],
            ),
          ),

          if (fieldState.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fieldState.error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (fieldState.signedUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fieldState.signedUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: tc.onSurface10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.insert_drive_file_outlined,
                          color: tc.onSurface30, size: 24),
                    ),
                  ),
                ),
              ),
            ),

          if (fieldState.status != FieldUploadStatus.verified)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: isUploading ? null : onUpload,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color:
                          isUploading ? tc.onSurface20 : tc.borderDefault,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: isUploading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tc.onSurface60,
                          ),
                        )
                      : Icon(
                          fieldState.status == FieldUploadStatus.idle
                              ? Icons.upload_rounded
                              : Icons.refresh_rounded,
                          size: 18,
                          color: tc.onSurface,
                        ),
                  label: Text(
                    isUploading
                        ? 'Uploading…'
                        : fieldState.status == FieldUploadStatus.idle
                            ? 'Upload Document'
                            : 'Replace',
                    style: TextStyle(
                      color:
                          isUploading ? tc.onSurface30 : tc.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _KycStatusChip extends StatelessWidget {
  final FieldUploadStatus status;
  const _KycStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text, String label) = switch (status) {
      FieldUploadStatus.verified  => (const Color(0x1A22C55E), const Color(0xFF22C55E), 'Verified'),
      FieldUploadStatus.rejected  => (const Color(0x1AEF4444), const Color(0xFFEF4444), 'Rejected'),
      FieldUploadStatus.uploaded  => (const Color(0x1A3B82F6), const Color(0xFF3B82F6), 'Uploaded'),
      FieldUploadStatus.uploading => (const Color(0x1AFBBF24), const Color(0xFFFBBF24), 'Uploading'),
      FieldUploadStatus.idle      => (const Color(0x1A94A3B8), const Color(0xFF94A3B8), 'Not uploaded'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: text, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final AppThemeColors tc;
  const _Label(this.text, this.tc);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: tc.onSurface70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _SectionDivider extends StatelessWidget {
  final String label;
  final AppThemeColors tc;
  const _SectionDivider(this.label, this.tc);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: tc.sectionLabel,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: tc.borderDefault, height: 1)),
        ],
      );
}

class _TimeTile extends StatelessWidget {
  final String value;
  final String placeholder;
  final AppThemeColors tc;
  final VoidCallback onTap;

  const _TimeTile({
    required this.value,
    required this.placeholder,
    required this.tc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: value.isNotEmpty ? tc.accentSurface : tc.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value.isNotEmpty ? tc.borderDefault : tc.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: value.isNotEmpty ? tc.accentText : tc.onSurface50,
                  size: 18),
              const SizedBox(width: 10),
              Text(
                value.isNotEmpty ? value : placeholder,
                style: TextStyle(
                  color: value.isNotEmpty ? tc.onSurface : tc.onSurface30,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

class _EnumDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final AppThemeColors tc;

  const _EnumDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.borderDefault),
        ),
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(hint,
              style: TextStyle(color: tc.onSurface30, fontSize: 14)),
          style: TextStyle(
            color: tc.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: tc.surface,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: tc.onSurface50),
        ),
      );
}

class _CountStepper extends StatelessWidget {
  final int value;
  final AppThemeColors tc;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CountStepper({
    required this.value,
    required this.tc,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _StepBtn(
            icon: Icons.remove_rounded,
            enabled: value > 1,
            tc: tc,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$value',
              style: TextStyle(
                color: tc.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            enabled: value < 10,
            tc: tc,
            onTap: onIncrement,
          ),
        ],
      );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final AppThemeColors tc;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.tc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? tc.accentSurface : tc.onSurface10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? tc.borderDefault : tc.borderDefault,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? tc.accentText : tc.onSurface30,
          ),
        ),
      );
}
