import 'package:flutter/material.dart';

import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),

              const SizedBox(height: 8),

              Text(
                label,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}