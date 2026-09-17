import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(label: 'Full Name', controller: controller.nameController),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Phone Number',
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      hint: '+91 XXXXX XXXXX',
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => AppButton(label: 'Save Changes', isLoading: controller.saving.value, onPressed: controller.saveProfile),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
