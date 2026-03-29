// lib/features/home/presentation/widgets/profile_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vendor_card.dart';
import '../../../auth/data/auth_notifier.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: tc.onSurface),
              ),
              const SizedBox(height: 20),

              // ── Business card ────────────────────────────────────
              _BusinessCard(),

              const SizedBox(height: 24),

              // ── Account section ──────────────────────────────────
              _SectionLabel('ACCOUNT'),
              const SizedBox(height: 8),
              VendorCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingRow(
                      icon: Icons.verified_user_outlined,
                      label: 'KYC & Verification',
                      trailing: _KycBadge(),
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.account_balance_outlined,
                      label: 'Bank Account',
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Preferences section ──────────────────────────────
              _SectionLabel('PREFERENCES'),
              const SizedBox(height: 8),
              VendorCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      value: 'English',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Support section ──────────────────────────────────
              _SectionLabel('SUPPORT'),
              const SizedBox(height: 8),
              VendorCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingRow(
                      icon: Icons.help_outline,
                      label: 'Help & FAQ',
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.chat_bubble_outline,
                      label: 'Contact Support',
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.info_outline,
                      label: 'App Version',
                      value: '1.0.0',
                      onTap: null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Sign out ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, ref),
                  icon: Icon(Icons.logout, size: 18, color: AppColors.error),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withAlpha(80)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Business Card ───────────────────────────────────────────────────────────

class _BusinessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return VendorCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: const Center(
              child: Text(
                'TF',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TurfIn Sports',
                  style: TextStyle(
                    color: tc.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'vendor@turfin.com',
                  style: TextStyle(color: tc.onSurface50, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: tc.onSurface30),
                    const SizedBox(width: 4),
                    Text(
                      'Mumbai, Maharashtra',
                      style: TextStyle(color: tc.onSurface50, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: tc.onSurface50, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Section Label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Text(
      title,
      style: TextStyle(
        color: tc.sectionLabel,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Setting Row ─────────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: tc.onSurface50, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: tc.onSurface, fontSize: 14),
              ),
            ),
            if (value != null)
              Text(value!, style: TextStyle(color: tc.onSurface50, fontSize: 13)),
            if (trailing != null) trailing!,
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: tc.onSurface30, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

// ── KYC Badge ───────────────────────────────────────────────────────────────

class _KycBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 50,
      color: AppThemeColors.of(context).onSurface10,
    );
  }
}
