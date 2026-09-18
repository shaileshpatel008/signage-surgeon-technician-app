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

  /// Web renders this status text in a flat navy — this app color-codes it
  /// by stage instead (client-requested, beyond web parity): amber while
  /// the technician is en route, blue once work has started, green once
  /// that visit is done. Matches both `_2` (repair visit) stage variants
  /// and cleaning's plain `tech_assigned`/etc. via substring checks rather
  /// than an exhaustive value list.
  static Color stageColor(String? stage) {
    if (stage == null || stage.isEmpty) return AppColors.brandGray;
    if (stage.contains('completed')) return AppColors.success;
    if (stage.contains('in_progress')) return AppColors.info;
    if (stage.contains('en_route')) return AppColors.warning;
    return AppColors.brandNavy;
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
