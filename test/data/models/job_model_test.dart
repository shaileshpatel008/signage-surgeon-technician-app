import 'package:flutter_test/flutter_test.dart';
import 'package:signage_surgeon_technician/data/models/job_model.dart';

void main() {
  const technicianUid = 'tech-123';

  group('JobModel.fromRequestDoc — two-visit service (repair/rebranding/new signage)', () {
    test('site-visit-only assignment yields exactly one job with the right stage keys', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-1',
        service: ServiceTypes.repairing,
        technicianUid: technicianUid,
        data: {
          'assignedLabourUid': technicianUid,
          'signageType': 'LED Signboard',
          'trackingStage': 'tech_en_route',
          'siteVisitArrivalOtp': '1234',
          'siteVisitCompletionOtp': '5678',
        },
      );

      expect(jobs, hasLength(1));
      final job = jobs.single;
      expect(job.visitLabel, 'Site Visit');
      expect(job.assignmentField, 'assignedLabourUid');
      expect(job.enRouteStage, 'tech_en_route');
      expect(job.inProgressStage, 'work_in_progress');
      expect(job.doneStage, 'site_visit_completed');
      expect(job.arrivalOtp, '1234');
      expect(job.completionOtp, '5678');
      expect(job.canMarkArrived, isTrue);
      expect(job.canMarkCompleted, isFalse);
    });

    test('repair-visit assignment (assignedLabourUid2) uses the "_2" stage keys and workArrivalOtp', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-2',
        service: ServiceTypes.repairing,
        technicianUid: technicianUid,
        data: {
          'assignedLabourUid2': technicianUid,
          'signageType': 'LED Signboard',
          'trackingStage': 'work_in_progress_2',
          'workArrivalOtp': '1111',
          'workCompletionOtp': '2222',
        },
      );

      expect(jobs, hasLength(1));
      final job = jobs.single;
      expect(job.visitLabel, 'Repair Visit');
      expect(job.assignmentField, 'assignedLabourUid2');
      expect(job.enRouteStage, 'tech_en_route_2');
      expect(job.inProgressStage, 'work_in_progress_2');
      expect(job.doneStage, 'completed');
      expect(job.arrivalOtp, '1111');
      expect(job.completionOtp, '2222');
      expect(job.canMarkCompleted, isTrue);
      expect(job.isDone, isFalse);
    });

    test('a technician on BOTH visits of the same request yields two distinct jobs', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-3',
        service: ServiceTypes.rebranding,
        technicianUid: technicianUid,
        data: {
          'assignedLabourUid': technicianUid,
          'assignedLabourUid2': technicianUid,
          'trackingStage': 'work_in_progress',
        },
      );

      expect(jobs, hasLength(2));
      expect(jobs.map((j) => j.assignmentField), containsAll(['assignedLabourUid', 'assignedLabourUid2']));
    });

    test('a request the technician is not assigned to yields no jobs', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-4',
        service: ServiceTypes.newSignage,
        technicianUid: technicianUid,
        data: {'assignedLabourUid': 'someone-else'},
      );
      expect(jobs, isEmpty);
    });
  });

  group('JobModel.fromRequestDoc — single-visit service (cleaning)', () {
    test('uses "Visit" as the label, "completed" as the done stage, and startingOtp/completionOtp', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-5',
        service: ServiceTypes.cleaning,
        technicianUid: technicianUid,
        data: {
          'assignedLabourUid': technicianUid,
          'startingOtp': '9999',
          'completionOtp': '8888',
          'trackingStage': 'tech_en_route',
        },
      );

      expect(jobs, hasLength(1));
      final job = jobs.single;
      expect(job.visitLabel, 'Visit');
      expect(job.doneStage, 'completed');
      expect(job.arrivalOtp, '9999');
      expect(job.completionOtp, '8888');
    });

    test('falls back to cleaningPhase when trackingStage is absent, like labour/page.tsx does', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-6',
        service: ServiceTypes.cleaning,
        technicianUid: technicianUid,
        data: {'assignedLabourUid': technicianUid, 'cleaningPhase': 'work_in_progress'},
      );

      expect(jobs.single.stage, 'work_in_progress');
      expect(jobs.single.isDone, isFalse);
    });

    test('a cleaning request never gets a second visit even with assignedLabourUid2 set', () {
      final jobs = JobModel.fromRequestDoc(
        id: 'req-7',
        service: ServiceTypes.cleaning,
        technicianUid: technicianUid,
        data: {'assignedLabourUid2': technicianUid},
      );
      expect(jobs, isEmpty);
    });
  });

  test('title falls back to "Signage Job" when signageType is missing, like web', () {
    final jobs = JobModel.fromRequestDoc(
      id: 'req-8',
      service: ServiceTypes.repairing,
      technicianUid: technicianUid,
      data: {'assignedLabourUid': technicianUid},
    );
    expect(jobs.single.title, 'Signage Job');
  });
}
