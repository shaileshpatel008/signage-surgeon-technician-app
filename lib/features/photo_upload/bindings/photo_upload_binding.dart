import 'package:get/get.dart';
import '../controllers/photo_upload_controller.dart';

class PhotoUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PhotoUploadController());
  }
}
