/// User-facing copy explaining *why* a permission is being requested,
/// shown in a rationale dialog before the OS prompt (better grant rates,
/// and required by Play Store policy for sensitive permissions).
class PermissionUtils {
  PermissionUtils._();

  static const String locationRationale =
      'The Signage Surgeon needs your location to give you accurate directions to a job site.';

  static const String cameraRationale = 'Camera access lets you capture before/after photos for a job.';

  static const String photosRationale = 'Photo library access lets you attach existing photos to a job.';

  static const String bluetoothRationale =
      'Bluetooth access lets the app scan for and connect to nearby signage controllers for diagnostics.';

  static const String notificationsRationale =
      'Enable notifications to be alerted the moment a new job is assigned to you.';
}
