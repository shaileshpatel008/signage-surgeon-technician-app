import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// The small pill used for a job's service type ("Repairing",
/// "Rebranding", ...) — alternates red/yellow tints exactly like the
/// web sidebar's service icons do.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusBadge({super.key, required this.label, required this.background, required this.foreground});

  factory StatusBadge.forService(String serviceLabel) {
    final isYellow = serviceLabel == 'Rebranding' || serviceLabel == 'Signage Cleaning';
    return StatusBadge(
      label: serviceLabel,
      background: isYellow ? AppColors.warningBg : AppColors.dangerBg,
      foreground: isYellow ? AppColors.warning : AppColors.brandRed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimensions.radiusPill)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }
}
