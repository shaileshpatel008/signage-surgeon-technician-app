import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// Matches the web app's empty-state copy exactly where one exists
/// (e.g. "No jobs assigned to you right now.") — pass [title] verbatim
/// from the equivalent web string rather than rewording it.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const AppEmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.brandNavy.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Icon(icon, size: 28, color: AppColors.mutedText),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }
}
