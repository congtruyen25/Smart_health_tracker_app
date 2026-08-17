import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final weekday = _weekday(now.weekday);
    final month = _month(now.month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$weekday, ${now.day} $month',
              style: AppTextStyles.caption,
            ),

            const SizedBox(height: 8),

            Text(
              'Good morning,',
              style: AppTextStyles.greeting,
            ),

            Text(
              '$userName.',
              style: AppTextStyles.greeting.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: const CircleAvatar(
            backgroundColor: AppColors.surface,
            child: Icon(
              Icons.person,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _weekday(int day) {
    const days = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    return days[day - 1];
  }

  String _month(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[month - 1];
  }
}