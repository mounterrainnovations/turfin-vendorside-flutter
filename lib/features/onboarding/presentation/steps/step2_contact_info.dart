// lib/features/onboarding/presentation/steps/step2_contact_info.dart
// Step 3 of 5 — Arena Setup

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/arena_options_provider.dart';
import '../../data/onboarding_notifier.dart';
import '../pages/map_location_picker_screen.dart';
import '../widgets/onboarding_widgets.dart';

const _indianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
  'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
  'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
  'West Bengal', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Puducherry',
  'Chandigarh', 'Andaman & Nicobar Islands', 'Lakshadweep',
  'Dadra & Nagar Haveli and Daman & Diu',
];

const _slotDurations = [
  '30 min', '45 min', '60 min (1 hr)', '90 min', '120 min (2 hrs)',
];

class Step2ArenaSetup extends ConsumerStatefulWidget {
  const Step2ArenaSetup({super.key});

  @override
  ConsumerState<Step2ArenaSetup> createState() => _Step2State();
}

class _Step2State extends ConsumerState<Step2ArenaSetup> {
  late final TextEditingController _arenaNameCtrl;
  late final TextEditingController _arenaDescCtrl;
  late final TextEditingController _fullAddressCtrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _weekdayPriceCtrl;
  late final TextEditingController _weekendPriceCtrl;
  late final TextEditingController _peakHourPriceCtrl;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final s = ref.read(vendorOnboardingProvider);
    _arenaNameCtrl    = TextEditingController(text: s.arenaName);
    _arenaDescCtrl    = TextEditingController(text: s.arenaDescription);
    _fullAddressCtrl  = TextEditingController(text: s.fullAddress);
    _landmarkCtrl     = TextEditingController(text: s.landmark);
    _cityCtrl         = TextEditingController(text: s.city);
    _stateCtrl        = TextEditingController(text: s.arenaState);
    _pincodeCtrl      = TextEditingController(text: s.pincode);
    _weekdayPriceCtrl = TextEditingController(text: s.weekdayPrice);
    _weekendPriceCtrl = TextEditingController(text: s.weekendPrice);
    _peakHourPriceCtrl = TextEditingController(text: s.peakHourPrice);
  }

  @override
  void dispose() {
    _arenaNameCtrl.dispose();
    _arenaDescCtrl.dispose();
    _fullAddressCtrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _weekdayPriceCtrl.dispose();
    _weekendPriceCtrl.dispose();
    _peakHourPriceCtrl.dispose();
    super.dispose();
  }

  // ── Media helpers ─────────────────────────────────────────────────────────

  Future<void> _pickCoverPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      ref.read(vendorOnboardingProvider.notifier).setCoverPhoto(file.path);
    }
  }

  Future<void> _addGalleryPhotos() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty && mounted) {
      final existing =
          ref.read(vendorOnboardingProvider).galleryPhotoPaths;
      ref
          .read(vendorOnboardingProvider.notifier)
          .setGalleryPhotos([...existing, ...files.map((f) => f.path)]);
    }
  }

  Future<void> _addVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null && mounted) {
      final existing = ref.read(vendorOnboardingProvider).videoPaths;
      ref
          .read(vendorOnboardingProvider.notifier)
          .setVideos([...existing, file.path]);
    }
  }

  // ── Time picker ───────────────────────────────────────────────────────────

  Future<void> _pickTime(BuildContext context, bool isOpening) async {
    final notifier = ref.read(vendorOnboardingProvider.notifier);
    final s = ref.read(vendorOnboardingProvider);
    final currentStr = isOpening ? s.openingTime : s.closingTime;

    TimeOfDay initial = TimeOfDay.now();
    if (currentStr.isNotEmpty) {
      final parts = currentStr.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1].split(' ')[0]) ?? 0;
        initial = TimeOfDay(hour: h, minute: m);
      }
    }

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      final formatted = _formatTime(picked);
      if (isOpening) {
        notifier.setOpeningTime(formatted);
      } else {
        notifier.setClosingTime(formatted);
      }
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // ── Open map location picker ──────────────────────────────────────────────

  void _openMapPicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapLocationPickerScreen(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s        = ref.watch(vendorOnboardingProvider);
    final notifier = ref.read(vendorOnboardingProvider.notifier);
    final tc       = AppThemeColors.of(context);

    final sportsAsync    = ref.watch(sportsOptionsProvider);
    final amenitiesAsync = ref.watch(amenitiesOptionsProvider);

    final sportsList = sportsAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const <String>[
        'Football', 'Cricket', 'Badminton', 'Box Cricket',
        'Pickleball', 'Tennis', 'Others',
      ],
    );
    final amenitiesList = amenitiesAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const <String>[
        'Parking', 'Washroom', 'Drinking Water', 'Flood Lights',
        'Seating Area', 'Changing Room', 'Cafeteria', 'Shower',
        'Equipment Rental', 'WiFi', 'Other Amenities',
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ════════════════════════════════════════════════════════════
          // SECTION A — Arena Basic Details
          // ════════════════════════════════════════════════════════════
          const OnbSectionHeader(
            section: 'SECTION A',
            title: 'Arena Basic Details',
          ),

          const OnbFieldLabel('Arena Name'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Ace Sports Arena',
            controller: _arenaNameCtrl,
            onChanged: notifier.setArenaName,
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Arena Description'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Describe your arena, facilities, unique features…',
            controller: _arenaDescCtrl,
            maxLines: 3,
            onChanged: notifier.setArenaDescription,
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Sports Available'),
          const SizedBox(height: 6),
          OnbMultiSelectTile(
            selected: s.sportsAvailable,
            placeholder: 'Select sports',
            onTap: () async {
              final result = await showOnbMultiSelectPicker(
                context,
                title: 'Sports Available',
                options: sportsList,
                selected: s.sportsAvailable,
              );
              if (result != null) notifier.setSports(result);
            },
          ),
          if (s.sportsAvailable.isNotEmpty) ...[
            const SizedBox(height: 8),
            OnbSelectedChips(items: s.sportsAvailable),
          ],

          const OnbSectionDivider(),

          // ════════════════════════════════════════════════════════════
          // SECTION B — Location Details
          // ════════════════════════════════════════════════════════════
          const OnbSectionHeader(
            section: 'SECTION B',
            title: 'Location Details',
          ),

          const OnbFieldLabel('Full Address'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Building, Street, Area',
            controller: _fullAddressCtrl,
            maxLines: 2,
            onChanged: notifier.setFullAddress,
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Landmark', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Near City Mall',
            controller: _landmarkCtrl,
            onChanged: notifier.setLandmark,
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('City'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: 'Mumbai',
                      controller: _cityCtrl,
                      onChanged: notifier.setCity,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('Pincode'),
                    const SizedBox(height: 6),
                    _PincodeField(
                      controller: _pincodeCtrl,
                      onChanged: notifier.setPincode,
                      tc: tc,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('State'),
          const SizedBox(height: 6),
          OnbDropdownTile(
            value: s.arenaState.isEmpty ? null : s.arenaState,
            placeholder: 'Select state',
            onTap: () async {
              final result = await showOnbOptionPicker(
                context,
                title: 'State',
                options: _indianStates,
                selected: s.arenaState.isEmpty ? null : s.arenaState,
              );
              if (result != null) notifier.setArenaState(result);
            },
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Location on Map'),
          const SizedBox(height: 6),
          _MapLocationTile(
            address: s.mapAddress,
            isSet: s.mapLat != null,
            tc: tc,
            onTap: () => _openMapPicker(context),
          ),

          const OnbSectionDivider(),

          // ════════════════════════════════════════════════════════════
          // SECTION C — Turf Media Upload
          // ════════════════════════════════════════════════════════════
          const OnbSectionHeader(
            section: 'SECTION C',
            title: 'Turf Media Upload',
          ),

          const OnbFieldLabel('Turf Cover Photo'),
          const SizedBox(height: 6),
          _CoverPhotoTile(
            path: s.coverPhotoPath,
            tc: tc,
            onTap: _pickCoverPhoto,
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Gallery Photos', optional: true),
          const SizedBox(height: 6),
          _GalleryRow(
            paths: s.galleryPhotoPaths,
            tc: tc,
            onAdd: _addGalleryPhotos,
            onRemove: (i) {
              final list = List<String>.from(s.galleryPhotoPaths)..removeAt(i);
              notifier.setGalleryPhotos(list);
            },
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Videos', optional: true),
          const SizedBox(height: 6),
          _VideoList(
            paths: s.videoPaths,
            tc: tc,
            onAdd: _addVideo,
            onRemove: (i) {
              final list = List<String>.from(s.videoPaths)..removeAt(i);
              notifier.setVideos(list);
            },
          ),

          const OnbSectionDivider(),

          // ════════════════════════════════════════════════════════════
          // SECTION D — Amenities
          // ════════════════════════════════════════════════════════════
          const OnbSectionHeader(
            section: 'SECTION D',
            title: 'Amenities',
          ),

          const OnbFieldLabel('Available Amenities'),
          const SizedBox(height: 6),
          OnbMultiSelectTile(
            selected: s.amenities,
            placeholder: 'Select amenities',
            onTap: () async {
              final result = await showOnbMultiSelectPicker(
                context,
                title: 'Amenities',
                options: amenitiesList,
                selected: s.amenities,
              );
              if (result != null) notifier.setAmenities(result);
            },
          ),
          if (s.amenities.isNotEmpty) ...[
            const SizedBox(height: 8),
            OnbSelectedChips(items: s.amenities),
          ],

          const OnbSectionDivider(),

          // ════════════════════════════════════════════════════════════
          // SECTION E — Pricing & Timings
          // ════════════════════════════════════════════════════════════
          const OnbSectionHeader(
            section: 'SECTION E',
            title: 'Pricing & Timings',
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('Opening Time'),
                    const SizedBox(height: 6),
                    OnbTimePickerTile(
                      value: s.openingTime.isEmpty ? null : s.openingTime,
                      placeholder: '09:00 AM',
                      onTap: () => _pickTime(context, true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('Closing Time'),
                    const SizedBox(height: 6),
                    OnbTimePickerTile(
                      value: s.closingTime.isEmpty ? null : s.closingTime,
                      placeholder: '10:00 PM',
                      onTap: () => _pickTime(context, false),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Available Days'),
          const SizedBox(height: 10),
          OnbDayPicker(
            selected: s.availableDays,
            onChanged: notifier.setAvailableDays,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('Weekday Price'),
                    const SizedBox(height: 6),
                    _PriceField(
                      hint: '500',
                      controller: _weekdayPriceCtrl,
                      onChanged: notifier.setWeekdayPrice,
                      tc: tc,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('Weekend Price'),
                    const SizedBox(height: 6),
                    _PriceField(
                      hint: '700',
                      controller: _weekendPriceCtrl,
                      onChanged: notifier.setWeekendPrice,
                      tc: tc,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Peak Hour Price', optional: true),
          const SizedBox(height: 6),
          _PriceField(
            hint: '900',
            controller: _peakHourPriceCtrl,
            onChanged: notifier.setPeakHourPrice,
            tc: tc,
          ),

          const SizedBox(height: 16),

          const OnbFieldLabel('Slot Duration'),
          const SizedBox(height: 6),
          OnbDropdownTile(
            value: s.slotDuration.isEmpty ? null : s.slotDuration,
            placeholder: 'Select duration',
            onTap: () async {
              final result = await showOnbOptionPicker(
                context,
                title: 'Slot Duration',
                options: _slotDurations,
                selected: s.slotDuration.isEmpty ? null : s.slotDuration,
              );
              if (result != null) notifier.setSlotDuration(result);
            },
          ),

        ],
      ),
    );
  }
}

// ── Map location tile ─────────────────────────────────────────────────────────

class _MapLocationTile extends StatelessWidget {
  final String address;
  final bool isSet;
  final AppThemeColors tc;
  final VoidCallback onTap;

  const _MapLocationTile({
    required this.address,
    required this.isSet,
    required this.tc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSet ? AppColors.primarySubtle : tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSet ? AppColors.primary70 : tc.borderDefault,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.location_pin,
              color: isSet ? AppColors.primary : tc.onSurface50,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSet && address.isNotEmpty ? address : 'Tap to pick location on map',
                style: TextStyle(
                  color: isSet ? tc.onSurface : tc.onSurface30,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: tc.onSurface50, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Cover photo upload tile ───────────────────────────────────────────────────

class _CoverPhotoTile extends StatelessWidget {
  final String? path;
  final AppThemeColors tc;
  final VoidCallback onTap;

  const _CoverPhotoTile({
    required this.path,
    required this.tc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        decoration: BoxDecoration(
          color: path != null ? Colors.transparent : tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: path != null ? AppColors.primary70 : tc.borderDefault,
            width: path != null ? 1.5 : 1.0,
          ),
        ),
        child: path != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(path!), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: tc.onSurface10,
                            child: Icon(Icons.broken_image_outlined,
                                color: tc.onSurface30, size: 36))),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Tap to change',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: tc.onSurface30, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Cover Photo',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tc.onSurface60,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'JPG or PNG · Max 5 MB',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tc.onSurface30,
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Gallery photo row ─────────────────────────────────────────────────────────

class _GalleryRow extends StatelessWidget {
  final List<String> paths;
  final AppThemeColors tc;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _GalleryRow({
    required this.paths,
    required this.tc,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...List.generate(paths.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(paths[i]),
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                              width: 88,
                              height: 88,
                              color: tc.onSurface10,
                              child: Icon(Icons.broken_image_outlined,
                                  color: tc.onSurface30),
                            )),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tc.borderDefault),
              ),
              child: Icon(Icons.add_rounded, color: tc.onSurface50, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video list ────────────────────────────────────────────────────────────────

class _VideoList extends StatelessWidget {
  final List<String> paths;
  final AppThemeColors tc;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _VideoList({
    required this.paths,
    required this.tc,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(paths.length, (i) {
          final name = paths[i].split(Platform.pathSeparator).last;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary70),
            ),
            child: Row(
              children: [
                const Icon(Icons.videocam_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                        color: tc.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => onRemove(i),
                  child: Icon(Icons.close_rounded,
                      color: tc.onSurface50, size: 18),
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tc.borderDefault),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: tc.onSurface50, size: 20),
                const SizedBox(width: 6),
                Text('Add Video',
                    style: TextStyle(
                        color: tc.onSurface60,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Price text field ──────────────────────────────────────────────────────────

class _PriceField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppThemeColors tc;

  const _PriceField({
    required this.hint,
    required this.controller,
    required this.onChanged,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: TextStyle(
          color: tc.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: '₹ ',
        prefixStyle: TextStyle(
            color: tc.onSurface60, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Pincode field ─────────────────────────────────────────────────────────────

class _PincodeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppThemeColors tc;

  const _PincodeField({
    required this.controller,
    required this.onChanged,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: TextStyle(
          color: tc.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: const InputDecoration(
        hintText: '400001',
        counterText: '',
      ),
    );
  }
}
