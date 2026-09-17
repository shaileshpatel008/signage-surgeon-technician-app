import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/admin_user_model.dart';
import '../../../data/repositories/auth_repository.dart';

enum LoginStep { credentials, otp }

/// Drives the exact two-step flow `admin/login/page.tsx` implements:
/// password + role check first, then a 6-digit email OTP, matching the
/// same UX (and the same backend) for every admin role on web — this app
/// simply refuses to proceed past step 1 for anything but `role: "labour"`.
class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  final step = LoginStep.credentials.obs;
  final obscurePassword = true.obs;
  final submitting = false.obs;
  final resending = false.obs;
  final errorMessage = RxnString();

  AdminUserModel? _pendingAdmin;

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> submitCredentials() async {
    errorMessage.value = null;
    final emailError = ValidationUtils.email(emailController.text);
    final passwordError = ValidationUtils.password(passwordController.text);
    if (emailError != null) {
      errorMessage.value = emailError;
      return;
    }
    if (passwordError != null) {
      errorMessage.value = passwordError;
      return;
    }

    submitting.value = true;
    final result = await _authRepository.sendCredentialsAndOtp(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    submitting.value = false;

    result.when(
      success: (admin) {
        _pendingAdmin = admin;
        step.value = LoginStep.otp;
      },
      failure: (message) => errorMessage.value = message,
    );
  }

  Future<void> verifyOtp() async {
    errorMessage.value = null;
    final otpError = ValidationUtils.otp(otpController.text);
    if (otpError != null) {
      errorMessage.value = otpError;
      return;
    }

    submitting.value = true;
    final result = await _authRepository.verifyOtpAndSignIn(
      email: emailController.text.trim(),
      password: passwordController.text,
      otp: otpController.text.trim(),
    );
    submitting.value = false;

    result.when(
      success: (_) => Get.offAllNamed(Routes.dashboard),
      failure: (message) => errorMessage.value = message,
    );
  }

  Future<void> resendOtp() async {
    resending.value = true;
    try {
      await _authRepository.resendOtp(emailController.text.trim());
      AppDialog.info('A new code has been sent to your email.');
    } finally {
      resending.value = false;
    }
  }

  void backToCredentials() {
    step.value = LoginStep.credentials;
    otpController.clear();
    errorMessage.value = null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
