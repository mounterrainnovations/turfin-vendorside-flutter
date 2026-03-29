// lib/features/fields/presentation/pages/add_field_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1
  final _nameCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String? _selectedSurface;
  final List<String> _selectedSports = [];

  // Step 2
  final _priceCtrl = TextEditingController();
  final _weekdayOpenCtrl = TextEditingController(text: '06:00 AM');
  final _weekdayCloseCtrl = TextEditingController(text: '10:00 PM');
  final _weekendOpenCtrl = TextEditingController(text: '06:00 AM');
  final _weekendCloseCtrl = TextEditingController(text: '10:00 PM');

  // Step 3
  final List<String> _selectedAmenities = [];

  static const _surfaces = ['Artificial Turf', 'Natural Grass', 'Concrete', 'Wooden'];
  static const _sports = ['Football', 'Cricket', 'Basketball', 'Volleyball', 'Badminton', 'Tennis'];
  static const _amenities = [
    'Parking', 'Flood Lights', 'Changing Room', 'Cafeteria',
    'Shower', 'Equipment Rental', 'Spectator Seating', 'Wi-Fi',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    _weekdayOpenCtrl.dispose();
    _weekdayCloseCtrl.dispose();
    _weekendOpenCtrl.dispose();
    _weekendCloseCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _submit() {
    // TODO: persist field via notifier
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Field added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(
        backgroundColor: tc.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tc.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Field',
          style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          _StepIndicator(current: _currentPage),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _Step1(
                  nameCtrl: _nameCtrl,
                  capacityCtrl: _capacityCtrl,
                  selectedSurface: _selectedSurface,
                  selectedSports: _selectedSports,
                  surfaces: _surfaces,
                  sports: _sports,
                  onSurfaceChanged: (v) => setState(() => _selectedSurface = v),
                  onSportToggled: (s) => setState(() {
                    if (_selectedSports.contains(s)) {
                      _selectedSports.remove(s);
                    } else {
                      _selectedSports.add(s);
                    }
                  }),
                ),
                _Step2(
                  priceCtrl: _priceCtrl,
                  weekdayOpenCtrl: _weekdayOpenCtrl,
                  weekdayCloseCtrl: _weekdayCloseCtrl,
                  weekendOpenCtrl: _weekendOpenCtrl,
                  weekendCloseCtrl: _weekendCloseCtrl,
                ),
                _Step3(
                  selectedAmenities: _selectedAmenities,
                  amenities: _amenities,
                  onToggle: (a) => setState(() {
                    if (_selectedAmenities.contains(a)) {
                      _selectedAmenities.remove(a);
                    } else {
                      _selectedAmenities.add(a);
                    }
                  }),
                ),
              ],
            ),
          ),
          _BottomBar(
            currentPage: _currentPage,
            onBack: _currentPage > 0
                ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut)
                : null,
            onNext: _nextPage,
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final labels = ['Basic Info', 'Hours & Price', 'Amenities'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == current;
          final isDone = i < current;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isDone ? AppColors.primary : tc.onSurface10,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.black : tc.onSurface50,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: isActive ? tc.onSurface : tc.onSurface50,
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (i < 2)
                        Container(
                          margin: const EdgeInsets.only(top: 4, right: 8),
                          height: 1,
                          color: tc.onSurface10,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1: Basic Info ──────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController capacityCtrl;
  final String? selectedSurface;
  final List<String> selectedSports;
  final List<String> surfaces;
  final List<String> sports;
  final ValueChanged<String?> onSurfaceChanged;
  final ValueChanged<String> onSportToggled;

  const _Step1({
    required this.nameCtrl,
    required this.capacityCtrl,
    required this.selectedSurface,
    required this.selectedSports,
    required this.surfaces,
    required this.sports,
    required this.onSurfaceChanged,
    required this.onSportToggled,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(hint: 'Field Name', controller: nameCtrl),
          const SizedBox(height: 16),
          CustomTextField(
            hint: 'Capacity (players)',
            controller: capacityCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text('Surface Type', style: TextStyle(color: tc.onSurface60, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tc.borderDefault),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSurface,
                isExpanded: true,
                dropdownColor: tc.surface,
                hint: Text('Select surface', style: TextStyle(color: tc.onSurface50)),
                items: surfaces
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: TextStyle(color: tc.onSurface)),
                        ))
                    .toList(),
                onChanged: onSurfaceChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Sports Supported', style: TextStyle(color: tc.onSurface60, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sports
                .map((s) => _ToggleChip(
                      label: s,
                      selected: selectedSports.contains(s),
                      onTap: () => onSportToggled(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Hours & Pricing ─────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final TextEditingController priceCtrl;
  final TextEditingController weekdayOpenCtrl;
  final TextEditingController weekdayCloseCtrl;
  final TextEditingController weekendOpenCtrl;
  final TextEditingController weekendCloseCtrl;

  const _Step2({
    required this.priceCtrl,
    required this.weekdayOpenCtrl,
    required this.weekdayCloseCtrl,
    required this.weekendOpenCtrl,
    required this.weekendCloseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            hint: 'Standard Price ₹/hr (e.g. 600)',
            controller: priceCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Text(
            'Weekday Hours',
            style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(hint: 'Open (e.g. 06:00 AM)', controller: weekdayOpenCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(hint: 'Close (e.g. 10:00 PM)', controller: weekdayCloseCtrl),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Weekend Hours',
            style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(hint: 'Open (e.g. 06:00 AM)', controller: weekendOpenCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(hint: 'Close (e.g. 10:00 PM)', controller: weekendCloseCtrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Amenities ───────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final List<String> selectedAmenities;
  final List<String> amenities;
  final ValueChanged<String> onToggle;

  const _Step3({
    required this.selectedAmenities,
    required this.amenities,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select all amenities available at this field',
            style: TextStyle(color: tc.onSurface60, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: amenities
                .map((a) => _ToggleChip(
                      label: a,
                      selected: selectedAmenities.contains(a),
                      onTap: () => onToggle(a),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Chip ─────────────────────────────────────────────────────────────

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySubtle : tc.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : tc.borderDefault,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : tc.onSurface60,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Bottom Bar ──────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  const _BottomBar({required this.currentPage, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: tc.scaffoldBg,
        border: Border(top: BorderSide(color: tc.borderSubtle)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: tc.borderDefault),
                foregroundColor: tc.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back'),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                currentPage < 2 ? 'Next' : 'Add Field',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
