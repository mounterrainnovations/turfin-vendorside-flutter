// lib/features/auth/presentation/pages/vendor_signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/routing/app_router.dart';
import '../../data/auth_notifier.dart';

class VendorSignupScreen extends ConsumerStatefulWidget {
  const VendorSignupScreen({super.key});

  @override
  ConsumerState<VendorSignupScreen> createState() => _VendorSignupScreenState();
}

class _VendorSignupScreenState extends ConsumerState<VendorSignupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 1 — Account
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePassword  = true;
  bool _obscureConfirm   = true;

  // Page 2 — Business Info
  final _ownerNameCtrl  = TextEditingController();
  final _bizNameCtrl    = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _whatsappCtrl   = TextEditingController(); // optional
  final _gstCtrl        = TextEditingController(); // optional
  String _businessType  = 'individual';

  // Page 3 — Address
  final _houseNumberCtrl = TextEditingController(); // optional
  final _floorCtrl       = TextEditingController(); // optional
  final _towerBlockCtrl  = TextEditingController(); // optional
  final _landmarkCtrl    = TextEditingController(); // optional
  final _cityCtrl        = TextEditingController();
  String _selectedState  = '';
  final _pinCodeCtrl     = TextEditingController();
  // addressType hardcoded to 'work'; country hardcoded to 'India'
  final String _addressType = 'work';

  // Page 4 — Banking
  final _bankNameCtrl      = TextEditingController();
  final _accHolderCtrl     = TextEditingController();
  final _accNumberCtrl     = TextEditingController();
  final _confirmAccNumCtrl = TextEditingController();
  final _ifscCtrl          = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _ownerNameCtrl.dispose();
    _bizNameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _gstCtrl.dispose();
    _houseNumberCtrl.dispose();
    _floorCtrl.dispose();
    _towerBlockCtrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _pinCodeCtrl.dispose();
    _bankNameCtrl.dispose();
    _accHolderCtrl.dispose();
    _accNumberCtrl.dispose();
    _confirmAccNumCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  // ── Validation per page ────────────────────────────────────────────────────
  // Rules mirror the backend DTOs exactly (signup.dto.ts + create-vendor.dto.ts).

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  // IFSC format: 4 uppercase letters + '0' + 6 alphanumeric chars (e.g. HDFC0001234)
  static final _ifscRegex  = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  String? _validatePage(int page) {
    switch (page) {

      // ── Page 1: Account ──────────────────────────────────────────────────
      case 0:
        final email = _emailCtrl.text.trim();
        if (email.isEmpty) return 'Email is required.';
        if (!_emailRegex.hasMatch(email)) return 'Enter a valid email address (e.g. name@example.com).';
        if (_passwordCtrl.text.isEmpty) return 'Password is required.';
        if (_passwordCtrl.text.length < 8) return 'Password must be at least 8 characters.';
        if (_confirmPassCtrl.text.isEmpty) return 'Please confirm your password.';
        if (_passwordCtrl.text != _confirmPassCtrl.text) return 'Passwords do not match.';
        return null;

      // ── Page 2: Business Info ─────────────────────────────────────────────
      case 1:
        final owner = _ownerNameCtrl.text.trim();
        if (owner.isEmpty) return 'Owner full name is required.';
        if (owner.length > 100) return 'Owner full name must be at most 100 characters.';
        final biz = _bizNameCtrl.text.trim();
        if (biz.isEmpty) return 'Business name is required.';
        if (biz.length > 100) return 'Business name must be at most 100 characters.';
        final phone = _phoneCtrl.text.trim();
        if (phone.isEmpty) return 'Phone number is required.';
        if (phone.length > 20) return 'Phone number must be at most 20 characters.';
        final wa = _whatsappCtrl.text.trim();
        if (wa.isNotEmpty && wa.length > 20) return 'WhatsApp number must be at most 20 characters.';
        final gst = _gstCtrl.text.trim();
        if (gst.isNotEmpty && gst.length > 50) return 'GST number must be at most 50 characters.';
        return null;

      // ── Page 3: Address ───────────────────────────────────────────────────
      case 2:
        if (_selectedState.isEmpty) return 'State is required.';
        final city = _cityCtrl.text.trim();
        if (city.isEmpty) return 'City is required.';
        if (city.length > 50) return 'City must be at most 50 characters.';
        final pin = _pinCodeCtrl.text.trim();
        if (pin.isEmpty) return 'Pin code is required.';
        if (!RegExp(r'^\d{6}$').hasMatch(pin)) return 'Enter a valid 6-digit pin code.';
        final hn = _houseNumberCtrl.text.trim();
        if (hn.length > 50) return 'House/Flat number must be at most 50 characters.';
        final fl = _floorCtrl.text.trim();
        if (fl.length > 20) return 'Floor must be at most 20 characters.';
        final tb = _towerBlockCtrl.text.trim();
        if (tb.length > 50) return 'Tower/Block must be at most 50 characters.';
        final lm = _landmarkCtrl.text.trim();
        if (lm.length > 100) return 'Landmark must be at most 100 characters.';
        return null;

      // ── Page 4: Banking ───────────────────────────────────────────────────
      case 3:
        final bank = _bankNameCtrl.text.trim();
        if (bank.isEmpty) return 'Bank name is required.';
        if (bank.length > 100) return 'Bank name must be at most 100 characters.';
        final holder = _accHolderCtrl.text.trim();
        if (holder.isEmpty) return 'Account holder name is required.';
        if (holder.length > 100) return 'Account holder name must be at most 100 characters.';
        final accNum = _accNumberCtrl.text.trim();
        if (accNum.isEmpty) return 'Account number is required.';
        if (accNum.length > 50) return 'Account number must be at most 50 characters.';
        if (_confirmAccNumCtrl.text.trim() != accNum) return 'Account numbers do not match.';
        final ifsc = _ifscCtrl.text.trim().toUpperCase();
        if (ifsc.isEmpty) return 'IFSC code is required.';
        if (ifsc.length > 20) return 'IFSC code must be at most 20 characters.';
        if (!_ifscRegex.hasMatch(ifsc)) return 'Enter a valid IFSC code (e.g. HDFC0001234).';
        return null;

      default:
        return null;
    }
  }

  void _onNext() {
    final error = _validatePage(_currentPage);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }
    setState(() => _errorMessage = null);
    if (_currentPage < 3) {
      _pageController.nextPage(
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
      ref.read(authModeProvider.notifier).state = 'welcome';
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    final data = SignupFormData(
      email:              _emailCtrl.text.trim(),
      password:           _passwordCtrl.text,
      ownerFullName:      _ownerNameCtrl.text.trim(),
      businessName:       _bizNameCtrl.text.trim(),
      businessType:       _businessType,
      phone:              _phoneCtrl.text.trim(),
      whatsapp:           _whatsappCtrl.text.trim().isEmpty ? null : _whatsappCtrl.text.trim(),
      gstNumber:          _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
      addressType:        _addressType,
      houseNumber:        _houseNumberCtrl.text.trim().isEmpty ? null : _houseNumberCtrl.text.trim(),
      floor:              _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
      towerBlock:         _towerBlockCtrl.text.trim().isEmpty ? null : _towerBlockCtrl.text.trim(),
      landmark:           _landmarkCtrl.text.trim().isEmpty ? null : _landmarkCtrl.text.trim(),
      city:               _cityCtrl.text.trim(),
      state:              _selectedState,
      pinCode:            _pinCodeCtrl.text.trim(),
      country:            'India',
      bankName:           _bankNameCtrl.text.trim(),
      accountHolderName:  _accHolderCtrl.text.trim(),
      accountNumber:      _accNumberCtrl.text.trim(),
      ifsc:               _ifscCtrl.text.trim().toUpperCase(),
    );

    await ref.read(authNotifierProvider.notifier).signUp(data);

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);

    authState.when(
      data: (_) {
        ref.read(pendingPhoneProvider.notifier).state = data.phone;
        ref.read(authModeProvider.notifier).state = 'otp';
      },
      error: (e, _) {
        final msg = e.toString();
        setState(() { _isLoading = false; _errorMessage = msg; });
        // Email already exists — jump back to page 1 so user can correct it immediately.
        if (msg == 'An account with this email already exists.' && _currentPage != 0) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      },
      loading: () {},
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tc.onSurface10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: tc.onSurface, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pageTitle(_currentPage),
                          style: TextStyle(
                            color: tc.onSurface,
                            fontSize: 16,
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
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: List.generate(4, (i) {
                  final active = i <= _currentPage;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : tc.onSurface10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Error box ────────────────────────────────────────────────────
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x1AEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x66EF4444)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ),

            // ── Pages ────────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() { _currentPage = i; _errorMessage = null; }),
                children: [
                  _Page1Account(
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    confirmPassCtrl: _confirmPassCtrl,
                    obscurePassword: _obscurePassword,
                    obscureConfirm: _obscureConfirm,
                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                    onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  _Page2Business(
                    ownerNameCtrl: _ownerNameCtrl,
                    bizNameCtrl: _bizNameCtrl,
                    phoneCtrl: _phoneCtrl,
                    whatsappCtrl: _whatsappCtrl,
                    gstCtrl: _gstCtrl,
                    businessType: _businessType,
                    onBusinessTypeChanged: (v) => setState(() => _businessType = v!),
                  ),
                  _Page3Address(
                    houseNumberCtrl: _houseNumberCtrl,
                    floorCtrl: _floorCtrl,
                    towerBlockCtrl: _towerBlockCtrl,
                    landmarkCtrl: _landmarkCtrl,
                    cityCtrl: _cityCtrl,
                    selectedState: _selectedState,
                    onStateChanged: (v) => setState(() => _selectedState = v ?? ''),
                    pinCodeCtrl: _pinCodeCtrl,
                  ),
                  _Page4Banking(
                    bankNameCtrl: _bankNameCtrl,
                    accHolderCtrl: _accHolderCtrl,
                    accNumberCtrl: _accNumberCtrl,
                    confirmAccNumCtrl: _confirmAccNumCtrl,
                    ifscCtrl: _ifscCtrl,
                  ),
                ],
              ),
            ),

            // ── CTA button ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onNext,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : Text(
                          _currentPage < 3 ? 'NEXT' : 'CREATE ACCOUNT',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pageTitle(int page) => switch (page) {
    0 => 'Account Details',
    1 => 'Business Info',
    2 => 'Address',
    3 => 'Banking Details',
    _ => '',
  };
}

// ── Page 1 — Account ────────────────────────────────────────────────────────

class _Page1Account extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPassCtrl;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const _Page1Account({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmPassCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create your login credentials.',
              style: TextStyle(color: tc.onSurface60, fontSize: 14, height: 1.5)),
          const SizedBox(height: 28),
          _Label('Email', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'vendor@example.com',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _Label('Password', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Min. 8 characters',
            controller: passwordCtrl,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: tc.onSurface50, size: 20),
              onPressed: onTogglePassword,
            ),
          ),
          const SizedBox(height: 18),
          _Label('Confirm Password', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Re-enter password',
            controller: confirmPassCtrl,
            obscureText: obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: tc.onSurface50, size: 20),
              onPressed: onToggleConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2 — Business Info ───────────────────────────────────────────────────

class _Page2Business extends StatelessWidget {
  final TextEditingController ownerNameCtrl;
  final TextEditingController bizNameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController whatsappCtrl;
  final TextEditingController gstCtrl;
  final String businessType;
  final ValueChanged<String?> onBusinessTypeChanged;

  const _Page2Business({
    required this.ownerNameCtrl,
    required this.bizNameCtrl,
    required this.phoneCtrl,
    required this.whatsappCtrl,
    required this.gstCtrl,
    required this.businessType,
    required this.onBusinessTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about your business.',
              style: TextStyle(color: tc.onSurface60, fontSize: 14, height: 1.5)),
          const SizedBox(height: 28),
          _Label('Owner Full Name', tc),
          const SizedBox(height: 6),
          CustomTextField(hint: 'e.g. Rajesh Kumar', controller: ownerNameCtrl),
          const SizedBox(height: 18),
          _Label('Business Name', tc),
          const SizedBox(height: 6),
          CustomTextField(hint: 'e.g. Green Turf Arena', controller: bizNameCtrl),
          const SizedBox(height: 18),
          _Label('Business Type', tc),
          const SizedBox(height: 6),
          _DropdownField<String>(
            value: businessType,
            items: const [
              DropdownMenuItem(value: 'individual', child: Text('Individual')),
              DropdownMenuItem(value: 'company', child: Text('Company')),
              DropdownMenuItem(value: 'partnership', child: Text('Partnership')),
            ],
            onChanged: onBusinessTypeChanged,
          ),
          const SizedBox(height: 18),
          _Label('Phone Number', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: '+91 98765 43210',
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          _Label('WhatsApp Number  (optional)', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Same as phone or different',
            controller: whatsappCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          _Label('GST Number  (optional)', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. 27AAPFU0939F1ZV',
            controller: gstCtrl,
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
    );
  }
}

// ── Page 3 — Address ─────────────────────────────────────────────────────────

const _kIndianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
  'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  // Union Territories
  'Andaman and Nicobar Islands', 'Chandigarh',
  'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Jammu and Kashmir',
  'Ladakh', 'Lakshadweep', 'Puducherry',
];

class _Page3Address extends StatefulWidget {
  final TextEditingController houseNumberCtrl;
  final TextEditingController floorCtrl;
  final TextEditingController towerBlockCtrl;
  final TextEditingController landmarkCtrl;
  final TextEditingController cityCtrl;
  final String selectedState;
  final ValueChanged<String?> onStateChanged;
  final TextEditingController pinCodeCtrl;

  const _Page3Address({
    required this.houseNumberCtrl,
    required this.floorCtrl,
    required this.towerBlockCtrl,
    required this.landmarkCtrl,
    required this.cityCtrl,
    required this.selectedState,
    required this.onStateChanged,
    required this.pinCodeCtrl,
  });

  @override
  State<_Page3Address> createState() => _Page3AddressState();
}

class _Page3AddressState extends State<_Page3Address> {
  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Address fields — matches VendorAddressDto field order ─────────
          _Label('House / Flat No.  (optional)', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Shop 4 / Flat B-12',
            controller: widget.houseNumberCtrl,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Floor  (optional)', tc),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: 'e.g. 2nd',
                      controller: widget.floorCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Tower / Block  (optional)', tc),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: 'e.g. Tower A',
                      controller: widget.towerBlockCtrl,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _Label('Landmark  (optional)', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Near City Mall',
            controller: widget.landmarkCtrl,
          ),
          const SizedBox(height: 16),

          _Label('City', tc),
          const SizedBox(height: 6),
          CustomTextField(hint: 'e.g. Pune', controller: widget.cityCtrl),
          const SizedBox(height: 16),

          _Label('State', tc),
          const SizedBox(height: 6),
          _DropdownField<String>(
            value: widget.selectedState.isEmpty ? null : widget.selectedState,
            hint: 'Select state',
            items: _kIndianStates
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: widget.onStateChanged,
          ),
          const SizedBox(height: 16),

          _Label('Pin Code', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. 411001',
            controller: widget.pinCodeCtrl,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

// ── Page 4 — Banking ─────────────────────────────────────────────────────────

class _Page4Banking extends StatelessWidget {
  final TextEditingController bankNameCtrl;
  final TextEditingController accHolderCtrl;
  final TextEditingController accNumberCtrl;
  final TextEditingController confirmAccNumCtrl;
  final TextEditingController ifscCtrl;

  const _Page4Banking({
    required this.bankNameCtrl,
    required this.accHolderCtrl,
    required this.accNumberCtrl,
    required this.confirmAccNumCtrl,
    required this.ifscCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your bank account for payouts.',
              style: TextStyle(color: tc.onSurface60, fontSize: 14, height: 1.5)),
          const SizedBox(height: 28),
          _Label('Bank Name', tc),
          const SizedBox(height: 6),
          CustomTextField(hint: 'e.g. HDFC Bank', controller: bankNameCtrl),
          const SizedBox(height: 18),
          _Label('Account Holder Name', tc),
          const SizedBox(height: 6),
          CustomTextField(hint: 'As per bank records', controller: accHolderCtrl),
          const SizedBox(height: 18),
          _Label('Account Number', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. 00012345678901',
            controller: accNumberCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          _Label('Confirm Account Number', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Re-enter account number',
            controller: confirmAccNumCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          _Label('IFSC Code', tc),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. HDFC0001234',
            controller: ifscCtrl,
            keyboardType: TextInputType.visiblePassword,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 14, color: tc.onSurface30),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your banking details are encrypted and stored securely.',
                  style: TextStyle(color: tc.onSurface30, fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ],
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
    style: TextStyle(color: tc.onSurface70, fontSize: 13, fontWeight: FontWeight.w600),
  );
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: tc.onSurface10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tc.borderDefault),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null
              ? Text(hint!, style: TextStyle(color: tc.onSurface50, fontSize: 15))
              : null,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: tc.surface,
          style: TextStyle(color: tc.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: tc.onSurface50),
        ),
      ),
    );
  }
}
