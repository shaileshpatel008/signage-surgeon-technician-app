/// Route name constants. Kept separate from [AppPages] so features can
/// reference a route by name without importing the page-binding wiring.
abstract class Routes {
  Routes._();

  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';

  // Proposed additions — not part of the current web app, built for the
  // client-approved "full app" mockup. See each feature's README note.
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const notifications = '/notifications';
  static const photoUpload = '/photo-upload';
  static const quotation = '/quotation';
  static const reports = '/reports';
  static const settings = '/settings';
  static const bluetoothDiagnostics = '/bluetooth-diagnostics';
}
