import 'package:flutter_test/flutter_test.dart';
import 'package:signage_surgeon_technician/data/models/job_model.dart';

void main() {
  group('JobModel.fromSiteVisitDoc — two-visit service (repair/rebranding/new signage)', () {
    test('builds the Site Visit job with the right stage keys and OTP fields', () {
      final job = JobModel.fromSiteVisitDoc(
        id: 'req-1',
        service: ServiceTypes.repairing,
        data: {
          'signageType': 'LED Signboard',
          'trackingStage': 'tech_en_route',
          'siteVisitArrivalOtp': '1234',
          'siteVisitCompletionOtp': '5678',
        },
      );

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
  });

  group('JobModel.fromRepairVisitDoc — two-visit service', () {
    test('builds the Repair Visit job using the "_2" stage keys and workArrivalOtp', () {
      final job = JobModel.fromRepairVisitDoc(
        id: 'req-2',
        service: ServiceTypes.repairing,
        data: {
          'signageType': 'LED Signboard',
          'trackingStage': 'work_in_progress_2',
          'workArrivalOtp': '1111',
          'workCompletionOtp': '2222',
        },
      );

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

    test(
      'a technician on BOTH visits of the same request yields two distinct jobs, one per query — '
      'this is the duplicate-listing regression: neither factory looks at the other assignment '
      'field, matching the two independent forEach loops in labour/page.tsx',
      () {
        final data = {'assignedLabourUid': 'tech-123', 'assignedLabourUid2': 'tech-123', 'trackingStage': 'work_in_progress'};

        final siteVisitJob = JobModel.fromSiteVisitDoc(id: 'req-3', service: ServiceTypes.rebranding, data: data);
        final repairVisitJob = JobModel.fromRepairVisitDoc(id: 'req-3', service: ServiceTypes.rebranding, data: data);

        expect(siteVisitJob.assignmentField, 'assignedLabourUid');
        expect(repairVisitJob.assignmentField, 'assignedLabourUid2');
        expect(siteVisitJob.id, repairVisitJob.id);
      },
    );
  });

  group('JobModel.fromSiteVisitDoc — single-visit service (cleaning)', () {
    test('uses "Visit" as the label, "completed" as the done stage, and startingOtp/completionOtp', () {
      final job = JobModel.fromSiteVisitDoc(
        id: 'req-5',
        service: ServiceTypes.cleaning,
        data: {'startingOtp': '9999', 'completionOtp': '8888', 'trackingStage': 'tech_en_route'},
      );

      expect(job.visitLabel, 'Visit');
      expect(job.doneStage, 'completed');
      expect(job.arrivalOtp, '9999');
      expect(job.completionOtp, '8888');
    });

    test('falls back to cleaningPhase when trackingStage is absent, like labour/page.tsx does', () {
      final job = JobModel.fromSiteVisitDoc(
        id: 'req-6',
        service: ServiceTypes.cleaning,
        data: {'cleaningPhase': 'work_in_progress'},
      );

      expect(job.stage, 'work_in_progress');
      expect(job.isDone, isFalse);
    });
  });

  test('title falls back to "Signage Job" when signageType is missing, like web', () {
    final job = JobModel.fromSiteVisitDoc(id: 'req-8', service: ServiceTypes.repairing, data: const {});
    expect(job.title, 'Signage Job');
  });
}
