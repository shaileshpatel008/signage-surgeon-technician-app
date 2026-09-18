import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Small formatting helpers shared across features.
class CommonUtils {
  CommonUtils._();

  /// `tech_en_route` -> `Tech En Route`. Mirrors `formatStage()` in
  /// `labour/page.tsx` exactly so status text reads identically to web.
  static String formatStage(String? stage) {
    if (stage == null || stage.isEmpty) return '—';
    return stage.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  /// Web renders this status as flat navy text — this app color-codes it
  /// instead (client-requested, beyond web parity), via the job card's
  /// status band: amber while the technician is en route, blue once work
  /// has started, green once that visit is done, navy for anything earlier
  /// (e.g. `tech_assigned`, before the technician has started the visit).
  /// Matches both `_2` (repair visit) stage variants and cleaning's plain
  /// stage names via substring checks rather than an exhaustive value list.
  static StageVisual stageVisual(String? stage) {
    if (stage != null && stage.contains('completed')) {
      return const StageVisual(
        background: AppColors.success,
        foreground: AppColors.white,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (stage != null && stage.contains('in_progress')) {
      return const StageVisual(background: AppColors.info, foreground: AppColors.white, icon: Icons.build_outlined);
    }
    if (stage != null && stage.contains('en_route')) {
      return const StageVisual(
        background: AppColors.brandYellow,
        foreground: AppColors.brandNavy,
        icon: Icons.access_time_rounded,
      );
    }
    return const StageVisual(
      background: AppColors.brandNavy,
      foreground: AppColors.white,
      icon: Icons.radio_button_unchecked_rounded,
    );
  }

  static String formatEquipment(String? value) {
    switch (value) {
      case 'ladder':
        return 'Ladder';
      case 'h_frame':
        return 'H-Frame (Palak)';
      case 'not_needed':
        return 'Not Needed';
      default:
        return value ?? '—';
    }
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static String orDash(String? value) => (value == null || value.trim().isEmpty) ? '—' : value;
}

/// Background/foreground/icon for a job card's status band — see
/// [CommonUtils.stageVisual].
class StageVisual {
  final Color background;
  final Color foreground;
  final IconData icon;

  const StageVisual({required this.background, required this.foreground, required this.icon});
}
