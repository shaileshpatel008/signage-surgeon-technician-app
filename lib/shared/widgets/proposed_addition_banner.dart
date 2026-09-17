import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// The amber "not in the current web app" banner from the approved
/// full-app mockup — shown on every proposed-addition screen. Gated by
/// [AppConstants.showProposedAdditionBanners] so it's a one-line change
/// to remove once a screen graduates to fully-wired, or once the client
/// simply wants it gone from production builds.
class ProposedAdditionBanner extends StatelessWidget {
  const ProposedAdditionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.showProposedAdditionBanners) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF4D6),
        border: Border(bottom: BorderSide(color: AppColors.brandYellowDark, width: 1.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
          SizedBox(width: 6),
          Text(
            'PROPOSED ADDITION — NOT IN WEB APP TODAY',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}
