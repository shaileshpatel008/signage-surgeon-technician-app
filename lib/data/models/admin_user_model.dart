import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Mirrors `admins/{uid}` documents exactly as written by
/// `POST /api/admin/create-admin` on web (see `technicians/page.tsx`) and
/// read by `AdminAuthContext.tsx`. This app only ever signs in users whose
/// `role` is `"labour"` — see [AuthRepository].
class AdminUserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? parentVendorUid;
  final DateTime? createdAt;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.parentVendorUid,
    this.createdAt,
  });

  bool get isTechnician => role == 'labour';

  factory AdminUserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    return AdminUserModel(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      role: (data['role'] as String?) ?? '',
      phone: data['phone'] as String?,
      parentVendorUid: data['parentVendorUid'] as String?,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, name, role, phone, parentVendorUid, createdAt];
}
