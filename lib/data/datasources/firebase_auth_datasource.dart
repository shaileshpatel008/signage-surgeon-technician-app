import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/network_exception.dart';
import '../../core/services/logger_service.dart';
import '../models/admin_user_model.dart';

/// Wraps Firebase Auth + the `admins` collection exactly the way
/// `admin/login/page.tsx` does on web:
///
/// 1. `signInWithEmailAndPassword` to verify the password.
/// 2. Look up `admins/{uid}` — reject if missing, or if `role` isn't one
///    this app accepts (technicians only: `"labour"`).
/// 3. Sign back out (web does this too) and send a login OTP.
/// 4. On OTP confirm, sign back in for real.
class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseAuthDataSource({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  /// Step 1-2: validates the password and role, but does NOT leave the
  /// user signed in (matches web) — the caller still has to complete OTP.
  Future<AdminUserModel> validateCredentials({required String email, required String password}) async {
    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      logger.warning('signIn failed', e.code);
      throw const AuthException('Incorrect email or password.');
    }

    final uid = credential.user!.uid;
    try {
      final snap = await _db.collection(AppConstants.adminsCollection).doc(uid).get();
      if (!snap.exists) {
        await _auth.signOut();
        throw const AuthException('No technician account exists for this login.');
      }

      final admin = AdminUserModel.fromFirestore(uid, snap.data()!);
      if (admin.role != AppConstants.roleLabour) {
        await _auth.signOut();
        throw const AuthException(
          'This app is for technicians only. Ask your Vendor Admin for the web admin panel link instead.',
        );
      }

      // Matches web: sign out again immediately, OTP re-establishes the
      // session once confirmed.
      await _auth.signOut();
      return admin;
    } on AuthException {
      rethrow;
    } catch (e) {
      await _auth.signOut();
      throw const AuthException("Couldn't verify your account. Please try again.");
    }
  }

  /// Step 4: re-authenticates for real after a valid OTP.
  Future<AdminUserModel> completeSignIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;
    final snap = await _db.collection(AppConstants.adminsCollection).doc(uid).get();
    if (!snap.exists) {
      await _auth.signOut();
      throw const AuthException('No technician account exists for this login.');
    }
    return AdminUserModel.fromFirestore(uid, snap.data()!);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Used by the splash screen to silently restore a session — mirrors
  /// `AdminAuthContext`'s `onAuthStateChanged` handler, but this app also
  /// re-checks `role === "labour"` since a stray non-technician session
  /// should never be treated as signed in here.
  Future<AdminUserModel?> getCurrentAdminProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snap = await _db.collection(AppConstants.adminsCollection).doc(user.uid).get();
    if (!snap.exists) return null;

    final admin = AdminUserModel.fromFirestore(user.uid, snap.data()!);
    if (!admin.isTechnician) return null;
    return admin;
  }
}
