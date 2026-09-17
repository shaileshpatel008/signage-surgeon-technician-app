import 'package:flutter_test/flutter_test.dart';
import 'package:signage_surgeon_technician/core/utils/common_utils.dart';

void main() {
  group('CommonUtils.formatStage', () {
    test('converts snake_case to Title Case, matching web formatStage()', () {
      expect(CommonUtils.formatStage('tech_en_route'), 'Tech En Route');
      expect(CommonUtils.formatStage('work_in_progress_2'), 'Work In Progress 2');
      expect(CommonUtils.formatStage('completed'), 'Completed');
    });

    test('handles null/empty as an em dash', () {
      expect(CommonUtils.formatStage(null), '—');
      expect(CommonUtils.formatStage(''), '—');
    });
  });

  group('CommonUtils.formatEquipment', () {
    test('maps known equipment codes', () {
      expect(CommonUtils.formatEquipment('ladder'), 'Ladder');
      expect(CommonUtils.formatEquipment('h_frame'), 'H-Frame (Palak)');
      expect(CommonUtils.formatEquipment('not_needed'), 'Not Needed');
    });

    test('falls back to the raw value for unknown codes', () {
      expect(CommonUtils.formatEquipment('crane'), 'crane');
    });
  });

  group('CommonUtils.initials', () {
    test('takes first letter of first and last name', () {
      expect(CommonUtils.initials('Rakesh Kumar'), 'RK');
    });

    test('single name uses just its first letter', () {
      expect(CommonUtils.initials('Rakesh'), 'R');
    });
  });
}
