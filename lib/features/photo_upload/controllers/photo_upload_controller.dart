import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/jobs_repository.dart';

/// Proposed addition — technicians have no photo upload capability on
/// web today (`photoUrls` is customer-only, read-only for a technician).
/// This writes to a NEW `technicianPhotoUrls` field. See
/// `JobsRepository.uploadWorkPhoto`.
class PhotoUploadController extends GetxController {
  final JobsRepository _jobsRepository = Get.find();
  final ImagePicker _picker = ImagePicker();

  late final JobModel job;
  final RxList<String> uploadedUrls = <String>[].obs;
  final RxBool uploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    job = Get.arguments as JobModel;
    uploadedUrls.assignAll(job.technicianPhotoUrls);
  }

  Future<void> pickAndUpload(ImageSource source) async {
    final hasPermission = source == ImageSource.camera
        ? await PermissionService.instance.requestCamera()
        : await PermissionService.instance.requestPhotos();

    if (!hasPermission) {
      AppDialog.error('Permission needed to ${source == ImageSource.camera ? 'take a photo' : 'access your photos'}.');
      return;
    }

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    uploading.value = true;
    final result = await _jobsRepository.uploadWorkPhoto(job: job, file: File(picked.path));
    uploading.value = false;

    result.when(
      success: (url) {
        uploadedUrls.add(url);
        AppDialog.success('Photo uploaded.');
      },
      failure: AppDialog.error,
    );
  }
}
