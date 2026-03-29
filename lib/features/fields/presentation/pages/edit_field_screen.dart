// lib/features/fields/presentation/pages/edit_field_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/models/field_model.dart';

class EditFieldScreen extends StatefulWidget {
  final FieldModel field;
  const EditFieldScreen({super.key, required this.field});

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _weekdayOpenCtrl;
  late final TextEditingController _weekdayCloseCtrl;
  late final TextEditingController _weekendOpenCtrl;
  late final TextEditingController _weekendCloseCtrl;

  late String? _selectedSurface;
  late List<String> _selectedSports;
  late List<String> _selectedAmenities;
  late FieldStatus _status;

  static const _surfaces = ['Artificial Turf', 'Natural Grass', 'Concrete', 'Wooden'];
  static const _sports = ['Football', 'Cricket', 'Basketball', 'Volleyball', 'Badminton', 'Tennis'];
  static const _amenities = [
    'Parking', 'Flood Lights', 'Changing Room', 'Cafeteria',
    'Shower', 'Equipment Rental', 'Spectator Seating', 'Wi-Fi',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.field;
    _nameCtrl = TextEditingController(text: f.name);
    _capacityCtrl = TextEditingController(text: f.capacity.toString());
    _priceCtrl = TextEditingController(
      text: (f.standardPricePaise / 100).toStringAsFixed(0),
    );
    _weekdayOpenCtrl = TextEditingController(text: f.weekdayOpen);
    _weekdayCloseCtrl = TextEditingController(text: f.weekdayClose);
    _weekendOpenCtrl = TextEditingController(text: f.weekendOpen);
    _weekendCloseCtrl = TextEditingController(text: f.weekendClose);
    _selectedSurface = f.surfaceType;
    _selectedSports = List.from(f.sports);
    _selectedAmenities = List.from(f.amenities);
    _status = f.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    _weekdayOpenCtrl.dispose();
    _weekdayCloseCtrl.dispose();
    _weekendOpenCtrl.dispose();
    _weekendCloseCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // TODO: persist via notifier
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Field updated successfully')),
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
          'Edit Field',
          style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Basic Info ────────────────────────────────────────────
            _SectionHeader(title: 'Basic Info'),
            const SizedBox(height: 12),
            CustomTextField(hint: 'Field Name', controller: _nameCtrl),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Capacity (players)',
              controller: _capacityCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Text('Surface Type', style: TextStyle(color: tc.onSurface60, fontSize: 13)),
            const SizedBox(height: 8),
            _DropdownField(
              value: _selectedSurface,
              items: _surfaces,
              onChanged: (v) => setState(() => _selectedSurface = v),
            ),
            const SizedBox(height: 12),
            Text('Sports Supported', style: TextStyle(color: tc.onSurface60, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sports
                  .map((s) => _ToggleChip(
                        label: s,
                        selected: _selectedSports.contains(s),
                        onTap: () => setState(() {
                          if (_selectedSports.contains(s)) {
                            _selectedSports.remove(s);
                          } else {
                            _selectedSports.add(s);
                          }
                        }),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ── Hours & Pricing ───────────────────────────────────────
            _SectionHeader(title: 'Hours & Pricing'),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Standard Price ₹/hr',
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text('Weekday Hours', style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: CustomTextField(hint: 'Open', controller: _weekdayOpenCtrl)),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(hint: 'Close', controller: _weekdayCloseCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Weekend Hours', style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: CustomTextField(hint: 'Open', controller: _weekendOpenCtrl)),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(hint: 'Close', controller: _weekendCloseCtrl)),
              ],
            ),

            const SizedBox(height: 24),

            // ── Amenities ─────────────────────────────────────────────
            _SectionHeader(title: 'Amenities'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amenities
                  .map((a) => _ToggleChip(
                        label: a,
                        selected: _selectedAmenities.contains(a),
                        onTap: () => setState(() {
                          if (_selectedAmenities.contains(a)) {
                            _selectedAmenities.remove(a);
                          } else {
                            _selectedAmenities.add(a);
                          }
                        }),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ── Status ────────────────────────────────────────────────
            _SectionHeader(title: 'Status'),
            const SizedBox(height: 12),
            _DropdownField<FieldStatus>(
              value: _status,
              items: FieldStatus.values,
              itemLabel: (s) => s.name[0].toUpperCase() + s.name.substring(1),
              onChanged: (v) { if (v != null) setState(() => _status = v); },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: BoxDecoration(
          color: tc.scaffoldBg,
          border: Border(top: BorderSide(color: tc.borderSubtle)),
        ),
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Text(
      title,
      style: TextStyle(color: tc.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

// ── Dropdown Field ──────────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T)? itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tc.borderDefault),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: tc.surface,
          hint: Text('Select', style: TextStyle(color: tc.onSurface50)),
          items: items
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      itemLabel != null ? itemLabel!(s) : s.toString(),
                      style: TextStyle(color: tc.onSurface),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
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
