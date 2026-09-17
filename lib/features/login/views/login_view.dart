import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(colors: [AppColors.brandYellow, AppColors.brandRed]),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Obx(
                  () => controller.step.value == LoginStep.credentials
                      ? _CredentialsStep(controller: controller)
                      : _OtpStep(controller: controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialsStep extends StatelessWidget {
  final LoginController controller;
  const _CredentialsStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Technician Login', style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Text(
          "Sign in with the email and password your Vendor Admin set up for you.",
          style: AppTextStyles.body.copyWith(color: AppColors.brandGray),
        ),
        const SizedBox(height: 26),
        Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Email',
                controller: controller.emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Obx(
                () => AppTextField(
                  label: 'Password',
                  controller: controller.passwordController,
                  hint: '••••••••',
                  obscureText: controller.obscurePassword.value,
                  suffixIcon: IconButton(
                    onPressed: controller.toggleObscure,
                    icon: Icon(
                      controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 19,
                      color: AppColors.brandNavy.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppColors.brandRed, padding: EdgeInsets.zero),
                  child: Text('Forgot password?', style: AppTextStyles.link),
                ),
              ),
              const SizedBox(height: 6),
              Obx(() {
                final error = controller.errorMessage.value;
                return error == null
                    ? const SizedBox.shrink()
                    : Padding(padding: const EdgeInsets.only(bottom: 14), child: AppInlineError(message: error));
              }),
              Obx(
                () => AppButton(
                  label: 'Sign In',
                  isLoading: controller.submitting.value,
                  onPressed: controller.submitCredentials,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.brandYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'New here? Only your Vendor Admin can create a technician account for you from the web dashboard.',
                        style: AppTextStyles.body.copyWith(fontSize: 11.5, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  final LoginController controller;
  const _OtpStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: controller.backToCredentials,
          style: TextButton.styleFrom(foregroundColor: AppColors.brandNavy, padding: EdgeInsets.zero),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
          label: Text('Back', style: AppTextStyles.bodyMedium),
        ),
        const SizedBox(height: 12),
        Text('Enter Verification Code', style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Obx(
          () => Text.rich(
            TextSpan(
              style: AppTextStyles.body.copyWith(color: AppColors.brandGray),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to '),
                TextSpan(
                  text: controller.emailController.text.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandNavy),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(letterSpacing: 8),
          decoration: const InputDecoration(counterText: '', hintText: '000000'),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final error = controller.errorMessage.value;
          return error == null
              ? const SizedBox.shrink()
              : Padding(padding: const EdgeInsets.only(bottom: 14), child: AppInlineError(message: error));
        }),
        Obx(
          () => AppButton(
            label: 'Verify & Sign In',
            isLoading: controller.submitting.value,
            onPressed: controller.verifyOtp,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Obx(
            () => TextButton(
              onPressed: controller.resending.value ? null : controller.resendOtp,
              child: Text(
                controller.resending.value ? 'Resending…' : 'Resend Code',
                style: AppTextStyles.link,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
