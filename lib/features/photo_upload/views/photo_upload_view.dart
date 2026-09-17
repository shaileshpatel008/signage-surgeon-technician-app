import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/photo_upload_controller.dart';

class PhotoUploadView extends GetView<PhotoUploadController> {
  const PhotoUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(title: const Text('Work Photos')),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${controller.job.title} · ${controller.job.serviceLabel}', style: AppTextStyles.bodySmall),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UPLOADED PHOTOS', style: AppTextStyles.caption),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      if (controller.uploadedUrls.isEmpty) {
                        return Center(
                          child: Text('No work photos uploaded yet.', style: AppTextStyles.bodySmall),
                        );
                      }
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: controller.uploadedUrls.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            child: CachedNetworkImage(
                              imageUrl: controller.uploadedUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, _) => const ColoredBox(color: AppColors.borderLight),
                              errorWidget: (context, _, __) => const ColoredBox(
                                color: AppColors.borderLight,
                                child: Icon(Icons.broken_image_outlined, color: AppColors.mutedText),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _ActionTile(
                            icon: Icons.camera_alt_outlined,
                            label: 'Take Photo',
                            loading: controller.uploading.value,
                            onTap: () => controller.pickAndUpload(ImageSource.camera),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _ActionTile(
                            icon: Icons.photo_library_outlined,
                            label: 'Choose From Gallery',
                            loading: controller.uploading.value,
                            onTap: () => controller.pickAndUpload(ImageSource.gallery),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            if (loading)
              const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandRed))
            else
              Icon(icon, color: AppColors.brandRed),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
