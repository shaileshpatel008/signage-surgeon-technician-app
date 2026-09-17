extension StringExtensions on String {
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isBlank => trim().isEmpty;
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}
