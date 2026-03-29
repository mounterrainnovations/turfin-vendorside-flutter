// lib/features/bookings/data/mock_bookings_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/vendor_booking_model.dart';

final mockVendorBookingsProvider = Provider<List<VendorBookingModel>>((ref) {
  final now = DateTime.now();
  return [
    VendorBookingModel(
      id: 'BK001',
      customerName: 'Arjun Mehta',
      customerPhone: '9876543210',
      fieldName: 'Field A — Football',
      bookingDate: now,
      startTime: '07:00 AM',
      endTime: '09:00 AM',
      totalAmountPaise: 120000,
      status: VendorBookingStatus.confirmed,
    ),
    VendorBookingModel(
      id: 'BK002',
      customerName: 'Priya Sharma',
      customerPhone: '9812345678',
      fieldName: 'Field B — Cricket',
      bookingDate: now,
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      totalAmountPaise: 80000,
      status: VendorBookingStatus.confirmed,
    ),
    VendorBookingModel(
      id: 'BK003',
      customerName: 'Rahul Singh',
      customerPhone: '9898989898',
      fieldName: 'Field A — Football',
      bookingDate: now.subtract(const Duration(days: 1)),
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      totalAmountPaise: 120000,
      status: VendorBookingStatus.completed,
    ),
    VendorBookingModel(
      id: 'BK004',
      customerName: 'Divya Nair',
      customerPhone: '9900000011',
      fieldName: 'Field B — Cricket',
      bookingDate: now.subtract(const Duration(days: 1)),
      startTime: '08:00 AM',
      endTime: '10:00 AM',
      totalAmountPaise: 80000,
      status: VendorBookingStatus.cancelled,
    ),
    VendorBookingModel(
      id: 'BK005',
      customerName: 'Karan Patel',
      customerPhone: '9111222333',
      fieldName: 'Field A — Football',
      bookingDate: now.add(const Duration(days: 1)),
      startTime: '06:00 AM',
      endTime: '08:00 AM',
      totalAmountPaise: 120000,
      status: VendorBookingStatus.confirmed,
    ),
  ];
});
