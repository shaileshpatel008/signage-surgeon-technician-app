import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Firestore Timestamp <-> DateTime helpers, plus the "is this visit today"
/// grouping logic used to mirror `labour/page.tsx`'s Today/Upcoming split.
class AppDateUtils {
  AppDateUtils._();

  static DateTime? fromTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;
    return isSameDay(date, DateTime.now());
  }

  static String formatVisitDate(DateTime? date) {
    if (date == null) return '';
    if (isToday(date)) return 'Today';
    return DateFormat('d MMM').format(date);
  }

  static String formatFullDate(DateTime date) => DateFormat('d MMM, yyyy').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return formatFullDate(date);
  }
}
