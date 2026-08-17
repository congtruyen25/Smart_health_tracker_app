import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class OverallHealthCard extends StatelessWidget {
  final String status;
  final String description;

  const OverallHealthCard({
    super.key,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Health',
            style: AppTextStyles.sectionTitle,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(
                    alpha: 0.12,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}