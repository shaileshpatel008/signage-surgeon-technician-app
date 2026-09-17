import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/storage_constants.dart';
import '../core/storage/local_storage.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class SignageSurgeonTechnicianApp extends StatelessWidget {
  const SignageSurgeonTechnicianApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = LocalStorage.instance.getBool(StorageKeys.themeMode, defaultValue: false);

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
