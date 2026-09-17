/// Keys used with [LocalStorage]. Centralized so a rename never has to be
/// hunted down across features.
abstract class StorageKeys {
  StorageKeys._();

  // Secure storage (flutter_secure_storage) — sensitive session data
  static const cachedEmail = 'cached_email';
  static const rememberMe = 'remember_me';

  // Shared preferences — non-sensitive UI/device prefs
  static const themeMode = 'theme_mode'; // system|light|dark
  static const onboardingSeen = 'onboarding_seen';
  static const lastSyncedAt = 'last_synced_at';
  static const notificationsEnabled = 'notifications_enabled';
}
