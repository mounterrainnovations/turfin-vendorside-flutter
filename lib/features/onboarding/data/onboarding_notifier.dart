// lib/features/onboarding/data/onboarding_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorOnboardingState {
  final int step;
  final bool submitted;

  // Step 1 — Business
  final String businessName;
  final String businessType;
  final String businessService;
  final String ownerName;

  // Step 2 — Contact & Identity
  final String phone;
  final String whatsapp;
  final String email;
  final String gstNumber;
  final String addressLine;
  final String city;
  final String addressState;
  final String pincode;

  // Step 3 — Bank
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String branchName;

  // Step 4 — KYC (local file paths, uploaded later)
  final String? aadharPath;
  final String? panPath;
  final String? companyRegPath;

  const VendorOnboardingState({
    this.step = 0,
    this.submitted = false,
    this.businessName = '',
    this.businessType = '',
    this.businessService = '',
    this.ownerName = '',
    this.phone = '',
    this.whatsapp = '',
    this.email = '',
    this.gstNumber = '',
    this.addressLine = '',
    this.city = '',
    this.addressState = '',
    this.pincode = '',
    this.accountHolder = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.branchName = '',
    this.aadharPath,
    this.panPath,
    this.companyRegPath,
  });

  VendorOnboardingState copyWith({
    int? step,
    bool? submitted,
    String? businessName,
    String? businessType,
    String? businessService,
    String? ownerName,
    String? phone,
    String? whatsapp,
    String? email,
    String? gstNumber,
    String? addressLine,
    String? city,
    String? addressState,
    String? pincode,
    String? accountHolder,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? aadharPath,
    String? panPath,
    String? companyRegPath,
  }) {
    return VendorOnboardingState(
      step:            step            ?? this.step,
      submitted:       submitted       ?? this.submitted,
      businessName:    businessName    ?? this.businessName,
      businessType:    businessType    ?? this.businessType,
      businessService: businessService ?? this.businessService,
      ownerName:       ownerName       ?? this.ownerName,
      phone:           phone           ?? this.phone,
      whatsapp:        whatsapp        ?? this.whatsapp,
      email:           email           ?? this.email,
      gstNumber:       gstNumber       ?? this.gstNumber,
      addressLine:     addressLine     ?? this.addressLine,
      city:            city            ?? this.city,
      addressState:    addressState    ?? this.addressState,
      pincode:         pincode         ?? this.pincode,
      accountHolder:   accountHolder   ?? this.accountHolder,
      accountNumber:   accountNumber   ?? this.accountNumber,
      ifscCode:        ifscCode        ?? this.ifscCode,
      branchName:      branchName      ?? this.branchName,
      aadharPath:      aadharPath      ?? this.aadharPath,
      panPath:         panPath         ?? this.panPath,
      companyRegPath:  companyRegPath  ?? this.companyRegPath,
    );
  }
}

class VendorOnboardingNotifier extends StateNotifier<VendorOnboardingState> {
  VendorOnboardingNotifier() : super(const VendorOnboardingState());

  void nextStep() => state = state.copyWith(step: state.step + 1);
  void prevStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }
  void submit() => state = state.copyWith(submitted: true);

  // Step 1
  void setBusinessName(String v)    => state = state.copyWith(businessName: v);
  void setBusinessType(String v)    => state = state.copyWith(businessType: v);
  void setBusinessService(String v) => state = state.copyWith(businessService: v);
  void setOwnerName(String v)       => state = state.copyWith(ownerName: v);

  // Step 2
  void setPhone(String v)        => state = state.copyWith(phone: v);
  void setWhatsapp(String v)     => state = state.copyWith(whatsapp: v);
  void setEmail(String v)        => state = state.copyWith(email: v);
  void setGst(String v)          => state = state.copyWith(gstNumber: v);
  void setAddressLine(String v)  => state = state.copyWith(addressLine: v);
  void setCity(String v)         => state = state.copyWith(city: v);
  void setAddressState(String v) => state = state.copyWith(addressState: v);
  void setPincode(String v)      => state = state.copyWith(pincode: v);

  // Step 3
  void setAccountHolder(String v) => state = state.copyWith(accountHolder: v);
  void setAccountNumber(String v) => state = state.copyWith(accountNumber: v);
  void setIfsc(String v)          => state = state.copyWith(ifscCode: v);
  void setBranchName(String v)    => state = state.copyWith(branchName: v);

  // Step 4
  void setAadhar(String path)     => state = state.copyWith(aadharPath: path);
  void setPan(String path)        => state = state.copyWith(panPath: path);
  void setCompanyReg(String path) => state = state.copyWith(companyRegPath: path);
}

final vendorOnboardingProvider =
    StateNotifierProvider<VendorOnboardingNotifier, VendorOnboardingState>(
  (ref) => VendorOnboardingNotifier(),
);
