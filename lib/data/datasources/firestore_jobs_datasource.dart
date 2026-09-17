import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

/// Firestore reads/writes for a technician's assigned jobs — a literal
/// port of the `load()` function in `labour/page.tsx`: for each of the 4
/// service collections, one query on `assignedLabourUid`, and (for
/// services with a repair visit) a second query on `assignedLabourUid2`.
/// Web uses one-shot `getDocs`, not a live listener, so this does too —
/// the dashboard controller re-fetches on pull-to-refresh and after a
/// stage change instead of subscribing.
class FirestoreJobsDataSource {
  final FirebaseFirestore _db;
  FirestoreJobsDataSource({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<List<JobModel>> fetchAssignedJobs(String technicianUid) async {
    final results = <JobModel>[];

    for (final service in ServiceTypes.all) {
      final collectionRef = _db.collection(service.collection);

      final snap1 = await collectionRef.where('assignedLabourUid', isEqualTo: technicianUid).get();
      for (final doc in snap1.docs) {
        results.addAll(
          JobModel.fromRequestDoc(id: doc.id, data: doc.data(), service: service, technicianUid: technicianUid),
        );
      }

      if (service.hasSecondVisit) {
        final snap2 = await collectionRef.where('assignedLabourUid2', isEqualTo: technicianUid).get();
        for (final doc in snap2.docs) {
          // fromRequestDoc already checks both fields against the doc data,
          // so a doc where the technician is BOTH assignedLabourUid and
          // assignedLabourUid2 (rare, but web doesn't forbid it) correctly
          // yields two distinct JobModels without double-adding from snap1.
          final jobs = JobModel.fromRequestDoc(id: doc.id, data: doc.data(), service: service, technicianUid: technicianUid);
          for (final job in jobs) {
            if (job.assignmentField == 'assignedLabourUid2') results.add(job);
          }
        }
      }
    }

    return results;
  }

  /// Matches `handleAdvanceStage` in `labour/page.tsx` exactly: always
  /// writes `trackingStage`, regardless of which assignment field or
  /// service the job came from.
  Future<void> advanceStage({required String collection, required String requestId, required String targetStage}) {
    return _db.collection(collection).doc(requestId).update({'trackingStage': targetStage});
  }

  /// Proposed addition: appends a technician-uploaded work-proof photo URL.
  /// `technicianPhotoUrls` is a new field this app introduces — it does
  /// not exist in the current web schema.
  Future<void> addTechnicianPhoto({required String collection, required String requestId, required String url}) {
    return _db.collection(collection).doc(requestId).set(
      {
        'technicianPhotoUrls': FieldValue.arrayUnion([url]),
      },
      SetOptions(merge: true),
    );
  }
}
