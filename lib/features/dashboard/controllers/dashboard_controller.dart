import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/admin_user_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/jobs_repository.dart';

/// Backend contract for the completion-photos step below.
const int kMinCompletionPhotos = 1;
const int kMaxCompletionPhotos = 6;

enum LoadStatus { loading, loaded, empty, error }

enum OtpMode { arrival, completion }

/// One-to-one with `LabourDashboard` in `labour/page.tsx`: loads every job
/// assigned to the signed-in technician across the 4 service collections,
/// groups into Today / Upcoming / Completed exactly like the web
/// `todayItems`/`upcomingItems`/`completedItems` filters, and advances a
/// job's `trackingStage` on a matching arrival/completion OTP.
class DashboardController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final JobsRepository _jobsRepository = Get.find();

  final Rxn<AdminUserModel> admin = Rxn<AdminUserModel>();
  final RxList<JobModel> jobs = <JobModel>[].obs;
  final Rx<LoadStatus> status = LoadStatus.loading.obs;
  final RxnString errorMessage = RxnString();

  /// Which job currently has its OTP entry sheet open, keyed by
  /// `collection|id|assignmentField` (a single request doc can yield 2 jobs).
  final RxnString openOtpKey = RxnString();
  final Rxn<OtpMode> otpMode = Rxn<OtpMode>();
  final TextEditingController otpTextController = TextEditingController();
  final RxBool confirmingOtp = false.obs;
  final RxnString otpError = RxnString();

  /// Completion-photos step (backend contract: required before a job can
  /// reach its FINAL "completed" stage — see [JobModel.requiresCompletionPhotos]).
  /// Only ever populated while a completion OTP sheet needing photos is open.
  final ImagePicker _picker = ImagePicker();
  final RxList<File> completionPhotos = <File>[].obs;
  final RxnString photosError = RxnString();
  final RxInt uploadProgressDone = 0.obs;
  final RxInt uploadProgressTotal = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    otpTextController.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    final restored = await _authRepository.restoreSession();
    admin.value = restored;
    if (restored == null) {
      Get.offAllNamed(Routes.login);
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final uid = admin.value?.uid;
    if (uid == null) return;

    status.value = LoadStatus.loading;
    final result = await _jobsRepository.fetchAssignedJobs(uid);
    result.when(
      success: (fetched) {
        jobs.assignAll(fetched);
        status.value = fetched.isEmpty ? LoadStatus.empty : LoadStatus.loaded;
      },
      failure: (message) {
        errorMessage.value = message;
        status.value = LoadStatus.error;
      },
    );
  }

  String _keyFor(JobModel job) => '${job.collection}|${job.id}|${job.assignmentField}';

  List<JobModel> get todayJobs =>
      jobs.where((j) => !j.isDone && j.visitDate != null && AppDateUtils.isToday(j.visitDate)).toList();

  List<JobModel> get upcomingJobs =>
      jobs.where((j) => !j.isDone && (j.visitDate == null || !AppDateUtils.isToday(j.visitDate))).toList();

  List<JobModel> get completedJobs => jobs.where((j) => j.isDone).toList();

  bool isOtpOpenFor(JobModel job) => openOtpKey.value == _keyFor(job);

  void openArrivalOtp(JobModel job) {
    openOtpKey.value = _keyFor(job);
    otpMode.value = OtpMode.arrival;
    otpTextController.clear();
    otpError.value = null;
  }

  void openCompletionOtp(JobModel job) {
    openOtpKey.value = _keyFor(job);
    otpMode.value = OtpMode.completion;
    otpTextController.clear();
    otpError.value = null;
    completionPhotos.clear();
    photosError.value = null;
  }

  void cancelOtp() {
    openOtpKey.value = null;
    otpMode.value = null;
    otpError.value = null;
    completionPhotos.clear();
    photosError.value = null;
    uploadProgressDone.value = 0;
    uploadProgressTotal.value = 0;
  }

  Future<void> addCompletionPhoto(ImageSource source) async {
    if (completionPhotos.length >= kMaxCompletionPhotos) {
      photosError.value = 'You can attach up to $kMaxCompletionPhotos photos.';
      return;
    }

    final hasPermission = source == ImageSource.camera
        ? await PermissionService.instance.requestCamera()
        : await PermissionService.instance.requestPhotos();
    if (!hasPermission) {
      photosError.value = 'Permission needed to ${source == ImageSource.camera ? 'take a photo' : 'access your photos'}.';
      return;
    }

    // maxWidth/maxHeight constrain the longer side to ~1600px (aspect
    // ratio preserved); imageQuality re-encodes as JPEG at ~80% — matches
    // the backend contract's compression target.
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (picked == null) return;

    completionPhotos.add(File(picked.path));
    photosError.value = null;
  }

  void removeCompletionPhoto(int index) {
    if (index < 0 || index >= completionPhotos.length) return;
    completionPhotos.removeAt(index);
  }

  /// Mirrors `confirmOtp()` in `labour/page.tsx`: validates the entered
  /// code against the job's `arrivalOtp`/`completionOtp` field client-side
  /// (same as web — there is no server-side OTP check for job visits,
  /// unlike the login OTP which is server-verified), then advances stage.
  Future<void> confirmOtp(JobModel job) async {
    final mode = otpMode.value;
    if (mode == null) return;

    final expected = mode == OtpMode.arrival ? job.arrivalOtp : job.completionOtp;
    if (expected == null || expected.isEmpty) {
      otpError.value = 'No OTP is set on this job yet — check with your office.';
      return;
    }

    final entered = otpTextController.text.trim();
    if (entered != expected) {
      otpError.value = "That code doesn't match. Ask the customer to confirm it again.";
      return;
    }

    final targetStage = mode == OtpMode.arrival ? job.inProgressStage : job.doneStage;
    final needsPhotos = mode == OtpMode.completion && job.requiresCompletionPhotos;

    if (needsPhotos && completionPhotos.length < kMinCompletionPhotos) {
      photosError.value = 'Add at least $kMinCompletionPhotos photo of the finished work before marking this job completed.';
      return;
    }

    confirmingOtp.value = true;
    photosError.value = null;
    uploadProgressDone.value = 0;
    uploadProgressTotal.value = needsPhotos ? completionPhotos.length : 0;

    final result = needsPhotos
        ? await _jobsRepository.completeJobWithPhotos(
            job: job,
            targetStage: targetStage,
            photoFiles: completionPhotos.toList(),
            technicianUid: admin.value?.uid ?? '',
            onProgress: (done, total) {
              uploadProgressDone.value = done;
              uploadProgressTotal.value = total;
            },
          )
        : await _jobsRepository.advanceStage(job, targetStage);
    confirmingOtp.value = false;

    result.when(
      success: (_) {
        final index = jobs.indexWhere((j) => _keyFor(j) == _keyFor(job));
        if (index != -1) jobs[index] = job.copyWith(stage: targetStage);
        cancelOtp();
      },
      // On failure the selected photos stay in [completionPhotos], so
      // tapping Confirm again (the only retry affordance) re-runs the
      // same upload instead of making the technician re-pick everything.
      failure: (message) {
        if (needsPhotos) {
          photosError.value = message;
        } else {
          otpError.value = message;
        }
      },
    );
  }

  Future<void> signOut() async {
    final confirmed = await AppDialog.confirm(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
    );
    if (!confirmed) return;
    await _authRepository.signOut();
    Get.offAllNamed(Routes.login);
  }
}
