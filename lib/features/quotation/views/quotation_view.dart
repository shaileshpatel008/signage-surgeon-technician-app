import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/quotation_controller.dart';

class QuotationView extends GetView<QuotationController> {
  const QuotationView({super.key});

  String _money(num? value) => value == null ? '—' : '₹${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(title: Text('Quotation ${controller.quotationNumber ?? ''}')),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Expanded(
            child: controller.quotation.isEmpty
                ? Center(
                    child: Text('No quotation has been sent for this job yet.', style: AppTextStyles.bodySmall),
                  )
                : ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Text('${controller.job.title} · ${controller.job.serviceLabel}', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 16),
                      if (controller.description != null) ...[
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SCOPE OF WORK', style: AppTextStyles.caption),
                              const SizedBox(height: 6),
                              Text(controller.description!, style: AppTextStyles.body),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CHARGES', style: AppTextStyles.caption),
                            const SizedBox(height: 8),
                            _Row('Service Charges', _money(controller.serviceCharges)),
                            _Row('Additional Charges', _money(controller.additionalCharges)),
                            _Row('GST (${controller.gstPercent ?? 18}%)', _money(controller.gstAmount)),
                            const Divider(height: 24),
                            _Row('Total Payable', _money(controller.totalPayable), emphasize: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.brandNavy.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Text(
                          'Quotations are prepared by your Vendor Admin. This screen is read-only for technicians — the repair visit unlocks automatically once the customer approves and pays.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _Row(this.label, this.value, {this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: emphasize ? AppTextStyles.h4 : AppTextStyles.bodySmall),
          Text(
            value,
            style: emphasize
                ? AppTextStyles.h4.copyWith(color: AppColors.brandRed)
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
