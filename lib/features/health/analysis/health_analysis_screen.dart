import 'package:flutter/material.dart';

import 'health_analyzer.dart';
import 'health_analysis_result.dart';
import 'health_status.dart';
import 'health_status_helper.dart';

class HealthAnalysisScreen extends StatelessWidget {
  final HealthAnalysisResult result;

  const HealthAnalysisScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analysis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildOverallCard(context),

          const SizedBox(height: 20),

          const Text(
            'Health Indicators',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          _buildStatusCard(
            context,
            icon: Icons.favorite_rounded,
            title: 'Heart Rate',
            status: result.heartRateStatus,
          ),

          const SizedBox(height: 10),

          _buildStatusCard(
            context,
            icon: Icons.monitor_heart_rounded,
            title: 'Blood Pressure',
            status: result.bloodPressureStatus,
          ),

          const SizedBox(height: 10),

          _buildStatusCard(
            context,
            icon: Icons.water_drop_rounded,
            title: 'Blood Glucose',
            status: result.glucoseStatus,
          ),

          const SizedBox(height: 24),

          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildOverallCard(BuildContext context) {
    final status = result.overallStatus;
    final color = HealthStatusHelper.color(status);
    final label = HealthStatusHelper.label(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Health',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required HealthStatus status,
      }) {
    final color = HealthStatusHelper.color(status);
    final label = HealthStatusHelper.label(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'This analysis is based on your latest recorded health measurements.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}