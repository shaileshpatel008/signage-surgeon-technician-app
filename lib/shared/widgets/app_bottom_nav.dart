import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';

/// The 3-tab bar (Home / Reports / Profile) — a **proposed addition**,
/// since the web app has no tabbed navigation at all (it's one page).
/// Notifications and Settings are one level deeper (via the header bell
/// icon and the Profile menu), matching the approved mockup.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _go(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Get.offNamed(Routes.dashboard);
        break;
      case 1:
        Get.offNamed(Routes.reports);
        break;
      case 2:
        Get.offNamed(Routes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', active: currentIndex == 0, onTap: () => _go(0)),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports', active: currentIndex == 1, onTap: () => _go(1)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', active: currentIndex == 2, onTap: () => _go(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brandRed : AppColors.mutedText;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
