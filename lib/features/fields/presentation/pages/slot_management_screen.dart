// lib/features/fields/presentation/pages/slot_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vendor_card.dart';
import '../../domain/models/field_model.dart';
import '../../domain/models/slot_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ════════════════════════════════════════════════════════════════════════════

class PeakRule {
  final String id;
  final TimeOfDay from;
  final TimeOfDay to;
  final int pricePaise; // fixed peak price

  PeakRule({required this.id, required this.from, required this.to, required this.pricePaise});

  PeakRule copyWith({TimeOfDay? from, TimeOfDay? to, int? pricePaise}) => PeakRule(
        id: id,
        from: from ?? this.from,
        to: to ?? this.to,
        pricePaise: pricePaise ?? this.pricePaise,
      );

  String get timeLabel =>
      '${_fmtTime(from)} – ${_fmtTime(to)}';

  static String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

class ScheduleConfig {
  final TimeOfDay weekdayOpen;
  final TimeOfDay weekdayClose;
  final TimeOfDay weekendOpen;
  final TimeOfDay weekendClose;
  final int slotDurationMinutes; // 30, 60, 90, 120
  final int basePricePaise;
  final List<PeakRule> peakRules;

  const ScheduleConfig({
    required this.weekdayOpen,
    required this.weekdayClose,
    required this.weekendOpen,
    required this.weekendClose,
    required this.slotDurationMinutes,
    required this.basePricePaise,
    required this.peakRules,
  });

  ScheduleConfig copyWith({
    TimeOfDay? weekdayOpen,
    TimeOfDay? weekdayClose,
    TimeOfDay? weekendOpen,
    TimeOfDay? weekendClose,
    int? slotDurationMinutes,
    int? basePricePaise,
    List<PeakRule>? peakRules,
  }) =>
      ScheduleConfig(
        weekdayOpen: weekdayOpen ?? this.weekdayOpen,
        weekdayClose: weekdayClose ?? this.weekdayClose,
        weekendOpen: weekendOpen ?? this.weekendOpen,
        weekendClose: weekendClose ?? this.weekendClose,
        slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
        basePricePaise: basePricePaise ?? this.basePricePaise,
        peakRules: peakRules ?? this.peakRules,
      );

  int get slotCount {
    final openMins = weekdayOpen.hour * 60 + weekdayOpen.minute;
    final closeMins = weekdayClose.hour * 60 + weekdayClose.minute;
    final total = closeMins - openMins;
    if (total <= 0) return 0;
    return total ~/ slotDurationMinutes;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

final _selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final _scheduleConfigProvider = StateNotifierProvider<_ScheduleConfigNotifier, ScheduleConfig>(
  (ref) => _ScheduleConfigNotifier(),
);

class _ScheduleConfigNotifier extends StateNotifier<ScheduleConfig> {
  _ScheduleConfigNotifier()
      : super(ScheduleConfig(
          weekdayOpen: const TimeOfDay(hour: 6, minute: 0),
          weekdayClose: const TimeOfDay(hour: 22, minute: 0),
          weekendOpen: const TimeOfDay(hour: 6, minute: 0),
          weekendClose: const TimeOfDay(hour: 23, minute: 0),
          slotDurationMinutes: 60,
          basePricePaise: 60000,
          peakRules: [
            // Default evening peak
          ],
        ));

  void update(ScheduleConfig config) => state = config;
  void addPeakRule(PeakRule rule) =>
      state = state.copyWith(peakRules: [...state.peakRules, rule]);
  void removePeakRule(String id) =>
      state = state.copyWith(peakRules: state.peakRules.where((r) => r.id != id).toList());
  void updatePeakRule(PeakRule updated) => state = state.copyWith(
      peakRules: state.peakRules.map((r) => r.id == updated.id ? updated : r).toList());
}

final _slotsProvider = StateNotifierProvider<_SlotsNotifier, List<VendorSlotModel>>(
  (ref) => _SlotsNotifier(ref.read(_scheduleConfigProvider)),
);

class _SlotsNotifier extends StateNotifier<List<VendorSlotModel>> {
  _SlotsNotifier(ScheduleConfig config) : super(_generate(config));

  static List<VendorSlotModel> _generate(ScheduleConfig config) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slots = <VendorSlotModel>[];
    int startMins = config.weekdayOpen.hour * 60 + config.weekdayOpen.minute;
    final endMins = config.weekdayClose.hour * 60 + config.weekdayClose.minute;
    int idx = 0;
    while (startMins + config.slotDurationMinutes <= endMins) {
      final sh = startMins ~/ 60;
      final sm = startMins % 60;
      final eh = (startMins + config.slotDurationMinutes) ~/ 60;
      final em = (startMins + config.slotDurationMinutes) % 60;
      final start = '${sh.toString().padLeft(2, '0')}:${sm.toString().padLeft(2, '0')}';
      final end = '${eh.toString().padLeft(2, '0')}:${em.toString().padLeft(2, '0')}';

      // Check if slot falls in a peak rule
      int price = config.basePricePaise;
      for (final rule in config.peakRules) {
        final ruleFrom = rule.from.hour * 60 + rule.from.minute;
        final ruleTo = rule.to.hour * 60 + rule.to.minute;
        if (startMins >= ruleFrom && startMins < ruleTo) {
          price = rule.pricePaise;
          break;
        }
      }

      VendorSlotStatus status = VendorSlotStatus.available;
      if (idx == 2 || idx == 5 || idx == 9) status = VendorSlotStatus.booked;
      if (idx == 12) status = VendorSlotStatus.blocked;

      slots.add(VendorSlotModel(
        id: 'S${idx.toString().padLeft(3, '0')}',
        fieldId: 'F001',
        slotDate: today,
        startTime: start,
        endTime: end,
        pricePaise: price,
        status: status,
      ));
      startMins += config.slotDurationMinutes;
      idx++;
    }
    return slots;
  }

  void regenerate(ScheduleConfig config) => state = _generate(config);

  void updateSlot(VendorSlotModel updated) =>
      state = state.map((s) => s.id == updated.id ? updated : s).toList();

  void bulkBlock(List<String> ids) => state = state
      .map((s) => ids.contains(s.id) && s.status != VendorSlotStatus.booked
          ? VendorSlotModel(
              id: s.id, fieldId: s.fieldId, slotDate: s.slotDate,
              startTime: s.startTime, endTime: s.endTime,
              pricePaise: s.pricePaise, status: VendorSlotStatus.blocked,
              blockReason: 'Blocked by vendor')
          : s)
      .toList();

  void bulkUnblock(List<String> ids) => state = state
      .map((s) => ids.contains(s.id) && s.status == VendorSlotStatus.blocked
          ? VendorSlotModel(
              id: s.id, fieldId: s.fieldId, slotDate: s.slotDate,
              startTime: s.startTime, endTime: s.endTime,
              pricePaise: s.pricePaise, status: VendorSlotStatus.available)
          : s)
      .toList();

  void bulkSetPrice(List<String> ids, int pricePaise) => state = state
      .map((s) => ids.contains(s.id) && s.status != VendorSlotStatus.booked
          ? VendorSlotModel(
              id: s.id, fieldId: s.fieldId, slotDate: s.slotDate,
              startTime: s.startTime, endTime: s.endTime,
              pricePaise: pricePaise, status: s.status,
              blockReason: s.blockReason)
          : s)
      .toList();
}

final _selectedSlotsProvider = StateProvider<Set<String>>((ref) => {});

// ════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════

class SlotManagementScreen extends ConsumerStatefulWidget {
  final FieldModel field;
  const SlotManagementScreen({super.key, required this.field});

  @override
  ConsumerState<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends ConsumerState<SlotManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final selectedSlots = ref.watch(_selectedSlotsProvider);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(
        backgroundColor: tc.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tc.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slot & Schedule',
                style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
            Text(widget.field.name,
                style: TextStyle(color: tc.onSurface50, fontSize: 12)),
          ],
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          // ── Tab bar ────────────────────────────────────────────────────
          Container(
            color: tc.scaffoldBg,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: tc.onSurface50,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'MANAGE SLOTS'),
                Tab(text: 'CONFIGURE'),
              ],
            ),
          ),
          Divider(height: 1, color: tc.borderSubtle),
          // ── Tab content ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ManageTab(field: widget.field),
                _ConfigureTab(field: widget.field),
              ],
            ),
          ),
        ],
      ),
      // ── Bulk action bar ──────────────────────────────────────────────────
      bottomNavigationBar: selectedSlots.isEmpty
          ? null
          : _BulkActionBar(selectedIds: selectedSlots),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 1 — MANAGE SLOTS
// ════════════════════════════════════════════════════════════════════════════

class _ManageTab extends ConsumerWidget {
  final FieldModel field;
  const _ManageTab({required this.field});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final slots = ref.watch(_slotsProvider);
    final selectedDate = ref.watch(_selectedDateProvider);
    final selectedSlots = ref.watch(_selectedSlotsProvider);
    final isSelectMode = selectedSlots.isNotEmpty;

    return Column(
      children: [
        // ── Date strip ──────────────────────────────────────────────
        _DateStrip(selectedDate: selectedDate),

        // ── Stats row ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _StatPill(
                count: slots.where((s) => s.status == VendorSlotStatus.available).length,
                label: 'Available',
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _StatPill(
                count: slots.where((s) => s.status == VendorSlotStatus.booked).length,
                label: 'Booked',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _StatPill(
                count: slots.where((s) => s.status == VendorSlotStatus.blocked).length,
                label: 'Blocked',
                color: tc.onSurface30,
              ),
              const Spacer(),
              // Select mode toggle
              TextButton.icon(
                onPressed: () {
                  if (isSelectMode) {
                    ref.read(_selectedSlotsProvider.notifier).state = {};
                  } else {
                    // Enter select mode by selecting first available slot hint
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tap slots to select them'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isSelectMode ? Icons.close : Icons.checklist_outlined,
                  size: 16,
                  color: isSelectMode ? AppColors.error : AppColors.primary,
                ),
                label: Text(
                  isSelectMode ? 'Cancel' : 'Select',
                  style: TextStyle(
                    color: isSelectMode ? AppColors.error : AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
        ),

        // ── Slot list ────────────────────────────────────────────────
        Expanded(
          child: slots.isEmpty
              ? _EmptySlots(
                  onGenerate: () {
                    final config = ref.read(_scheduleConfigProvider);
                    ref.read(_slotsProvider.notifier).regenerate(config);
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: slots.length,
                  itemBuilder: (_, i) => _SlotTile(
                    slot: slots[i],
                    isSelected: selectedSlots.contains(slots[i].id),
                    isSelectMode: isSelectMode,
                    onTap: () {
                      if (isSelectMode) {
                        final current = Set<String>.from(ref.read(_selectedSlotsProvider));
                        if (current.contains(slots[i].id)) {
                          current.remove(slots[i].id);
                        } else {
                          current.add(slots[i].id);
                        }
                        ref.read(_selectedSlotsProvider.notifier).state = current;
                      } else {
                        _showSlotDetail(context, ref, slots[i]);
                      }
                    },
                    onLongPress: () {
                      if (!isSelectMode) {
                        final current = {slots[i].id};
                        ref.read(_selectedSlotsProvider.notifier).state = current;
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showSlotDetail(BuildContext context, WidgetRef ref, VendorSlotModel slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SlotDetailSheet(slot: slot),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 2 — CONFIGURE
// ════════════════════════════════════════════════════════════════════════════

class _ConfigureTab extends ConsumerStatefulWidget {
  final FieldModel field;
  const _ConfigureTab({required this.field});

  @override
  ConsumerState<_ConfigureTab> createState() => _ConfigureTabState();
}

class _ConfigureTabState extends ConsumerState<_ConfigureTab> {
  late TextEditingController _basePriceCtrl;

  @override
  void initState() {
    super.initState();
    final config = ref.read(_scheduleConfigProvider);
    _basePriceCtrl = TextEditingController(
      text: (config.basePricePaise / 100).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _basePriceCtrl.dispose();
    super.dispose();
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _applyAndRegenerate() {
    final config = ref.read(_scheduleConfigProvider);
    final price = int.tryParse(_basePriceCtrl.text) ?? 600;
    final updated = config.copyWith(basePricePaise: price * 100);
    ref.read(_scheduleConfigProvider.notifier).update(updated);
    ref.read(_slotsProvider.notifier).regenerate(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${updated.slotCount} slots regenerated'),
        backgroundColor: AppColors.primary.withAlpha(220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final config = ref.watch(_scheduleConfigProvider);
    final durations = [30, 60, 90, 120];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Operating Hours ──────────────────────────────────────
          _ConfigSection(
            icon: Icons.access_time_outlined,
            title: 'Operating Hours',
            child: Column(
              children: [
                _HoursRow(
                  label: 'Weekdays',
                  open: _fmtTime(config.weekdayOpen),
                  close: _fmtTime(config.weekdayClose),
                  onTapOpen: () async {
                    final t = await _pickTime(context, config.weekdayOpen);
                    if (t != null) {
                      ref.read(_scheduleConfigProvider.notifier)
                          .update(config.copyWith(weekdayOpen: t));
                    }
                  },
                  onTapClose: () async {
                    final t = await _pickTime(context, config.weekdayClose);
                    if (t != null) {
                      ref.read(_scheduleConfigProvider.notifier)
                          .update(config.copyWith(weekdayClose: t));
                    }
                  },
                ),
                const SizedBox(height: 10),
                _HoursRow(
                  label: 'Weekends',
                  open: _fmtTime(config.weekendOpen),
                  close: _fmtTime(config.weekendClose),
                  onTapOpen: () async {
                    final t = await _pickTime(context, config.weekendOpen);
                    if (t != null) {
                      ref.read(_scheduleConfigProvider.notifier)
                          .update(config.copyWith(weekendOpen: t));
                    }
                  },
                  onTapClose: () async {
                    final t = await _pickTime(context, config.weekendClose);
                    if (t != null) {
                      ref.read(_scheduleConfigProvider.notifier)
                          .update(config.copyWith(weekendClose: t));
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Slot Duration ─────────────────────────────────────────
          _ConfigSection(
            icon: Icons.timelapse_outlined,
            title: 'Slot Duration',
            subtitle: '${config.slotCount} slots will be generated per day',
            child: Row(
              children: durations
                  .map((d) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _DurationChip(
                          label: d < 60 ? '${d}m' : '${d ~/ 60}h${d % 60 > 0 ? ' ${d % 60}m' : ''}',
                          selected: config.slotDurationMinutes == d,
                          onTap: () {
                            ref.read(_scheduleConfigProvider.notifier)
                                .update(config.copyWith(slotDurationMinutes: d));
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Base Pricing ──────────────────────────────────────────
          _ConfigSection(
            icon: Icons.currency_rupee_outlined,
            title: 'Base Price',
            subtitle: 'Standard rate for all non-peak slots',
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tc.onSurface10,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text('₹', style: TextStyle(color: tc.onSurface60, fontSize: 18)),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _basePriceCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '600',
                      hintStyle: TextStyle(color: tc.onSurface30),
                      suffix: Text('/hr', style: TextStyle(color: tc.onSurface50, fontSize: 13)),
                      filled: true,
                      fillColor: tc.surface,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Peak Hour Rules ───────────────────────────────────────
          _ConfigSection(
            icon: Icons.bolt_outlined,
            title: 'Peak Hour Pricing',
            subtitle: 'Set higher prices for high-demand time slots',
            trailing: IconButton(
              icon: Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
              onPressed: () => _addPeakRule(context, ref, config),
            ),
            child: config.peakRules.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: tc.onSurface30),
                        const SizedBox(width: 8),
                        Text(
                          'No peak rules yet. Tap + to add one.',
                          style: TextStyle(color: tc.onSurface50, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: config.peakRules
                        .map((rule) => _PeakRuleTile(
                              rule: rule,
                              onEdit: () => _editPeakRule(context, ref, rule),
                              onDelete: () => ref
                                  .read(_scheduleConfigProvider.notifier)
                                  .removePeakRule(rule.id),
                            ))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 24),

          // ── Apply button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _applyAndRegenerate,
              icon: const Icon(Icons.refresh, size: 18, color: Colors.black),
              label: Text(
                'Apply & Regenerate ${config.slotCount} Slots',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'This will regenerate slots for the selected day',
              style: TextStyle(color: tc.onSurface30, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addPeakRule(BuildContext context, WidgetRef ref, ScheduleConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PeakRuleSheet(
        onSave: (rule) => ref.read(_scheduleConfigProvider.notifier).addPeakRule(rule),
      ),
    );
  }

  void _editPeakRule(BuildContext context, WidgetRef ref, PeakRule rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PeakRuleSheet(
        existing: rule,
        onSave: (updated) =>
            ref.read(_scheduleConfigProvider.notifier).updatePeakRule(updated),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SLOT DETAIL BOTTOM SHEET
// ════════════════════════════════════════════════════════════════════════════

class _SlotDetailSheet extends ConsumerStatefulWidget {
  final VendorSlotModel slot;
  const _SlotDetailSheet({required this.slot});

  @override
  ConsumerState<_SlotDetailSheet> createState() => _SlotDetailSheetState();
}

class _SlotDetailSheetState extends ConsumerState<_SlotDetailSheet> {
  late VendorSlotStatus _status;
  late TextEditingController _priceCtrl;
  late TextEditingController _reasonCtrl;

  @override
  void initState() {
    super.initState();
    _status = widget.slot.status;
    _priceCtrl = TextEditingController(
        text: (widget.slot.pricePaise / 100).toStringAsFixed(0));
    _reasonCtrl = TextEditingController(text: widget.slot.blockReason ?? '');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isBooked = widget.slot.status == VendorSlotStatus.booked;

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            '${widget.slot.startTime} – ${widget.slot.endTime}',
            style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            'Base: ${widget.slot.formattedPrice}',
            style: TextStyle(color: tc.onSurface50, fontSize: 13),
          ),

          const SizedBox(height: 20),

          if (!isBooked) ...[
            // Status toggle
            Text('STATUS', style: TextStyle(color: tc.sectionLabel, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusToggleChip(
                  label: 'Available',
                  icon: Icons.check_circle_outline,
                  selected: _status == VendorSlotStatus.available,
                  color: AppColors.primary,
                  onTap: () => setState(() => _status = VendorSlotStatus.available),
                ),
                const SizedBox(width: 10),
                _StatusToggleChip(
                  label: 'Blocked',
                  icon: Icons.block_outlined,
                  selected: _status == VendorSlotStatus.blocked,
                  color: AppColors.error,
                  onTap: () => setState(() => _status = VendorSlotStatus.blocked),
                ),
                const SizedBox(width: 10),
                _StatusToggleChip(
                  label: 'Maintenance',
                  icon: Icons.build_outlined,
                  selected: _status == VendorSlotStatus.maintenance,
                  color: Colors.orange,
                  onTap: () => setState(() => _status = VendorSlotStatus.maintenance),
                ),
              ],
            ),

            if (_status == VendorSlotStatus.blocked || _status == VendorSlotStatus.maintenance) ...[
              const SizedBox(height: 16),
              Text('REASON (optional)', style: TextStyle(color: tc.sectionLabel, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                style: TextStyle(color: tc.onSurface),
                decoration: InputDecoration(
                  hintText: 'e.g. Field maintenance, Private event…',
                  hintStyle: TextStyle(color: tc.onSurface30),
                  filled: true,
                  fillColor: tc.onSurface10,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Price override
            Text('PRICE OVERRIDE', style: TextStyle(color: tc.sectionLabel, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 40, height: 48,
                  decoration: BoxDecoration(
                    color: tc.onSurface10,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  ),
                  child: Center(child: Text('₹', style: TextStyle(color: tc.onSurface60))),
                ),
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: tc.surface,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price = int.tryParse(_priceCtrl.text) ?? widget.slot.pricePaise ~/ 100;
                  final updated = VendorSlotModel(
                    id: widget.slot.id,
                    fieldId: widget.slot.fieldId,
                    slotDate: widget.slot.slotDate,
                    startTime: widget.slot.startTime,
                    endTime: widget.slot.endTime,
                    pricePaise: price * 100,
                    status: _status,
                    blockReason: _reasonCtrl.text.isEmpty ? null : _reasonCtrl.text,
                  );
                  ref.read(_slotsProvider.notifier).updateSlot(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Slot updated')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ] else ...[
            // Booked — read only
            VendorCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.event_available, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Text('This slot is booked by a customer',
                      style: TextStyle(color: tc.onSurface, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PEAK RULE BOTTOM SHEET
// ════════════════════════════════════════════════════════════════════════════

class _PeakRuleSheet extends ConsumerStatefulWidget {
  final PeakRule? existing;
  final ValueChanged<PeakRule> onSave;
  const _PeakRuleSheet({this.existing, required this.onSave});

  @override
  ConsumerState<_PeakRuleSheet> createState() => _PeakRuleSheetState();
}

class _PeakRuleSheetState extends ConsumerState<_PeakRuleSheet> {
  late TimeOfDay _from;
  late TimeOfDay _to;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _from = widget.existing?.from ?? const TimeOfDay(hour: 18, minute: 0);
    _to = widget.existing?.to ?? const TimeOfDay(hour: 21, minute: 0);
    _priceCtrl = TextEditingController(
      text: widget.existing != null
          ? (widget.existing!.pricePaise / 100).toStringAsFixed(0)
          : '900',
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.existing == null ? 'Add Peak Rule' : 'Edit Peak Rule',
            style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Slots in this window will use the peak price',
            style: TextStyle(color: tc.onSurface50, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Time range
          Text('TIME WINDOW', style: TextStyle(color: tc.sectionLabel, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TimePickerButton(
                  label: 'From',
                  time: _fmtTime(_from),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _from);
                    if (t != null) setState(() => _from = t);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('→', style: TextStyle(color: tc.onSurface50, fontSize: 18)),
              ),
              Expanded(
                child: _TimePickerButton(
                  label: 'To',
                  time: _fmtTime(_to),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _to);
                    if (t != null) setState(() => _to = t);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Peak price
          Text('PEAK PRICE (₹/slot)', style: TextStyle(color: tc.sectionLabel, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: const Center(
                  child: Text('₹', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: tc.surface,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary.withAlpha(80)),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary.withAlpha(80)),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final price = int.tryParse(_priceCtrl.text) ?? 900;
                final rule = PeakRule(
                  id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  from: _from,
                  to: _to,
                  pricePaise: price * 100,
                );
                widget.onSave(rule);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                widget.existing == null ? 'Add Peak Rule' : 'Save Changes',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BULK ACTION BAR
// ════════════════════════════════════════════════════════════════════════════

class _BulkActionBar extends ConsumerWidget {
  final Set<String> selectedIds;
  const _BulkActionBar({required this.selectedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: tc.surface,
        border: Border(top: BorderSide(color: AppColors.primary.withAlpha(80))),
        boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selectedIds.length} selected',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => ref.read(_selectedSlotsProvider.notifier).state = {},
                child: const Text('Clear', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(_slotsProvider.notifier).bulkBlock(selectedIds.toList());
                    ref.read(_selectedSlotsProvider.notifier).state = {};
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${selectedIds.length} slots blocked')),
                    );
                  },
                  icon: Icon(Icons.block, size: 16, color: AppColors.error),
                  label: Text('Block All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withAlpha(80)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(_slotsProvider.notifier).bulkUnblock(selectedIds.toList());
                    ref.read(_selectedSlotsProvider.notifier).state = {};
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${selectedIds.length} slots unblocked')),
                    );
                  },
                  icon: Icon(Icons.lock_open, size: 16, color: AppColors.primary),
                  label: Text('Unblock All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withAlpha(80)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBulkPriceDialog(context, ref),
                  icon: const Icon(Icons.currency_rupee, size: 16, color: Colors.black),
                  label: const Text('Set Price', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBulkPriceDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Price for Selected Slots'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '₹ ',
            hintText: 'e.g. 800',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = int.tryParse(ctrl.text) ?? 0;
              if (price > 0) {
                ref.read(_slotsProvider.notifier).bulkSetPrice(
                  selectedIds.toList(),
                  price * 100,
                );
                ref.read(_selectedSlotsProvider.notifier).state = {};
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Price set to ₹$price for ${selectedIds.length} slots')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _DateStrip extends ConsumerWidget {
  final DateTime selectedDate;
  const _DateStrip({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final today = DateTime.now();
    final days = List.generate(14, (i) {
      final d = today.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      height: 78,
      color: tc.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: days.length,
        itemBuilder: (_, i) {
          final day = days[i];
          final isSelected = day == selectedDate;
          final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
          return GestureDetector(
            onTap: () => ref.read(_selectedDateProvider.notifier).state = day,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabels[day.weekday % 7],
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.black
                          : isWeekend
                              ? AppColors.primary.withAlpha(180)
                              : tc.onSurface50,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected ? Colors.black : tc.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final VendorSlotModel slot;
  final bool isSelected;
  final bool isSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.isSelectMode,
    required this.onTap,
    required this.onLongPress,
  });

  Color _statusColor(VendorSlotStatus s, AppThemeColors tc) => switch (s) {
        VendorSlotStatus.available => AppColors.primary,
        VendorSlotStatus.booked => Colors.blue,
        VendorSlotStatus.blocked => tc.onSurface30,
        VendorSlotStatus.maintenance => Colors.orange,
      };

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final color = _statusColor(slot.status, tc);
    final isBooked = slot.status == VendorSlotStatus.booked;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : tc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: color, width: 3),
            top: isSelected ? BorderSide(color: AppColors.primary.withAlpha(80)) : BorderSide.none,
            right: isSelected ? BorderSide(color: AppColors.primary.withAlpha(80)) : BorderSide.none,
            bottom: isSelected ? BorderSide(color: AppColors.primary.withAlpha(80)) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            if (isSelectMode) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : tc.onSurface30,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.black)
                    : null,
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${slot.startTime} – ${slot.endTime}',
                        style: TextStyle(
                          color: tc.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (slot.blockReason != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.info_outline, size: 13, color: tc.onSurface30),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.formattedPrice,
                    style: TextStyle(color: tc.onSurface50, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                slot.status.name[0].toUpperCase() + slot.status.name.substring(1),
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            if (!isBooked && !isSelectMode) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: tc.onSurface20, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatPill({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$count $label',
            style: TextStyle(color: AppThemeColors.of(context).onSurface50, fontSize: 12)),
      ],
    );
  }
}

class _EmptySlots extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptySlots({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_off_outlined, size: 48, color: tc.onSurface20),
          const SizedBox(height: 12),
          Text('No slots for this day',
              style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Configure your schedule and tap\n"Apply & Regenerate"',
              textAlign: TextAlign.center,
              style: TextStyle(color: tc.onSurface50, fontSize: 13)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onGenerate,
            icon: Icon(Icons.refresh, size: 16, color: AppColors.primary),
            label: Text('Generate Slots', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withAlpha(80)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  const _ConfigSection({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return VendorCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w700, fontSize: 14)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: TextStyle(color: tc.onSurface50, fontSize: 11)),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String label;
  final String open;
  final String close;
  final VoidCallback onTapOpen;
  final VoidCallback onTapClose;
  const _HoursRow({
    required this.label,
    required this.open,
    required this.close,
    required this.onTapOpen,
    required this.onTapClose,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: TextStyle(color: tc.onSurface60, fontSize: 13)),
        ),
        Expanded(child: _TimePickerButton(label: 'Opens', time: open, onTap: onTapOpen)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('–', style: TextStyle(color: tc.onSurface30)),
        ),
        Expanded(child: _TimePickerButton(label: 'Closes', time: close, onTap: onTapClose)),
      ],
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  const _TimePickerButton({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: tc.onSurface10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tc.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: tc.onSurface30, fontSize: 10)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(time,
                      style: TextStyle(
                          color: tc.onSurface, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                Icon(Icons.access_time, size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DurationChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : tc.onSurface10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : tc.onSurface60,
            fontWeight: selected ? FontWeight.w800 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PeakRuleTile extends StatelessWidget {
  final PeakRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PeakRuleTile({required this.rule, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.timeLabel,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                Text('₹${(rule.pricePaise / 100).toStringAsFixed(0)}/slot',
                    style: TextStyle(color: tc.onSurface60, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 16, color: tc.onSurface50),
            onPressed: onEdit,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
        ],
      ),
    );
  }
}

class _StatusToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : tc.onSurface10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : tc.borderDefault,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : tc.onSurface50),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : tc.onSurface60,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
