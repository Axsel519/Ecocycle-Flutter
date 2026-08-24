import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/custom_header.dart';

class StepItem {
  final String id;
  final String title;
  final String desc;
  final String? imagePath;
  final IconData? iconData;

  const StepItem({
    required this.id,
    required this.title,
    required this.desc,
    this.imagePath,
    this.iconData,
  });
}

const List<StepItem> stepsData = [
  StepItem(
    id: "step-1",
    title: "SCAN WASTE",
    desc: "Snap a photo of your recyclables using the mobile app.",
    imagePath: "assets/images/Scan.png",
  ),
  StepItem(
    id: "step-2",
    title: "AI CLASSIFICATION",
    desc: "Our AI model accurately identifies plastic, glass, paper, and metal in real-time.",
    imagePath: "assets/images/Ai.png",
  ),
  StepItem(
    id: "step-3",
    title: "EARN REWARDS",
    desc: "Get points automatically credited to your digital wallet for each successful scan.",
    iconData: Icons.card_giftcard,
  ),
  StepItem(
    id: "step-4",
    title: "REDEEM COUPONS",
    desc: "Exchange points for discounts or vouchers from our partner organizations.",
    imagePath: "assets/images/COUPONS.png",
  ),
];

class HomeScreen extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onPickupPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUserDataChanged;

  const HomeScreen({
    super.key,
    required this.onScanPressed,
    required this.onPickupPressed,
    this.onProfilePressed,
    this.onUserDataChanged,
  });

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
            onProfilePressed: onProfilePressed,
            onUserDataChanged: onUserDataChanged,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/images/bghome.png'),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(
                          isSmallScreen ? 16 : 24,
                          isSmallScreen ? 20 : 32,
                          isSmallScreen ? 16 : 24,
                          isSmallScreen ? 24 : 36,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI-DRIVEN RECYCLING',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 22 : 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F2D23),
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 22 : 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F2D23),
                                  letterSpacing: -0.5,
                                  height: 1.15,
                                  fontFamily: 'sans-serif',
                                ),
                                children: const [
                                  TextSpan(text: 'GET '),
                                  TextSpan(
                                    text: 'REWARDED',
                                    style: TextStyle(
                                      color: Color(0xD40D5C46),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'EcoCycle uses AI to classify your household waste, awarding you points for discounts and offering convenient at-home pickups. Transform waste, earn value, save the planet.',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12.5 : 14,
                                color: AppColors.textBody,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 420) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildPrimaryButton('START RECYCLING NOW', onScanPressed),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildSecondaryButton('REQUEST AT-HOME PICKUP', onPickupPressed),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildPrimaryButton('START RECYCLING NOW', onScanPressed),
                                    const SizedBox(height: 10),
                                    _buildSecondaryButton('REQUEST AT-HOME PICKUP', onPickupPressed),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: 28,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'JUST FOUR STEPS',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'EcoCycle uses AI to classify your household waste, awarding you points for discounts and offering convenient at-home pickups.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSubtitle,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ...stepsData.map((step) => _buildStepCard(step, isSmallScreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF198754),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        elevation: 1,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSecondaryButton(String title, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF198754),
        side: const BorderSide(color: Color(0xFF198754), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStepCard(StepItem step, bool isSmallScreen) {
    final double iconBoxSize = isSmallScreen ? 75 : 90;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 14 : 20,
        vertical: isSmallScreen ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: step.imagePath != null
                  ? Image.asset(
                      step.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: AppColors.textDark,
                      ),
                    )
                  : Icon(
                      step.iconData,
                      size: isSmallScreen ? 34 : 40,
                      color: AppColors.textDark,
                    ),
            ),
          ),
          Text(
            step.title,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            step.desc,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: AppColors.textDesc,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}