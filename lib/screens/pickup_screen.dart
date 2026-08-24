import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../core/app_colors.dart';
import '../widgets/custom_header.dart';

class PickupScreen extends StatefulWidget {
  final VoidCallback? onHeaderProfilePressed;
  final VoidCallback? onUserDataChanged;

  const PickupScreen({
    super.key,
    this.onHeaderProfilePressed,
    this.onUserDataChanged,
  });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357);
  String _pickupType = 'home';
  bool _isLocating = false;

  final Map<String, int> _quantities = {
    'Paper': 0,
    'Cans': 0,
    'Glass': 0,
    'Plastic': 0,
    'Electronics': 0,
  };

  final Map<String, int> _unitPrices = {
    'Paper': 10,
    'Cans': 25,
    'Glass': 20,
    'Plastic': 15,
    'Electronics': 50,
  };

  final Map<String, IconData> _categoryIcons = {
    'Paper': Icons.description_outlined,
    'Cans': Icons.local_drink_outlined,
    'Glass': Icons.wine_bar_outlined,
    'Plastic': Icons.water_drop_outlined,
    'Electronics': Icons.devices_other_outlined,
  };

  int get _totalPrice {
    return _quantities.entries.fold(0, (sum, item) {
      return sum + (item.value * (_unitPrices[item.key] ?? 0));
    });
  }

  void _updateQuantity(String key, int delta) {
    setState(() {
      final current = _quantities[key] ?? 0;
      final updated = (current + delta).clamp(0, 99);
      _quantities[key] = updated;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable GPS / Location services.')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied.')),
            );
          }
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newPos;
        _isLocating = false;
      });

      _mapController.move(newPos, 15.0);
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            showBackground: true,
            onProfilePressed: widget.onHeaderProfilePressed,
            onUserDataChanged: widget.onUserDataChanged,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 14 : 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Request',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select your location and the recyclables you wish to collect.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: isSmallScreen ? 180 : 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _selectedLocation,
                                    initialZoom: 13.0,
                                    onTap: (tapPosition, point) {
                                      setState(() => _selectedLocation = point);
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.ecocycle_app',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _selectedLocation,
                                          width: 44,
                                          height: 44,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: AppColors.error,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: FloatingActionButton.small(
                                    onPressed: _isLocating ? null : _getCurrentLocation,
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    elevation: 3,
                                    child: _isLocating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : const Icon(Icons.my_location, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('At-Home Pickup')),
                                selected: _pickupType == 'home',
                                selectedColor: AppColors.badgeGreen,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 11.5 : 13,
                                  color: _pickupType == 'home' ? AppColors.primary : AppColors.textDark,
                                ),
                                onSelected: (val) => setState(() => _pickupType = 'home'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Community Bin')),
                                selected: _pickupType == 'dropoff',
                                selectedColor: AppColors.badgeGreen,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 11.5 : 13,
                                  color: _pickupType == 'dropoff' ? AppColors.primary : AppColors.textDark,
                                ),
                                onSelected: (val) => setState(() => _pickupType = 'dropoff'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Select Waste Items',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._quantities.keys.map((key) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.badgeGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _categoryIcons[key] ?? Icons.recycling,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        '\$${_unitPrices[key]}/unit',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 22),
                                      onPressed: () => _updateQuantity(key, -1),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      child: Text(
                                        '${_quantities[key]}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                                      onPressed: () => _updateQuantity(key, 1),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.badgeGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimated Total:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              Text(
                                '\$$_totalPrice',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _totalPrice == 0
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Pickup Request Submitted Successfully!')),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('SUBMIT REQUEST', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}