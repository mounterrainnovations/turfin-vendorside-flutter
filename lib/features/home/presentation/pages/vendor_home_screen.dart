// lib/features/home/presentation/pages/vendor_home_screen.dart

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

    final tabs = const [
      DashboardTab(),
      BookingsTab(),
      FieldsTab(),
      ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppThemeColors.of(context).scaffoldBg,
      body: IndexedStack(
        index: currentTab,
        children: tabs,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF000000),
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
    final tc = AppThemeColors.of(context);
    const items = [
      (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      (Icons.calendar_today_outlined, Icons.calendar_today, 'Bookings'),
      (Icons.sports_soccer_outlined, Icons.sports_soccer, 'Fields'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: tc.navBg,
        border: Border(top: BorderSide(color: tc.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              ...List.generate(2, (i) => Expanded(child: _NavItem(
                icon: items[i].$1,
                activeIcon: items[i].$2,
                label: items[i].$3,
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              ))),
              const SizedBox(width: 64),
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
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            color: isActive ? AppColors.primary : tc.onSurface50,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : tc.onSurface50,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
