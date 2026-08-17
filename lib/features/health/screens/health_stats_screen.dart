import 'package:flutter/material.dart';
import '../widgets/health_trend_chart.dart';
import '../stats/health_stats.dart';
import '../stats/health_stats_service.dart';
import '../database/health_database.dart';
import '../models/health_measurement.dart';
import '../analysis/health_analyzer.dart';
import '../analysis/health_status_helper.dart';
import '../stats/health_trend_service.dart';
import '../analysis/health_threshold.dart';
import '../analysis/health_status.dart';
class HealthStatsScreen extends StatefulWidget {
  const HealthStatsScreen({
    super.key,
  });

  @override
  State<HealthStatsScreen> createState() =>
      _HealthStatsScreenState();
}

class _HealthStatsScreenState
    extends State<HealthStatsScreen> {
  late Future<List<HealthMeasurement>> _trendMeasurements;
  late Future<HealthStats> _stats;
  late Future<HealthMeasurement?> _latestMeasurement;
  late Future<HealthThreshold> _threshold;

  @override
  void initState() {
    super.initState();

    _loadStats();
  }

  void _loadStats() {
    _stats = HealthStatsService.getStats();

    _latestMeasurement =
        HealthDatabase.instance.getLatestMeasurement();

    _trendMeasurements =
        HealthTrendService.getLast7Days();

    _threshold = _loadThreshold();
  }
  Future<HealthThreshold> _loadThreshold() async {
    final threshold =
    await HealthDatabase.instance.getHealthThreshold();

    return threshold ??
        HealthThreshold.defaultThreshold;
  }

  Future<void> _refreshStats() async {
    setState(() {
      _loadStats();
    });

    await _stats;
    await _latestMeasurement;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Statistics'),
        actions: [
          IconButton(
            onPressed: _refreshStats,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: FutureBuilder<HealthStats>(
        future: _stats,
        builder: (context, statsSnapshot) {

          if (statsSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (statsSnapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load health statistics.',
              ),
            );
          }

          final stats =
              statsSnapshot.data ??
                  HealthStats.empty();

          if (stats.measurementCount == 0) {
            return _buildEmptyState();
          }

          return FutureBuilder<HealthMeasurement?>(
            future: _latestMeasurement,
            builder: (
                context,
                latestSnapshot,
                ) {
              final latestMeasurement =
                  latestSnapshot.data;

              return FutureBuilder<HealthThreshold>(
                future: _threshold,
                builder: (
                    context,
                    thresholdSnapshot,
                    ) {
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

                  return RefreshIndicator(
                    onRefresh: _refreshStats,
                    child: ListView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        32,
                      ),
                      children: [
                        // ==========================
                        // OVERVIEW
                        // ==========================

                        _buildOverviewCard(
                          stats,
                        ),

                        const SizedBox(height: 20),

                        // ==========================
                        // LATEST MEASUREMENT
                        // ==========================

                        if (latestMeasurement != null)
                          _buildLatestMeasurementCard(
                            latestMeasurement,
                            threshold,
                          ),

                        if (latestMeasurement != null)
                          const SizedBox(height: 20),

                        // ==========================
                        // HEALTH TREND
                        // ==========================

                        FutureBuilder<List<HealthMeasurement>>(
                          future: _trendMeasurements,
                          builder: (
                              context,
                              trendSnapshot,
                              ) {
                            if (trendSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child:
                                  CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (trendSnapshot.hasError) {
                              return const Text(
                                'Failed to load health trend.',
                              );
                            }

                            final measurements =
                                trendSnapshot.data ?? [];

                            return Column(
                              children: [
                                HealthTrendChart(
                                  measurements: measurements,
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),

                        // ==========================
                        // HEART RATE
                        // ==========================

                        _buildSectionTitle(
                          'Heart Rate',
                          Icons.favorite_rounded,
                        ),

                        const SizedBox(height: 10),

                        _buildStatisticCard(
                          title: 'Average',
                          value:
                          '${stats.averageHeartRate.toStringAsFixed(0)} bpm',
                          icon:
                          Icons.favorite_rounded,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child:
                              _buildSmallStatisticCard(
                                title: 'Minimum',
                                value:
                                '${stats.minHeartRate.toStringAsFixed(0)} bpm',
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child:
                              _buildSmallStatisticCard(
                                title: 'Maximum',
                                value:
                                '${stats.maxHeartRate.toStringAsFixed(0)} bpm',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ==========================
                        // BLOOD PRESSURE
                        // ==========================

                        _buildSectionTitle(
                          'Blood Pressure',
                          Icons.monitor_heart_rounded,
                        ),

                        const SizedBox(height: 10),

                        _buildStatisticCard(
                          title: 'Average',
                          value:
                          '${stats.averageSystolic.toStringAsFixed(0)} / '
                              '${stats.averageDiastolic.toStringAsFixed(0)} mmHg',
                          icon:
                          Icons.monitor_heart_rounded,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child:
                              _buildSmallStatisticCard(
                                title: 'Systolic',
                                value:
                                '${stats.averageSystolic.toStringAsFixed(0)} mmHg',
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child:
                              _buildSmallStatisticCard(
                                title: 'Diastolic',
                                value:
                                '${stats.averageDiastolic.toStringAsFixed(0)} mmHg',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ==========================
                        // BLOOD GLUCOSE
                        // ==========================

                        _buildSectionTitle(
                          'Blood Glucose',
                          Icons.water_drop_rounded,
                        ),

                        const SizedBox(height: 10),

                        _buildStatisticCard(
                          title: 'Average',
                          value:
                          '${stats.averageBloodGlucose.toStringAsFixed(1)} mmol/L',
                          icon:
                          Icons.water_drop_rounded,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child:
                              _buildSmallStatisticCard(
                                title: 'Minimum',
                                value:
                                '${stats.minBloodGlucose.toStringAsFixed(1)} mmol/L',
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child:
                              _buildSmallStatisticCard(
                                title: 'Maximum',
                                value:
                                '${stats.maxBloodGlucose.toStringAsFixed(1)} mmol/L',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ==========================
                        // SUMMARY
                        // ==========================

                        _buildSummaryCard(
                          stats,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [

            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey.shade500,
            ),

            const SizedBox(height: 16),

            const Text(
              'No measurements yet.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add a health measurement to see '
                  'your statistics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewCard(
      HealthStats stats,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(18),
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
      ),
      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  'Health Overview',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Total measurements',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${stats.measurementCount}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LATEST MEASUREMENT
  // ============================================================

  Widget _buildLatestMeasurementCard(
      HealthMeasurement measurement,
      HealthThreshold threshold,
      ) {

    final analysis =
    HealthAnalyzer.analyzeMeasurement(
      measurement,
      threshold: threshold,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Icon(
                Icons.access_time_rounded,
                size: 18,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Latest Measurement',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                _formatDate(
                  measurement.measuredAt,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: _LatestMetric(
                  icon:
                  Icons.favorite_rounded,
                  title: 'Heart Rate',
                  value:
                  '${measurement.heartRate.toStringAsFixed(0)} bpm',
                  status: analysis.heartRateStatus,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _LatestMetric(
                  icon:
                  Icons.monitor_heart_rounded,
                  title: 'Blood Pressure',
                  value:
                  '${measurement.systolic.toStringAsFixed(0)}/'
                      '${measurement.diastolic.toStringAsFixed(0)}',
                  status: analysis.bloodPressureStatus,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _LatestMetric(
                  icon:
                  Icons.water_drop_rounded,
                  title: 'Glucose',
                  value:
                  '${measurement.bloodGlucose.toStringAsFixed(1)}',
                  status: analysis.glucoseStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [

        Icon(
          icon,
          size: 20,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTIC CARD
  // ============================================================

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Row(
          children: [

            Icon(
              icon,
              size: 24,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SMALL STATISTIC CARD
  // ============================================================

  Widget _buildSmallStatisticCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCard(
      HealthStats stats,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          const Text(
            'Statistics Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Statistics are calculated from '
                '${stats.measurementCount} recorded measurements.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month ${hour}:$minute';
  }
}

// ================================================================
// LATEST METRIC
// ================================================================

  class _LatestMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final HealthStatus status;

  const _LatestMetric({
  required this.icon,
  required this.title,
  required this.value,
  required this.status,
  });

  @override
  Widget build(BuildContext context) {
  final statusLabel =
  HealthStatusHelper.label(status);

  final statusColor =
  HealthStatusHelper.color(status);

  return Column(
  children: [
  Icon(
  icon,
  size: 20,
  color: Theme.of(context)
      .colorScheme
      .primary,
  ),

  const SizedBox(height: 6),

  Text(
  title,
  textAlign: TextAlign.center,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
  fontSize: 10,
  ),
  ),

  const SizedBox(height: 4),

  Text(
  value,
  textAlign: TextAlign.center,
  style: const TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w800,
  ),
  ),

  const SizedBox(height: 3),

  Text(
  statusLabel,
  style: TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: statusColor,
  ),
  ),
  ],
  );
  }
  }