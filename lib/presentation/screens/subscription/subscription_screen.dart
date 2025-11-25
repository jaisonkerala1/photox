import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.proGold.withOpacity(0.3),
                    AppColors.proGold.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Pro icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.proGradient),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.proGold.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 24),
                  
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.proGradient,
                    ).createShader(bounds),
                    child: Text(
                      'PhotoX PRO',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Unlock unlimited AI photo magic',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Features list
                  ..._buildFeatures(context),
                  
                  const SizedBox(height: 32),
                  
                  // Pricing cards
                  Row(
                    children: [
                      Expanded(
                        child: _PricingCard(
                          title: 'Monthly',
                          price: '\$9.99',
                          period: '/month',
                          isPopular: false,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PricingCard(
                          title: 'Yearly',
                          price: '\$59.99',
                          period: '/year',
                          isPopular: true,
                          savings: 'Save 50%',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 24),
                  
                  // Subscribe button
                  CustomButton(
                    text: 'Subscribe Now',
                    onPressed: () {
                      // TODO: Implement subscription purchase
                    },
                    isFullWidth: true,
                    gradientColors: AppColors.proGradient,
                    prefixIcon: Icons.star_rounded,
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Restore purchases
                  TextButton(
                    onPressed: () {
                      // TODO: Implement restore purchases
                    },
                    child: const Text('Restore Purchases'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Terms
                  Text(
                    'Payment will be charged to your account. Subscription automatically renews unless cancelled.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures(BuildContext context) {
    final features = [
      ('Unlimited AI edits', Icons.all_inclusive_rounded),
      ('HD quality export', Icons.hd_rounded),
      ('All filters & styles', Icons.palette_rounded),
      ('No ads', Icons.block_rounded),
      ('Priority processing', Icons.speed_rounded),
      ('Advanced face tools', Icons.face_retouching_natural),
      ('Cloud storage', Icons.cloud_rounded),
      ('New features first', Icons.new_releases_rounded),
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.proGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(feature.$2, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              feature.$1,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 50)));
    }).toList();
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isPopular;
  final String? savings;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
    this.savings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPopular ? null : AppColors.cardBackground,
          gradient: isPopular ? const LinearGradient(colors: AppColors.proGradient) : null,
          borderRadius: BorderRadius.circular(20),
          border: isPopular ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            if (isPopular && savings != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  savings!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.proGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isPopular ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPopular ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: period,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPopular ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


