import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/date_utils.dart';

/// One service type's Firestore shape, mirroring the `SERVICES` config in
/// `labour/page.tsx` exactly — collection name, display label, and
/// whether it has a second ("repair"/work) visit after the site visit.
class ServiceTypeConfig {
  final String collection;
  final String label;
  final bool hasSecondVisit;

  const ServiceTypeConfig({required this.collection, required this.label, required this.hasSecondVisit});
}

abstract class ServiceTypes {
  ServiceTypes._();

  static const repairing = ServiceTypeConfig(collection: 'repair_requests', label: 'Repairing', hasSecondVisit: true);
  static const rebranding = ServiceTypeConfig(collection: 'rebranding_requests', label: 'Rebranding', hasSecondVisit: true);
  static const newSignage =
      ServiceTypeConfig(collection: 'new_signage_requests', label: 'New Signage', hasSecondVisit: true);
  static const cleaning = ServiceTypeConfig(collection: 'cleaning_requests', label: 'Signage Cleaning', hasSecondVisit: false);

  /// Exactly the 4 collections a technician has any assignment in today —
  /// matches `SERVICES` in `labour/page.tsx`. AMC, Sign Shoppy and Support
  /// Tickets never assign a `labour`, so they are intentionally absent.
  static const all = [repairing, rebranding, newSignage, cleaning];
}

/// One assigned visit for the signed-in technician — mirrors the `WorkItem`
/// type in `labour/page.tsx` field-for-field. A single Firestore request
/// document can produce up to two [JobModel]s (site visit + repair visit)
/// for the two-visit services, exactly as the web page does.
class JobModel extends Equatable {
  final String id;
  final String collection;
  final String serviceLabel;
  final String? signageType;
  final String? stage;
  final String? address;
  final double? lat;
  final double? lng;

  /// Photos the *customer* attached to the request — read-only here,
  /// exactly like web (a plain list of URLs, never editable by a technician).
  final List<String> photoUrls;

  final DateTime? visitDate;
  final String? visitTimeStart;
  final String? visitTimeEnd;
  final String visitLabel;

  final String? arrivalOtp;
  final String? completionOtp;

  final String enRouteStage;
  final String inProgressStage;
  final String doneStage;

  /// Which assignment field this job came from (`assignedLabourUid` for
  /// the site visit, `assignedLabourUid2` for the repair visit) — needed
  /// so [JobsRepository.advanceStage] writes the right doc's `trackingStage`.
  final String assignmentField;

  /// finalQuotation map, when present — surfaced read-only on the
  /// **proposed** Quotation screen; technicians have no write access to it.
  final Map<String, dynamic>? finalQuotation;

  /// Proposed addition: work-proof photo URLs the technician has uploaded
  /// via the (new) Photo Upload screen. Not part of the current web schema.
  final List<String> technicianPhotoUrls;

  const JobModel({
    required this.id,
    required this.collection,
    required this.serviceLabel,
    required this.visitLabel,
    required this.enRouteStage,
    required this.inProgressStage,
    required this.doneStage,
    required this.assignmentField,
    this.signageType,
    this.stage,
    this.address,
    this.lat,
    this.lng,
    this.photoUrls = const [],
    this.visitDate,
    this.visitTimeStart,
    this.visitTimeEnd,
    this.arrivalOtp,
    this.completionOtp,
    this.finalQuotation,
    this.technicianPhotoUrls = const [],
  });

  bool get isDone => stage == doneStage;
  bool get canMarkArrived => stage == enRouteStage;
  bool get canMarkCompleted => stage == inProgressStage;
  bool get isToday => AppDateUtils.isToday(visitDate);

  String get title => (signageType == null || signageType!.isEmpty) ? 'Signage Job' : signageType!;

  /// Mirrors the `snap1.docs.forEach` body in `labour/page.tsx` exactly:
  /// called once per doc returned by the `assignedLabourUid` query,
  /// unconditionally builds the Site Visit job — it never looks at
  /// `assignedLabourUid2`. Web doesn't check that field here either; the
  /// two visit types are independent per-query results, not two facets
  /// of one doc to be cross-checked. (A previous version of this method
  /// checked both fields on every call, which meant a request the
  /// technician is assigned to for BOTH visits — a normal case — got its
  /// repair-visit job built twice: once here, once from
  /// [fromRepairVisitDoc], because both queries return that same doc.
  /// That's the duplicate-listing bug: web shows 2 records for such a
  /// job, the app was showing 3.)
  factory JobModel.fromSiteVisitDoc({
    required String id,
    required Map<String, dynamic> data,
    required ServiceTypeConfig service,
  }) {
    final isCleaningSingleVisit = !service.hasSecondVisit;
    final location = data['location'] as Map<String, dynamic>?;

    return JobModel(
      id: id,
      collection: service.collection,
      serviceLabel: service.label,
      signageType: data['signageType'] as String?,
      stage: (data['trackingStage'] as String?) ?? (data['cleaningPhase'] as String?),
      address: location?['address'] as String?,
      lat: (location?['lat'] as num?)?.toDouble(),
      lng: (location?['lng'] as num?)?.toDouble(),
      photoUrls: (data['photoUrls'] as List?)?.whereType<String>().toList() ?? const <String>[],
      visitDate: AppDateUtils.fromTimestamp(data['visitDate']),
      visitTimeStart: data['visitTimeStart'] as String?,
      visitTimeEnd: data['visitTimeEnd'] as String?,
      visitLabel: service.hasSecondVisit ? 'Site Visit' : 'Visit',
      arrivalOtp: isCleaningSingleVisit ? data['startingOtp'] as String? : data['siteVisitArrivalOtp'] as String?,
      completionOtp:
          isCleaningSingleVisit ? data['completionOtp'] as String? : data['siteVisitCompletionOtp'] as String?,
      enRouteStage: 'tech_en_route',
      inProgressStage: 'work_in_progress',
      doneStage: isCleaningSingleVisit ? 'completed' : 'site_visit_completed',
      assignmentField: 'assignedLabourUid',
      finalQuotation: data['finalQuotation'] as Map<String, dynamic>?,
      technicianPhotoUrls: (data['technicianPhotoUrls'] as List?)?.whereType<String>().toList() ?? const <String>[],
    );
  }

  /// Mirrors the `snap2.docs.forEach` body in `labour/page.tsx`: called
  /// once per doc returned by the `assignedLabourUid2` query, unconditionally
  /// builds the Repair Visit job. Only ever called for `hasSecondVisit`
  /// services — see [fromSiteVisitDoc]'s doc comment for why this doesn't
  /// check `assignedLabourUid`.
  factory JobModel.fromRepairVisitDoc({
    required String id,
    required Map<String, dynamic> data,
    required ServiceTypeConfig service,
  }) {
    final location = data['location'] as Map<String, dynamic>?;

    return JobModel(
      id: id,
      collection: service.collection,
      serviceLabel: service.label,
      signageType: data['signageType'] as String?,
      stage: data['trackingStage'] as String?,
      address: location?['address'] as String?,
      lat: (location?['lat'] as num?)?.toDouble(),
      lng: (location?['lng'] as num?)?.toDouble(),
      photoUrls: (data['photoUrls'] as List?)?.whereType<String>().toList() ?? const <String>[],
      visitDate: AppDateUtils.fromTimestamp(data['visitDate2']),
      visitTimeStart: data['visitTimeStart2'] as String?,
      visitTimeEnd: data['visitTimeEnd2'] as String?,
      visitLabel: 'Repair Visit',
      arrivalOtp: data['workArrivalOtp'] as String?,
      completionOtp: data['workCompletionOtp'] as String?,
      enRouteStage: 'tech_en_route_2',
      inProgressStage: 'work_in_progress_2',
      doneStage: 'completed',
      assignmentField: 'assignedLabourUid2',
      finalQuotation: data['finalQuotation'] as Map<String, dynamic>?,
      technicianPhotoUrls: (data['technicianPhotoUrls'] as List?)?.whereType<String>().toList() ?? const <String>[],
    );
  }

  JobModel copyWith({String? stage}) {
    return JobModel(
      id: id,
      collection: collection,
      serviceLabel: serviceLabel,
      signageType: signageType,
      stage: stage ?? this.stage,
      address: address,
      lat: lat,
      lng: lng,
      photoUrls: photoUrls,
      visitDate: visitDate,
      visitTimeStart: visitTimeStart,
      visitTimeEnd: visitTimeEnd,
      visitLabel: visitLabel,
      arrivalOtp: arrivalOtp,
      completionOtp: completionOtp,
      enRouteStage: enRouteStage,
      inProgressStage: inProgressStage,
      doneStage: doneStage,
      assignmentField: assignmentField,
      finalQuotation: finalQuotation,
      technicianPhotoUrls: technicianPhotoUrls,
    );
  }

  @override
  List<Object?> get props => [id, collection, assignmentField, stage];
}
