import 'package:get/get.dart';
import '../../../data/models/job_model.dart';

/// Proposed addition — technicians have zero quotation access on web
/// today (only `vendor_admin`/`super_admin` can view/edit
/// `finalQuotation` on `repair-requests/[id]/page.tsx`). This is a
/// read-only render of the same field, already present in the schema.
class QuotationController extends GetxController {
  late final JobModel job;

  @override
  void onInit() {
    super.onInit();
    job = Get.arguments as JobModel;
  }

  Map<String, dynamic> get quotation => job.finalQuotation ?? const {};

  String? get quotationNumber => quotation['quotationNumber'] as String?;
  String? get description => quotation['description'] as String?;
  num? get serviceCharges => quotation['serviceCharges'] as num?;
  num? get additionalCharges => quotation['additionalCharges'] as num?;
  num? get gstPercent => quotation['gstPercent'] as num?;
  num? get gstAmount => quotation['gstAmount'] as num?;
  num? get totalPayable => quotation['totalPayable'] as num?;
}
