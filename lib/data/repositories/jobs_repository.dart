import 'dart:io';
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
