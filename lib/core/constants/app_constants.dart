/// App-wide constants mirroring the web admin app's Firestore schema.
/// Keep these in lockstep with `src/app/admin/labour/page.tsx` and
/// `src/app/admin/technicians/page.tsx` in the web repo — this app reads
/// and writes the exact same collections and fields.
abstract class AppConstants {
  AppConstants._();

  static const String appName = 'The Signage Surgeon — Technician';

  /// Client approved seeing these labeled in the reviewed mockup. Flip to
  /// `false` once a screen's backend is actually wired up end-to-end
  /// (e.g. once something populates `technician_notifications`) or once
  /// the client no longer needs the distinction called out in the UI.
  static const bool showProposedAdditionBanners = true;

  // Firestore collections
  static const String adminsCollection = 'admins';
  static const String repairRequests = 'repair_requests';
  static const String rebrandingRequests = 'rebranding_requests';
  static const String newSignageRequests = 'new_signage_requests';
  static const String cleaningRequests = 'cleaning_requests';

  // Admin roles (admins/{uid}.role) — a technician is always "labour"
  static const String roleSuperAdmin = 'super_admin';
  static const String roleVendorAdmin = 'vendor_admin';
  static const String roleBackendStaff = 'backend_staff';
  static const String roleLabour = 'labour';

  // OTP purposes, as sent to /api/admin/send-otp and verify-otp
  static const String otpPurposeLogin = 'login';
  static const String otpPurposeSignup = 'signup';

  // trackingStage values (repair/rebranding/new_signage — two-visit flow)
  static const String stageSubmitted = 'submitted';
  static const String stageTechAssigned = 'tech_assigned';
  static const String stageTechEnRoute = 'tech_en_route';
  static const String stageWorkInProgress = 'work_in_progress';
  static const String stageSiteVisitCompleted = 'site_visit_completed';
  static const String stageQuotationSent = 'quotation_sent';
  static const String stageQuotationApproved = 'quotation_approved';
  static const String stageQuotationRejected = 'quotation_rejected';
  static const String stageQuotationPaid = 'quotation_paid';
  static const String stageTechAssigned2 = 'tech_assigned_2';
  static const String stageTechEnRoute2 = 'tech_en_route_2';
  static const String stageWorkInProgress2 = 'work_in_progress_2';
  static const String stageCompleted = 'completed';
  static const String stageCancelledByCustomer = 'cancelled_by_customer';
}
