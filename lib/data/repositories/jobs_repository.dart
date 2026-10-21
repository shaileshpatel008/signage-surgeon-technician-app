import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/network/api_response.dart';
import '../../core/services/logger_service.dart';
import '../datasources/firestore_jobs_datasource.dart';
import '../models/job_model.dart';

class JobsRepository {
  final FirestoreJobsDataSource _dataSource;
  final FirebaseStorage _storage;

  JobsRepository({required FirestoreJobsDataSource dataSource, FirebaseStorage? storage})
      : _dataSource = dataSource,
        _storage = storage ?? FirebaseStorage.instance;

  Future<ApiResult<List<JobModel>>> fetchAssignedJobs(String technicianUid) async {
    try {
      final jobs = await _dataSource.fetchAssignedJobs(technicianUid);
      return ApiResult.success(jobs);
    } catch (e, st) {
      logger.error('fetchAssignedJobs failed', e, st);
      return const ApiResult.failure("Couldn't load your jobs. Pull down to try again.");
    }
  }

  /// OTP-confirmed stage advance — arrival moves a job to its
  /// `inProgressStage`, completion moves it to its `doneStage`.
  Future<ApiResult<void>> advanceStage(JobModel job, String targetStage) async {
    try {
      await _dataSource.advanceStage(collection: job.collection, requestId: job.id, targetStage: targetStage);
      return const ApiResult.success(null);
    } catch (e, st) {
      logger.error('advanceStage failed', e, st);
      return const ApiResult.failure('Something went wrong saving this. Please try again.');
    }
  }

  /// Completion-with-photos: uploads each file to Firebase Storage at
  /// `completion_photos/{serviceCollection}/{requestId}/{timestamp}_{index}.jpg`
  /// (the exact path the backend contract specifies), then writes
  /// `completionPhotos` and `trackingStage` onto the request doc in one
  /// update. Fails fast — if any upload throws, nothing is written to
  /// Firestore, so a job is never marked completed with partial/missing
  /// photos. [onProgress] reports 1-based (uploaded, total) after each
  /// file finishes, for a simple "Uploading photo 2 of 4" indicator.
  Future<ApiResult<void>> completeJobWithPhotos({
    required JobModel job,
    required String targetStage,
    required List<File> photoFiles,
    required String technicianUid,
    void Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      final completionPhotos = <Map<String, dynamic>>[];
      for (var i = 0; i < photoFiles.length; i++) {
        final storagePath =
            'completion_photos/${job.collection}/${job.id}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = _storage.ref(storagePath);
        await ref.putFile(photoFiles[i]);
        final url = await ref.getDownloadURL();
        completionPhotos.add({
          'url': url,
          'storagePath': storagePath,
          'uploadedBy': technicianUid,
          // FieldValue.serverTimestamp() isn't allowed inside an
          // arrayUnion element, so this is a client timestamp.
          'uploadedAt': Timestamp.now(),
        });
        onProgress?.call(i + 1, photoFiles.length);
      }

      await _dataSource.completeWithPhotos(
        collection: job.collection,
        requestId: job.id,
        targetStage: targetStage,
        completionPhotos: completionPhotos,
      );
      return const ApiResult.success(null);
    } catch (e, st) {
      logger.error('completeJobWithPhotos failed', e, st);
      return const ApiResult.failure("Couldn't upload photos. Please try again.");
    }
  }

  /// Proposed addition: uploads a work-proof photo to Firebase Storage and
  /// links it onto the request doc's `technicianPhotoUrls` field.
  Future<ApiResult<String>> uploadWorkPhoto({required JobModel job, required File file}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final ref = _storage.ref('technician_uploads/${job.collection}/${job.id}/$fileName');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      await _dataSource.addTechnicianPhoto(collection: job.collection, requestId: job.id, url: url);
      return ApiResult.success(url);
    } catch (e, st) {
      logger.error('uploadWorkPhoto failed', e, st);
      return const ApiResult.failure("Couldn't upload this photo. Please try again.");
    }
  }
}
