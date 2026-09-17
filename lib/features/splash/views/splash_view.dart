import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/splash_controller.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandNavy,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.skipToLogin,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative blobs — clipped to the screen bounds so they
            // never bleed into (or clash with) the status bar, unlike the
            // unclipped, off-screen-positioned version this replaced.
            ClipRect(
              child: Stack(
                children: [
                  Positioned(top: -40, right: -60, child: _blob(200, AppColors.brandRed.withValues(alpha: 0.14))),
                  Positioned(bottom: -60, left: -70, child: _blob(220, AppColors.brandYellow.withValues(alpha: 0.08))),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Stack(
                  children: [
                    // True centering — not a Spacer-balanced Column, which
                    // does not reliably center short content vertically
                    // once safe-area insets are uneven top vs. bottom.
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 20)),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'The Signage Surgeon',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.brandYellow.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.brandYellow.withValues(alpha: 0.35)),
                            ),
                            child: const Text(
                              'TECHNICIAN APP',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.brandYellow),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 4,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(colors: [AppColors.brandYellow, AppColors.brandRed]),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Repair · Rebrand · Reliably',
                            style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                          ),
                        ],
                      ),
                    ),
                    // Loading indicator pinned to the bottom, independent
                    // of the centered block's height.
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: Center(child: _LoadingDots()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = (_controller.value - (i * 0.15)) % 1.0;
            final opacity = t < 0.4 ? 1.0 : 0.25;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
