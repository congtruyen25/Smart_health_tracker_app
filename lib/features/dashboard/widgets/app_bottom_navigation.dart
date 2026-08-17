import 'package:flutter/material.dart';

import 'package:smart_health_tracker/app/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;

  const AppBottomNavigation({
    super.key,
    this.currentIndex = 0,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _item(
              0,
              Icons.grid_view_rounded,
              'Home',
            ),
          ),

          Expanded(
            child: _item(
              1,
              Icons.access_time_rounded,
              'Log',
            ),
          ),

          const SizedBox(width: 64),

          Expanded(
            child: _item(
              2,
              Icons.show_chart_rounded,
              'Stats',
            ),
          ),

          Expanded(
            child: _item(
              3,
              Icons.person_outline_rounded,
              'Me',
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
      int index,
      IconData icon,
      String label,
      ) {
    final selected = currentIndex == index;

    return InkWell(
      onTap: () => onItemSelected?.call(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 21,
            color: selected
                ? AppColors.primary
                : AppColors.textMuted,
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}