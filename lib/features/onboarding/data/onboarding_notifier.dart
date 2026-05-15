// lib/features/onboarding/data/onboarding_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorOnboardingState {
  final int step;
  final bool submitted;

  // Step 2 — Personal Details
  final String fullName;
  final String email;

  // Step 3 — Arena Setup, Section A
  final String arenaName;
  final String arenaDescription;
  final List<String> sportsAvailable;

  // Step 3 — Arena Setup, Section B
  final String fullAddress;
  final String landmark;
  final String city;
  final String arenaState;
  final String pincode;
  final double? mapLat;
  final double? mapLng;

  // Step 3 — Arena Setup, Section C
  final String? coverPhotoPath;
  final List<String> galleryPhotoPaths;
  final List<String> videoPaths;

  // Step 3 — Arena Setup, Section D
  final List<String> amenities;

  // Step 3 — Arena Setup, Section E
  final String openingTime;
  final String closingTime;
  final List<String> availableDays;
  final String weekdayPrice;
  final String weekendPrice;
  final String peakHourPrice;
  final String slotDuration;

  // Step 4 — KYC Verification
  final String? aadhaarPath;
  final String? panPath;
  final String gstNumber;
  final String? gstCertPath;

  // Step 5 — Bank & Payout Details
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String? cancelledChequePath;

  const VendorOnboardingState({
    this.step = 0,
    this.submitted = false,
    this.fullName = '',
    this.email = '',
    this.arenaName = '',
    this.arenaDescription = '',
    this.sportsAvailable = const [],
    this.fullAddress = '',
    this.landmark = '',
    this.city = '',
    this.arenaState = '',
    this.pincode = '',
    this.mapLat,
    this.mapLng,
    this.coverPhotoPath,
    this.galleryPhotoPaths = const [],
    this.videoPaths = const [],
    this.amenities = const [],
    this.openingTime = '',
    this.closingTime = '',
    this.availableDays = const [],
    this.weekdayPrice = '',
    this.weekendPrice = '',
    this.peakHourPrice = '',
    this.slotDuration = '',
    this.aadhaarPath,
    this.panPath,
    this.gstNumber = '',
    this.gstCertPath,
    this.accountHolderName = '',
    this.bankName = '',
    this.accountNumber = '',
    this.confirmAccountNumber = '',
    this.ifscCode = '',
    this.cancelledChequePath,
  });

  VendorOnboardingState copyWith({
    int? step,
    bool? submitted,
    String? fullName,
    String? email,
    String? arenaName,
    String? arenaDescription,
    List<String>? sportsAvailable,
    String? fullAddress,
    String? landmark,
    String? city,
    String? arenaState,
    String? pincode,
    double? mapLat,
    double? mapLng,
    String? coverPhotoPath,
    List<String>? galleryPhotoPaths,
    List<String>? videoPaths,
    List<String>? amenities,
    String? openingTime,
    String? closingTime,
    List<String>? availableDays,
    String? weekdayPrice,
    String? weekendPrice,
    String? peakHourPrice,
    String? slotDuration,
    String? aadhaarPath,
    String? panPath,
    String? gstNumber,
    String? gstCertPath,
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? cancelledChequePath,
  }) {
    return VendorOnboardingState(
      step:                 step                 ?? this.step,
      submitted:            submitted            ?? this.submitted,
      fullName:             fullName             ?? this.fullName,
      email:                email                ?? this.email,
      arenaName:            arenaName            ?? this.arenaName,
      arenaDescription:     arenaDescription     ?? this.arenaDescription,
      sportsAvailable:      sportsAvailable      ?? this.sportsAvailable,
      fullAddress:          fullAddress          ?? this.fullAddress,
      landmark:             landmark             ?? this.landmark,
      city:                 city                 ?? this.city,
      arenaState:           arenaState           ?? this.arenaState,
      pincode:              pincode              ?? this.pincode,
      mapLat:               mapLat               ?? this.mapLat,
      mapLng:               mapLng               ?? this.mapLng,
      coverPhotoPath:       coverPhotoPath       ?? this.coverPhotoPath,
      galleryPhotoPaths:    galleryPhotoPaths    ?? this.galleryPhotoPaths,
      videoPaths:           videoPaths           ?? this.videoPaths,
      amenities:            amenities            ?? this.amenities,
      openingTime:          openingTime          ?? this.openingTime,
      closingTime:          closingTime          ?? this.closingTime,
      availableDays:        availableDays        ?? this.availableDays,
      weekdayPrice:         weekdayPrice         ?? this.weekdayPrice,
      weekendPrice:         weekendPrice         ?? this.weekendPrice,
      peakHourPrice:        peakHourPrice        ?? this.peakHourPrice,
      slotDuration:         slotDuration         ?? this.slotDuration,
      aadhaarPath:          aadhaarPath          ?? this.aadhaarPath,
      panPath:              panPath              ?? this.panPath,
      gstNumber:            gstNumber            ?? this.gstNumber,
      gstCertPath:          gstCertPath          ?? this.gstCertPath,
      accountHolderName:    accountHolderName    ?? this.accountHolderName,
      bankName:             bankName             ?? this.bankName,
      accountNumber:        accountNumber        ?? this.accountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      ifscCode:             ifscCode             ?? this.ifscCode,
      cancelledChequePath:  cancelledChequePath  ?? this.cancelledChequePath,
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

  // Step 2 — Personal Details
  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setEmail(String v)    => state = state.copyWith(email: v);

  // Step 3 — Arena Setup, Section A
  void setArenaName(String v)        => state = state.copyWith(arenaName: v);
  void setArenaDescription(String v) => state = state.copyWith(arenaDescription: v);
  void setSports(List<String> v)     => state = state.copyWith(sportsAvailable: v);

  // Step 3 — Arena Setup, Section B
  void setFullAddress(String v) => state = state.copyWith(fullAddress: v);
  void setLandmark(String v)    => state = state.copyWith(landmark: v);
  void setCity(String v)        => state = state.copyWith(city: v);
  void setArenaState(String v)  => state = state.copyWith(arenaState: v);
  void setPincode(String v)     => state = state.copyWith(pincode: v);
  void setMapLocation(double lat, double lng) =>
      state = state.copyWith(mapLat: lat, mapLng: lng);

  // Step 3 — Arena Setup, Section C
  void setCoverPhoto(String path)       => state = state.copyWith(coverPhotoPath: path);
  void setGalleryPhotos(List<String> v) => state = state.copyWith(galleryPhotoPaths: v);
  void setVideos(List<String> v)        => state = state.copyWith(videoPaths: v);

  // Step 3 — Arena Setup, Section D
  void setAmenities(List<String> v) => state = state.copyWith(amenities: v);

  // Step 3 — Arena Setup, Section E
  void setOpeningTime(String v)         => state = state.copyWith(openingTime: v);
  void setClosingTime(String v)         => state = state.copyWith(closingTime: v);
  void setAvailableDays(List<String> v) => state = state.copyWith(availableDays: v);
  void setWeekdayPrice(String v)        => state = state.copyWith(weekdayPrice: v);
  void setWeekendPrice(String v)        => state = state.copyWith(weekendPrice: v);
  void setPeakHourPrice(String v)       => state = state.copyWith(peakHourPrice: v);
  void setSlotDuration(String v)        => state = state.copyWith(slotDuration: v);

  // Step 4 — KYC
  void setAadhaar(String path)   => state = state.copyWith(aadhaarPath: path);
  void setPan(String path)       => state = state.copyWith(panPath: path);
  void setGstNumber(String v)    => state = state.copyWith(gstNumber: v);
  void setGstCert(String path)   => state = state.copyWith(gstCertPath: path);

  // Step 5 — Bank Details
  void setAccountHolderName(String v)    => state = state.copyWith(accountHolderName: v);
  void setBankName(String v)             => state = state.copyWith(bankName: v);
  void setAccountNumber(String v)        => state = state.copyWith(accountNumber: v);
  void setConfirmAccountNumber(String v) => state = state.copyWith(confirmAccountNumber: v);
  void setIfsc(String v)                 => state = state.copyWith(ifscCode: v);
  void setCancelledCheque(String path)   => state = state.copyWith(cancelledChequePath: path);
}

final vendorOnboardingProvider =
    StateNotifierProvider<VendorOnboardingNotifier, VendorOnboardingState>(
  (ref) => VendorOnboardingNotifier(),
);
