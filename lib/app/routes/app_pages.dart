import 'package:get/get.dart';
import '../../features/bluetooth/bindings/bluetooth_binding.dart';
import '../../features/bluetooth/views/bluetooth_view.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/login/views/login_view.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/photo_upload/bindings/photo_upload_binding.dart';
import '../../features/photo_upload/views/photo_upload_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/edit_profile_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/quotation/bindings/quotation_binding.dart';
import '../../features/quotation/views/quotation_view.dart';
import '../../features/reports/bindings/reports_binding.dart';
import '../../features/reports/views/reports_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import 'app_routes.dart';

/// Centralized route table. Every screen's binding is scoped to its own
/// page (`Bindings`, not `InitialBinding`) so a controller's dependencies
/// are created on navigation and torn down on pop — `InitialBinding` only
/// carries the app-wide singletons (storage, network, repositories).
class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(name: Routes.dashboard, page: () => const DashboardView(), binding: DashboardBinding()),

    // Proposed additions
    GetPage(name: Routes.profile, page: () => const ProfileView(), binding: ProfileBinding()),
    GetPage(name: Routes.editProfile, page: () => const EditProfileView(), binding: ProfileBinding()),
    GetPage(name: Routes.notifications, page: () => const NotificationsView(), binding: NotificationsBinding()),
    GetPage(name: Routes.photoUpload, page: () => const PhotoUploadView(), binding: PhotoUploadBinding()),
    GetPage(name: Routes.quotation, page: () => const QuotationView(), binding: QuotationBinding()),
    GetPage(name: Routes.reports, page: () => const ReportsView(), binding: ReportsBinding()),
    GetPage(name: Routes.settings, page: () => const SettingsView(), binding: SettingsBinding()),
    GetPage(name: Routes.bluetoothDiagnostics, page: () => const BluetoothView(), binding: BluetoothBinding()),
  ];
}
