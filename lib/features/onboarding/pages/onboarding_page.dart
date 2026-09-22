import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  static const String onboardingCompletedKey = 'onboarding_completed';

  const OnboardingScreen({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(onboardingCompletedKey, true);

    if (!context.mounted) {
      return;
    }

    onGetStarted();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF171B4B),
      body: Stack(
        children: [
          // Background decoration
          Positioned(top: -80, right: -70, child: _GlowCircle(size: 230, color: const Color(0xFF3F45A8))),

          Positioned(bottom: -100, left: -90, child: _GlowCircle(size: 280, color: const Color(0xFF252A65))),

          // Decorative location pins
          Positioned(
            top: size.height * 0.66,
            left: 55,
            child: Icon(Icons.location_on, size: 24, color: Colors.white.withValues(alpha: 0.12)),
          ),

          Positioned(
            top: size.height * 0.74,
            right: 55,
            child: Icon(Icons.location_on, size: 20, color: Colors.white.withValues(alpha: 0.10)),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Location icon
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                    child: const Center(child: Icon(Icons.location_on_rounded, size: 78, color: Colors.white)),
                  ),

                  const SizedBox(height: 34),

                  // App name
                  const Text(
                    'Salesman Tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Track • Manage • Grow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Stay connected with your team\n'
                      'and never miss a location.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 14, height: 1.6),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Get Started button
                  PrimaryButton(
                    label: 'Get Started',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _completeOnboarding(context),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
