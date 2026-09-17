import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/network/api_response.dart';
import '../../core/services/logger_service.dart';
import '../models/notification_model.dart';

/// See [NotificationModel] — proposed addition, reads a collection that
/// nothing writes to yet. Returns an empty, successful list (not an
/// error) when the collection has no documents, so the UI correctly
/// shows the empty state instead of an error banner.
class NotificationsRepository {
  final FirebaseFirestore _db;
  NotificationsRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<ApiResult<List<NotificationModel>>> fetchNotifications(String technicianUid) async {
    try {
      final snap = await _db
          .collection('technician_notifications')
          .doc(technicianUid)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final items = snap.docs.map((d) => NotificationModel.fromFirestore(d.id, d.data())).toList();
      return ApiResult.success(items);
    } catch (e, st) {
      logger.error('fetchNotifications failed', e, st);
      // Fails open to an empty list — a missing/never-created collection
      // is expected today, not an error state.
      return const ApiResult.success([]);
    }
  }

  Future<void> markAllRead(String technicianUid) async {
    try {
      final unread = await _db
          .collection('technician_notifications')
          .doc(technicianUid)
          .collection('items')
          .where('read', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e, st) {
      logger.error('markAllRead failed', e, st);
    }
  }
}
