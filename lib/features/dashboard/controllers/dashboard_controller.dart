import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/admin_user_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/jobs_repository.dart';

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
  }

  void cancelOtp() {
    openOtpKey.value = null;
    otpMode.value = null;
    otpError.value = null;
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

    confirmingOtp.value = true;
    final targetStage = mode == OtpMode.arrival ? job.inProgressStage : job.doneStage;
    final result = await _jobsRepository.advanceStage(job, targetStage);
    confirmingOtp.value = false;

    result.when(
      success: (_) {
        final index = jobs.indexWhere((j) => _keyFor(j) == _keyFor(job));
        if (index != -1) jobs[index] = job.copyWith(stage: targetStage);
        cancelOtp();
      },
      failure: (message) => otpError.value = message,
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
