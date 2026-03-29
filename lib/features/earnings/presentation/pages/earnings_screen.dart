// lib/features/earnings/presentation/pages/earnings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vendor_card.dart';

// ── Mock data ───────────────────────────────────────────────────────────────

class _EarningEntry {
  final String id;
  final String fieldName;
  final String customerName;
  final DateTime date;
  final int amountPaise;
  final String status; // settled, pending

  const _EarningEntry({
    required this.id,
    required this.fieldName,
    required this.customerName,
    required this.date,
    required this.amountPaise,
    required this.status,
  });

  String get formattedAmount => '₹${(amountPaise / 100).toStringAsFixed(0)}';
}

final _mockEarnings = [
  _EarningEntry(id: 'E001', fieldName: 'Field A', customerName: 'Rahul Sharma', date: DateTime(2025, 3, 28), amountPaise: 60000, status: 'settled'),
  _EarningEntry(id: 'E002', fieldName: 'Field B', customerName: 'Priya Mehta', date: DateTime(2025, 3, 28), amountPaise: 40000, status: 'settled'),
  _EarningEntry(id: 'E003', fieldName: 'Field A', customerName: 'Amit Kumar', date: DateTime(2025, 3, 27), amountPaise: 60000, status: 'pending'),
  _EarningEntry(id: 'E004', fieldName: 'Field A', customerName: 'Sneha Patel', date: DateTime(2025, 3, 26), amountPaise: 60000, status: 'settled'),
  _EarningEntry(id: 'E005', fieldName: 'Field B', customerName: 'Dev Rao', date: DateTime(2025, 3, 25), amountPaise: 40000, status: 'settled'),
  _EarningEntry(id: 'E006', fieldName: 'Field A', customerName: 'Kiran Joshi', date: DateTime(2025, 3, 24), amountPaise: 60000, status: 'pending'),
  _EarningEntry(id: 'E007', fieldName: 'Field B', customerName: 'Meena Singh', date: DateTime(2025, 3, 23), amountPaise: 40000, status: 'settled'),
];

// ── Screen ─────────────────────────────────────────────────────────────────

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedPeriod = 'This Month';
  static const _periods = ['Today', 'This Week', 'This Month', 'All Time'];

  int get _totalSettled => _mockEarnings
      .where((e) => e.status == 'settled')
      .fold(0, (sum, e) => sum + e.amountPaise);

  int get _totalPending => _mockEarnings
      .where((e) => e.status == 'pending')
      .fold(0, (sum, e) => sum + e.amountPaise);

  String _fmt(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';

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
          'Earnings',
          style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          // ── Period filter ──────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _periods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = _periods[i];
                final selected = p == _selectedPeriod;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : tc.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : tc.borderDefault,
                      ),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: selected ? Colors.black : tc.onSurface60,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary cards ────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Settled',
                          amount: _fmt(_totalSettled),
                          icon: Icons.check_circle_outline,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pending',
                          amount: _fmt(_totalPending),
                          icon: Icons.hourglass_top_outlined,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  VendorCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Bookings',
                              style: TextStyle(color: tc.onSurface50, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_mockEarnings.length}',
                              style: TextStyle(
                                color: tc.onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Avg per booking',
                              style: TextStyle(color: tc.onSurface50, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fmt(((_totalSettled + _totalPending) / _mockEarnings.length).round()),
                              style: TextStyle(
                                color: tc.onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Transaction list ─────────────────────────────
                  Text(
                    'TRANSACTIONS',
                    style: TextStyle(
                      color: tc.sectionLabel,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._mockEarnings.map((e) => _TransactionTile(entry: e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Card ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
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
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              color: tc.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: tc.onSurface50, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Transaction Tile ────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final _EarningEntry entry;
  const _TransactionTile({required this.entry});

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(d.year, d.month, d.day);
    final diff = today.difference(entryDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isSettled = entry.status == 'settled';
    final statusColor = isSettled ? AppColors.primary : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tc.onSurface10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                entry.customerName[0],
                style: TextStyle(
                  color: tc.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.customerName,
                  style: TextStyle(
                    color: tc.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.fieldName} · ${_dateLabel(entry.date)}',
                  style: TextStyle(color: tc.onSurface50, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.formattedAmount,
                style: TextStyle(
                  color: tc.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isSettled ? 'Settled' : 'Pending',
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
