import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_response.dart';
import '../../core/network/network_exception.dart';
import '../../core/services/logger_service.dart';
import '../models/admin_user_model.dart';

/// Proposed addition: profile viewing/editing and password change. The web
/// app has no self-service profile screen for technicians at all today —
/// their `admins/{uid}` doc is only ever written by a Vendor Admin via
/// `POST /api/admin/create-admin`. This repository lets a technician
/// update their own `name`/`phone` and password directly, which is new
/// write access beyond what the web schema currently grants them.
class ProfileRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProfileRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<ApiResult<AdminUserModel>> fetchProfile(String uid) async {
    try {
      final snap = await _db.collection(AppConstants.adminsCollection).doc(uid).get();
      if (!snap.exists) return const ApiResult.failure('Profile not found.');
      return ApiResult.success(AdminUserModel.fromFirestore(uid, snap.data()!));
    } catch (e, st) {
      logger.error('fetchProfile failed', e, st);
      return const ApiResult.failure("Couldn't load your profile.");
    }
  }

  Future<ApiResult<void>> updateProfile({required String uid, required String name, required String phone}) async {
    try {
      await _db.collection(AppConstants.adminsCollection).doc(uid).update({'name': name, 'phone': phone});
      return const ApiResult.success(null);
    } catch (e, st) {
      logger.error('updateProfile failed', e, st);
      return const ApiResult.failure("Couldn't save your changes.");
    }
  }

  Future<ApiResult<void>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const ApiResult.failure('Your session has expired. Please sign in again.');

      final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return const ApiResult.success(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return const ApiResult.failure('Your current password is incorrect.');
      }
      return ApiResult.failure(e.message ?? "Couldn't change your password.");
    } catch (e, st) {
      logger.error('changePassword failed', e, st);
      return const ApiResult.failure("Couldn't change your password.");
    }
  }
}
