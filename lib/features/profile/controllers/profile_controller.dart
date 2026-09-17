import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/admin_user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';

/// Proposed addition — see `ProfileRepository` for what's genuinely new
/// here vs. the web schema.
class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final ProfileRepository _profileRepository = Get.find();

  final Rxn<AdminUserModel> admin = Rxn<AdminUserModel>();
  final RxBool loading = true.obs;

  // Edit profile form state
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final RxBool saving = false.obs;

  // Change password form state
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final RxBool changingPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    loading.value = true;
    final restored = await _authRepository.restoreSession();
    admin.value = restored;
    if (restored != null) {
      nameController.text = restored.name;
      phoneController.text = restored.phone ?? '';
    }
    loading.value = false;
  }

  Future<void> saveProfile() async {
    final current = admin.value;
    if (current == null) return;
    final nameError = ValidationUtils.required(nameController.text, field: 'Name');
    if (nameError != null) {
      AppDialog.error(nameError);
      return;
    }

    saving.value = true;
    final result = await _profileRepository.updateProfile(
      uid: current.uid,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
    );
    saving.value = false;

    result.when(
      success: (_) {
        admin.value = AdminUserModel(
          uid: current.uid,
          email: current.email,
          name: nameController.text.trim(),
          role: current.role,
          phone: phoneController.text.trim(),
          parentVendorUid: current.parentVendorUid,
          createdAt: current.createdAt,
        );
        AppDialog.success('Profile updated.');
        Get.back();
      },
      failure: AppDialog.error,
    );
  }

  Future<void> changePassword() async {
    final current = admin.value;
    if (current == null) return;

    final currentError = ValidationUtils.required(currentPasswordController.text, field: 'Current password');
    final newError = ValidationUtils.password(newPasswordController.text);
    if (currentError != null) {
      AppDialog.error(currentError);
      return;
    }
    if (newError != null) {
      AppDialog.error(newError);
      return;
    }

    changingPassword.value = true;
    final result = await _profileRepository.changePassword(
      email: current.email,
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
    );
    changingPassword.value = false;

    result.when(
      success: (_) {
        currentPasswordController.clear();
        newPasswordController.clear();
        AppDialog.success('Password changed.');
        Get.back();
      },
      failure: AppDialog.error,
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
