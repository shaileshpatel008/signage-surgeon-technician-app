/// Small formatting helpers shared across features.
class CommonUtils {
  CommonUtils._();

  /// `tech_en_route` -> `Tech En Route`. Mirrors `formatStage()` in
  /// `labour/page.tsx` exactly so status text reads identically to web.
  static String formatStage(String? stage) {
    if (stage == null || stage.isEmpty) return '—';
    return stage.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
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
