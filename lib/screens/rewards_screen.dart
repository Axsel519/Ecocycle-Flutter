import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/custom_header.dart';

class RewardsScreen extends StatelessWidget {
  final VoidCallback? onHeaderProfilePressed;
  final VoidCallback? onUserDataChanged;

  const RewardsScreen({
    super.key,
    this.onHeaderProfilePressed,
    this.onUserDataChanged,
  });

  final List<Map<String, dynamic>> _rewards = const [
    {'title': 'Eco Store Voucher', 'points': 1500, 'category': 'Discounts'},
    {'title': 'Tree Donation', 'points': 2000, 'category': 'Donations'},
    {'title': 'Eco Workshop Pass', 'points': 1800, 'category': 'Experiences'},
    {'title': 'Amazon Gift Card', 'points': 2500, 'category': 'Discounts'},
    {'title': 'Organic Soap Pack', 'points': 1200, 'category': 'Discounts'},
    {'title': 'Recycled Tote Bag', 'points': 900, 'category': 'Experiences'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            showBackground: true,
            onProfilePressed: onHeaderProfilePressed,
            onUserDataChanged: onUserDataChanged,
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: _rewards.length,
              itemBuilder: (context, index) {
                final item = _rewards[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.badgeGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.card_giftcard, color: AppColors.primary, size: 30),
                      ),
                      Text(
                        item['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                      ),
                      Text(
                        '${item['points']} pts',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Redeemed ${item['title']}!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('REDEEM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}