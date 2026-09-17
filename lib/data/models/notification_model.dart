import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Proposed addition: no notification system exists for technicians on
/// web today. This models a NEW collection —
/// `technician_notifications/{technicianUid}/items/{id}` — that nothing
/// currently writes to. The read path here is real; wiring something
/// (a Cloud Function on job assignment, a Firestore trigger on quotation
/// approval, etc.) to actually populate it is a backend task the web repo
/// doesn't have yet.
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? relatedCollection;
  final String? relatedRequestId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.relatedCollection,
    this.relatedRequestId,
  });

  factory NotificationModel.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    return NotificationModel(
      id: id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
      read: (data['read'] as bool?) ?? false,
      relatedCollection: data['relatedCollection'] as String?,
      relatedRequestId: data['relatedRequestId'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, read];
}
