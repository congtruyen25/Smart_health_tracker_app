import 'package:flutter/material.dart';
import 'package:smart_health_tracker/features/health/analysis/health_analyzer.dart';
import 'package:smart_health_tracker/features/health/analysis/health_status_helper.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/features/health/models/health_measurement.dart';
import 'package:smart_health_tracker/features/health/analysis/health_threshold.dart';
import 'add_health_measurement_screen.dart';

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({
    super.key,
  });

  @override
  State<HealthHistoryScreen> createState() =>
      _HealthHistoryScreenState();
}

class _HealthHistoryScreenState
    extends State<HealthHistoryScreen> {
  late Future<List<HealthMeasurement>> _measurements;
  late Future<HealthThreshold> _threshold;

  @override
  void initState() {
    super.initState();

    _loadMeasurements();
  }

  void _loadMeasurements() {
    _measurements =
        HealthDatabase.instance.getMeasurements();

    _threshold = _loadThreshold();
  }
  Future<HealthThreshold> _loadThreshold() async {
    final threshold =
    await HealthDatabase.instance.getHealthThreshold();

    return threshold ??
        HealthThreshold.defaultThreshold;
  }
  Future<void> _editMeasurement(
      HealthMeasurement measurement,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddHealthMeasurementScreen(
              measurement: measurement,
            ),
      ),
    );

    if (result == true) {
      setState(() {
        _loadMeasurements();
      });
    }
  }
    Future<void> _deleteMeasurement(
        HealthMeasurement measurement,
        ) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Delete Measurement',
            ),
            content: const Text(
              'Are you sure you want to delete this measurement?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        },
      );

      // Người dùng chọn Cancel
      if (confirm != true) {
        return;
      }

      try {
        final rowsAffected =
        await HealthDatabase.instance.deleteMeasurement(
          measurement.id!,
        );

        debugPrint(
          'Measurement deleted. Rows affected: $rowsAffected',
        );

        if (!mounted) return;

        // Reload History
        setState(() {
          _loadMeasurements();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Measurement deleted successfully.',
            ),
          ),
        );
      } catch (e) {
        debugPrint(
          'Failed to delete measurement: $e',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to delete measurement.',
            ),
          ),
        );
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History'),
      ),
      body: FutureBuilder<List<HealthMeasurement>>(
        future: _measurements,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load measurements.',
              ),
            );
          }

          final measurements =
              snapshot.data ?? [];

          if (measurements.isEmpty) {
            return const Center(
              child: Text(
                'No measurements yet.',
              ),
            );
          }

          return FutureBuilder<HealthThreshold>(
            future: _threshold,
            builder: (context, thresholdSnapshot) {
              if (thresholdSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (thresholdSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Failed to load health threshold.',
                  ),
                );
              }

              final threshold =
                  thresholdSnapshot.data ??
                      HealthThreshold.defaultThreshold;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement =
                  measurements[index];

                  return _MeasurementCard(
                    measurement: measurement,
                    threshold: threshold,
                    onEdit: () {
                      _editMeasurement(measurement);
                    },
                    onDelete: () {
                      _deleteMeasurement(measurement);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
class _MeasurementCard extends StatelessWidget {
  final HealthMeasurement measurement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final HealthThreshold threshold;

  const _MeasurementCard({
    required this.measurement,
    required this.threshold,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final analysis =
    HealthAnalyzer.analyzeMeasurement(
      measurement,
      threshold: threshold,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // ==================================================
            // DATE
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 17,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    _formatDate(
                      measurement.measuredAt,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // HEART RATE
            // ==================================================

            _MetricRow(
              icon: Icons.favorite_rounded,
              title: 'Heart Rate',
              value:
              '${measurement.heartRate.toStringAsFixed(0)} bpm',
              status: HealthStatusHelper.label(
                analysis.heartRateStatus,
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // BLOOD PRESSURE
            // ==================================================

            _MetricRow(
              icon: Icons.monitor_heart_rounded,
              title: 'Blood Pressure',
              value:
              '${measurement.systolic.toStringAsFixed(0)} / '
                  '${measurement.diastolic.toStringAsFixed(0)} mmHg',
              status: HealthStatusHelper.label(
                analysis.bloodPressureStatus,
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // GLUCOSE
            // ==================================================

            _MetricRow(
              icon: Icons.water_drop_rounded,
              title: 'Blood Glucose',
              value:
              '${measurement.bloodGlucose.toStringAsFixed(1)} mmol/L',
              status: HealthStatusHelper.label(
                analysis.glucoseStatus,
              ),
            ),

            // ==================================================
            // NOTE
            // ==================================================

            if (measurement.note != null &&
                measurement.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        measurement.note!.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ==================================================
            // ACTIONS
            // ==================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [

                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                  label: const Text('Edit'),
                ),

                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                  ),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';

    return '$date • $time';
  }

}
class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String status;

  const _MetricRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
    _getStatusColor(status);

    return Row(
      children: [

        // ICON
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.12),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),

        const SizedBox(width: 12),

        // TITLE + VALUE
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // STATUS
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(
              alpha: 0.12,
            ),
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final normalized = status.toUpperCase();

    if (normalized == 'NORMAL') {
      return Colors.green;
    }

    if (normalized == 'WARNING') {
      return Colors.orange;
    }

    if (normalized == 'DANGER') {
      return Colors.red;
    }

    return Colors.grey;
  }
}