import 'package:get/get.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/jobs_repository.dart';
import '../../dashboard/controllers/dashboard_controller.dart' show LoadStatus;

/// Proposed addition. Job-count stats below are computed live from the
/// technician's own assigned documents — genuinely real, unlike a rating
/// average: `ratings` documents on web carry no technician reference
/// (`requestId` + `stars` only, checked against `admin/ratings/page.tsx`),
/// so there is no way to compute "my rating" from current data. That stat
/// stays a clearly-labeled placeholder until the web schema adds it.
class ReportsController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final JobsRepository _jobsRepository = Get.find();

  final Rx<LoadStatus> status = LoadStatus.loading.obs;
  final RxList<JobModel> _jobs = <JobModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    status.value = LoadStatus.loading;
    final admin = await _authRepository.restoreSession();
    if (admin == null) {
      status.value = LoadStatus.error;
      return;
    }

    final result = await _jobsRepository.fetchAssignedJobs(admin.uid);
    result.when(
      success: (jobs) {
        _jobs.assignAll(jobs);
        status.value = LoadStatus.loaded;
      },
      failure: (_) => status.value = LoadStatus.error,
    );
  }

  Future<void> refresh() => _load();

  int get totalAssigned => _jobs.length;
  int get completedCount => _jobs.where((j) => j.isDone).length;
  int get inProgressCount => _jobs.where((j) => !j.isDone && j.stage != null && j.stage != 'submitted' && j.stage != 'tech_assigned').length;
  int get upcomingCount => totalAssigned - completedCount - inProgressCount;

  /// service label -> count, in the same order as `ServiceTypes.all`.
  Map<String, int> get byService {
    final counts = <String, int>{};
    for (final job in _jobs) {
      counts[job.serviceLabel] = (counts[job.serviceLabel] ?? 0) + 1;
    }
    return counts;
  }

  int get maxServiceCount => byService.values.isEmpty ? 1 : byService.values.reduce((a, b) => a > b ? a : b);
}
