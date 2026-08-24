import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../widgets/custom_header.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onScanWaste;
  final VoidCallback? onHeaderProfilePressed;
  final VoidCallback? onUserDataChanged;

  const DashboardScreen({
    super.key,
    this.onScanWaste,
    this.onHeaderProfilePressed,
    this.onUserDataChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _adminUser;

  final List<Map<String, dynamic>> recentActivities = const [
    {
      'id': 1,
      'type': 'Plastic & Cans',
      'date': 'Aug 5, 2026',
      'points': '+150 EcoPoints',
      'status': 'Completed',
    },
    {
      'id': 2,
      'type': 'Paper & Cardboard',
      'date': 'Aug 2, 2026',
      'points': '+80 EcoPoints',
      'status': 'Completed',
    },
    {
      'id': 3,
      'type': 'Redeemed Amazon Voucher',
      'date': 'Jul 28, 2026',
      'points': '-1500 EcoPoints',
      'status': 'Redeemed',
    },
    {
      'id': 4,
      'type': 'Glass Bottles',
      'date': 'Jul 20, 2026',
      'points': '+120 EcoPoints',
      'status': 'Completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      setState(() {
        _adminUser = jsonDecode(userStr);
      });
    }
  }

  String get _adminFullName {
    if (_adminUser == null) return "Admin";
    if (_adminUser!['firstName'] != null && _adminUser!['lastName'] != null) {
      return '${_adminUser!['firstName'].toString().trim()} ${_adminUser!['lastName'].toString().trim()}';
    }
    return _adminUser!['name'] ?? 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    final int userPoints = _adminUser?['points'] ?? 2450;
    const int recycledCount = 38;
    const int pendingPickups = 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            showBackground: true,
            onProfilePressed: widget.onHeaderProfilePressed,
            onUserDataChanged: () {
              _loadAdmin();
              if (widget.onUserDataChanged != null) widget.onUserDataChanged!();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            children: [
                              const TextSpan(text: 'Welcome back, '),
                              TextSpan(
                                text: _adminFullName,
                                style: const TextStyle(color: Color(0xFF006847)),
                              ),
                              const TextSpan(text: '! 👋'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Track your recycling impact, manage pickups, and check your earned rewards.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onScanWaste,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006847),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Scan New Waste 📸',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.park_outlined,
                        title: 'Total EcoPoints',
                        value: '$userPoints',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        icon: Icons.recycling,
                        title: 'Items Recycled',
                        value: '$recycledCount kg',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        icon: Icons.local_shipping_outlined,
                        title: 'Pending Pickups',
                        value: '$pendingPickups',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Reward Goal 🎯',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '3000 EcoPoints for \$20 Discount Voucher',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (userPoints / 3000).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006847)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$userPoints pts', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const Text('3000 pts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const Divider(color: AppColors.border),
                        ...recentActivities.map((act) => _buildActivityItem(act)),
                      ],
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

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.badgeGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF006847), size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> act) {
    final bool isPlus = (act['points'] as String).startsWith('+');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act['type'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                Text(
                  act['date'],
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                act['points'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isPlus ? const Color(0xFF006847) : const Color(0xFFE11D48),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: act['status'] == 'Completed' ? AppColors.badgeGreen : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  act['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: act['status'] == 'Completed' ? const Color(0xFF006847) : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}