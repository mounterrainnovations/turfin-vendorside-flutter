// lib/features/onboarding/presentation/pages/map_location_picker_screen.dart
//
// Swiggy/Zomato-style map location picker using OpenStreetMap (no API key needed).
// User drags the map — the pin stays fixed at center.
// Address is reverse-geocoded from Nominatim as the map settles.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_notifier.dart';

class MapLocationPickerScreen extends ConsumerStatefulWidget {
  /// When provided, CONFIRM calls this instead of writing to vendorOnboardingProvider.
  final void Function(double lat, double lng, String address)? onConfirm;
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const MapLocationPickerScreen({
    super.key,
    this.onConfirm,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  @override
  ConsumerState<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState
    extends ConsumerState<MapLocationPickerScreen> {
  final _mapController = MapController();

  // Default center: India
  LatLng _center = const LatLng(20.5937, 78.9629);
  String _address = 'Drag the map to pin your arena location';
  bool _isLoadingAddress = false;
  bool _isLoadingLocation = false;
  bool _hasLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.onConfirm != null) {
      if (widget.initialLat != null && widget.initialLng != null) {
        _center = LatLng(widget.initialLat!, widget.initialLng!);
        _address = widget.initialAddress ?? 'Location previously set';
        _hasLocation = true;
      }
    } else {
      final s = ref.read(vendorOnboardingProvider);
      if (s.mapLat != null && s.mapLng != null) {
        _center = LatLng(s.mapLat!, s.mapLng!);
        _address = s.mapAddress.isNotEmpty ? s.mapAddress : 'Location previously set';
        _hasLocation = true;
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Reverse geocode via Nominatim (OpenStreetMap) ─────────────────────────

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isLoadingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'TurfinVendorApp/1.0'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final display = (data['display_name'] as String?) ?? '';
        setState(() {
          _address = display.isNotEmpty
              ? display
              : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
          _isLoadingAddress = false;
          _hasLocation = true;
        });
        return;
      }
    } catch (_) {}
    setState(() {
      _address =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      _isLoadingAddress = false;
      _hasLocation = true;
    });
  }

  // ── Get device location ───────────────────────────────────────────────────

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Please enable location services.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Location permission is required.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      _mapController.move(latLng, 17.0);
      setState(() {
        _center = latLng;
        _isLoadingLocation = false;
      });
      await _reverseGeocode(latLng);
    } catch (e) {
      _showSnack('Could not get location. Please drag the map.');
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  void _confirmLocation() {
    if (widget.onConfirm != null) {
      widget.onConfirm!(_center.latitude, _center.longitude, _address);
    } else {
      ref.read(vendorOnboardingProvider.notifier).setMapLocation(
            _center.latitude,
            _center.longitude,
            _address,
          );
    }
    Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      body: Stack(
        children: [

          // ── Map ─────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _hasLocation ? 16.0 : 5.0,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd ||
                    event is MapEventFlingAnimationEnd ||
                    event is MapEventRotateEnd) {
                  final newCenter = _mapController.camera.center;
                  setState(() => _center = newCenter);
                  _reverseGeocode(newCenter);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.turfin.vendor',
                maxZoom: 19,
              ),
            ],
          ),

          // ── Fixed center pin ─────────────────────────────────────────
          // Pin is shifted up so its tip aligns with map center
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_pin,
                        color: AppColors.primary,
                        size: 52,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar (back + current location) ────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _MapButton(
                      onTap: () => Navigator.pop(context),
                      tc: tc,
                      child: Icon(Icons.arrow_back_rounded,
                          color: tc.onSurface, size: 22),
                    ),
                    const Spacer(),
                    _MapButton(
                      onTap: _isLoadingLocation
                          ? null
                          : _goToCurrentLocation,
                      tc: tc,
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.my_location_rounded,
                              color: AppColors.primary, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom address sheet ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: tc.onSurface20,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text(
                    'SELECTED LOCATION',
                    style: TextStyle(
                      color: tc.sectionLabel,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.location_pin,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _isLoadingAddress
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 14,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: tc.onSurface10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 14,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: tc.onSurface10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _address,
                                style: TextStyle(
                                  color: tc.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _hasLocation ? _confirmLocation : null,
                      child: const Text(
                        'CONFIRM LOCATION',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating map button ───────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final VoidCallback? onTap;
  final AppThemeColors tc;
  final Widget child;

  const _MapButton({
    required this.onTap,
    required this.tc,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: tc.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
