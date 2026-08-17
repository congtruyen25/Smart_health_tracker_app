import 'package:flutter/material.dart';

import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/features/health/models/health_measurement.dart';
import 'package:smart_health_tracker/features/health/stats/health_trend_service.dart';
import 'package:smart_health_tracker/features/health/screens/health_stats_screen.dart';

enum TrendMetric {
  heartRate,
  bloodPressure,
  bloodGlucose,
}

class HealthTrendCard extends StatefulWidget {
  final int refreshKey;
  const HealthTrendCard({
    super.key,
    required this.refreshKey,
  });

  @override
  State<HealthTrendCard> createState() =>
      _HealthTrendCardState();
}

class _HealthTrendCardState
    extends State<HealthTrendCard> {

  late Future<List<HealthMeasurement>> _measurements;

  TrendMetric _selectedMetric =
      TrendMetric.heartRate;

  @override
  void initState() {
    super.initState();

    _loadTrend();
  }
  @override
  @override
  void didUpdateWidget(
      covariant HealthTrendCard oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      _loadTrend();
    }
  }
  void _loadTrend() {
    setState(() {
      _measurements =
          HealthTrendService.getLast7Days();
    });
  }

  void _openStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const HealthStatsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          // ==============================
          // HEADER
          // ==============================

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [

              const Text(
                'Health Trend',
                style:
                AppTextStyles.sectionTitle,
              ),

              TextButton(
                onPressed: _openStats,
                child: const Text(
                  'See all →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ==============================
          // METRIC SELECTOR
          // ==============================

          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,
            child: Row(
              children: [

                _buildMetricButton(
                  TrendMetric.heartRate,
                  'Heart Rate',
                ),

                const SizedBox(width: 8),

                _buildMetricButton(
                  TrendMetric.bloodPressure,
                  'Blood Pressure',
                ),

                const SizedBox(width: 8),

                _buildMetricButton(
                  TrendMetric.bloodGlucose,
                  'Glucose',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ==============================
          // CHART
          // ==============================

          Expanded(
            child: FutureBuilder<
                List<HealthMeasurement>>(
              future: _measurements,
              builder: (
                  context,
                  snapshot,
                  ) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Failed to load health trend.',
                    ),
                  );
                }

                final measurements =
                    snapshot.data ?? [];

                if (measurements.isEmpty) {
                  return const Center(
                    child: Text(
                      'No trend data yet.',
                      style:
                      AppTextStyles.caption,
                    ),
                  );
                }

                return _TrendChart(
                  measurements:
                  measurements,
                  metric:
                  _selectedMetric,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ======================================
  // METRIC BUTTON
  // ======================================

  Widget _buildMetricButton(
      TrendMetric metric,
      String label,
      ) {
    final selected =
        _selectedMetric == metric;

    return TextButton(
      onPressed: () {
        setState(() {
          _selectedMetric = metric;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: selected
            ? AppColors.primary
            : AppColors.background,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.w600,
          color: selected
              ? AppColors.background
              : AppColors.textMuted,
        ),
      ),
    );
  }
}


// =====================================================
// TREND CHART
// =====================================================

class _TrendChart extends StatelessWidget {
  final List<HealthMeasurement> measurements;
  final TrendMetric metric;

  const _TrendChart({
    required this.measurements,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {

    switch (metric) {

      case TrendMetric.heartRate:
        return _HeartRateTrend(
          measurements:
          measurements,
        );

      case TrendMetric.bloodPressure:
        return _BloodPressureTrend(
          measurements:
          measurements,
        );

      case TrendMetric.bloodGlucose:
        return _BloodGlucoseTrend(
          measurements:
          measurements,
        );
    }
  }
}


// =====================================================
// HEART RATE
// =====================================================

class _HeartRateTrend
    extends StatelessWidget {

  final List<HealthMeasurement>
  measurements;

  const _HeartRateTrend({
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {

    final values = measurements
        .map(
          (measurement) =>
      measurement.heartRate,
    )
        .toList();

    final minValue =
    values.reduce(
          (a, b) => a < b ? a : b,
    );

    final maxValue =
    values.reduce(
          (a, b) => a > b ? a : b,
    );

    final average =
        values.reduce(
              (a, b) => a + b,
        ) /
            values.length;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 18,
            ),

            const SizedBox(width: 6),

            const Text(
              'Heart Rate',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const Spacer(),

            Text(
              '${average.toStringAsFixed(0)} bpm avg',
              style:
              AppTextStyles.caption,
            ),
          ],
        ),

        const SizedBox(height: 10),

        Expanded(
          child: CustomPaint(
            painter: _TrendPainter(
              values: values,
            ),
            child:
            const SizedBox.expand(),
          ),
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [

            Text(
              'Min ${minValue.toStringAsFixed(0)}',
              style:
              AppTextStyles.caption,
            ),

            Text(
              'Max ${maxValue.toStringAsFixed(0)}',
              style:
              AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}


// =====================================================
// BLOOD PRESSURE
// =====================================================

class _BloodPressureTrend
    extends StatelessWidget {

  final List<HealthMeasurement>
  measurements;

  const _BloodPressureTrend({
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {

    final systolic = measurements
        .map(
          (measurement) =>
      measurement.systolic,
    )
        .toList();

    final diastolic = measurements
        .map(
          (measurement) =>
      measurement.diastolic,
    )
        .toList();

    final averageSystolic =
        systolic.reduce(
              (a, b) => a + b,
        ) /
            systolic.length;

    final averageDiastolic =
        diastolic.reduce(
              (a, b) => a + b,
        ) /
            diastolic.length;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            const Icon(
              Icons.monitor_heart_rounded,
              color: AppColors.primary,
              size: 18,
            ),

            const SizedBox(width: 6),

            const Text(
              'Blood Pressure',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const Spacer(),

            Text(
              '${averageSystolic.toStringAsFixed(0)}/'
                  '${averageDiastolic.toStringAsFixed(0)} avg',
              style:
              AppTextStyles.caption,
            ),
          ],
        ),

        const SizedBox(height: 8),

        Expanded(
          child: CustomPaint(
            painter:
            _BloodPressurePainter(
              systolic: systolic,
              diastolic: diastolic,
            ),
            child:
            const SizedBox.expand(),
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Systolic / Diastolic',
          style:
          AppTextStyles.caption,
        ),
      ],
    );
  }
}


// =====================================================
// BLOOD GLUCOSE
// =====================================================

class _BloodGlucoseTrend
    extends StatelessWidget {

  final List<HealthMeasurement>
  measurements;

  const _BloodGlucoseTrend({
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {

    final values = measurements
        .map(
          (measurement) =>
      measurement.bloodGlucose,
    )
        .toList();

    final average =
        values.reduce(
              (a, b) => a + b,
        ) /
            values.length;

    final minValue =
    values.reduce(
          (a, b) => a < b ? a : b,
    );

    final maxValue =
    values.reduce(
          (a, b) => a > b ? a : b,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            const Icon(
              Icons.water_drop_rounded,
              color: AppColors.primary,
              size: 18,
            ),

            const SizedBox(width: 6),

            const Text(
              'Blood Glucose',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const Spacer(),

            Text(
              '${average.toStringAsFixed(1)} mmol/L avg',
              style:
              AppTextStyles.caption,
            ),
          ],
        ),

        const SizedBox(height: 8),

        Expanded(
          child: CustomPaint(
            painter: _TrendPainter(
              values: values,
            ),
            child:
            const SizedBox.expand(),
          ),
        ),

        const SizedBox(height: 4),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [

            Text(
              'Min ${minValue.toStringAsFixed(1)}',
              style:
              AppTextStyles.caption,
            ),

            Text(
              'Max ${maxValue.toStringAsFixed(1)}',
              style:
              AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}


// =====================================================
// NORMAL TREND PAINTER
// =====================================================

class _TrendPainter
    extends CustomPainter {

  final List<double> values;

  _TrendPainter({
    required this.values,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {

    if (values.isEmpty) {
      return;
    }

    final minValue =
    values.reduce(
          (a, b) => a < b ? a : b,
    );

    final maxValue =
    values.reduce(
          (a, b) => a > b ? a : b,
    );

    final range =
        maxValue - minValue;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style =
          PaintingStyle.stroke
      ..strokeCap =
          StrokeCap.round;

    final path = Path();

    for (int i = 0;
    i < values.length;
    i++) {

      final x = values.length == 1
          ? size.width / 2
          : i *
          size.width /
          (values.length - 1);

      final normalized =
      range == 0
          ? 0.5
          : (values[i] -
          minValue) /
          range;

      final y =
          size.height -
              normalized *
                  (size.height - 12) -
              6;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      paint,
    );

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style =
          PaintingStyle.fill;

    for (int i = 0;
    i < values.length;
    i++) {

      final x = values.length == 1
          ? size.width / 2
          : i *
          size.width /
          (values.length - 1);

      final normalized =
      range == 0
          ? 0.5
          : (values[i] -
          minValue) /
          range;

      final y =
          size.height -
              normalized *
                  (size.height - 12) -
              6;

      canvas.drawCircle(
        Offset(x, y),
        3.5,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _TrendPainter oldDelegate,
      ) {
    return oldDelegate.values != values;
  }
}


// =====================================================
// BLOOD PRESSURE PAINTER
// =====================================================

class _BloodPressurePainter
    extends CustomPainter {

  final List<double> systolic;
  final List<double> diastolic;

  _BloodPressurePainter({
    required this.systolic,
    required this.diastolic,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {

    if (systolic.isEmpty) {
      return;
    }

    final allValues = [
      ...systolic,
      ...diastolic,
    ];

    final minValue =
    allValues.reduce(
          (a, b) => a < b ? a : b,
    );

    final maxValue =
    allValues.reduce(
          (a, b) => a > b ? a : b,
    );

    final range =
        maxValue - minValue;

    final systolicPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style =
          PaintingStyle.stroke
      ..strokeCap =
          StrokeCap.round;

    final diastolicPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style =
          PaintingStyle.stroke
      ..strokeCap =
          StrokeCap.round;

    _drawLine(
      canvas,
      size,
      systolic,
      minValue,
      range,
      systolicPaint,
    );

    _drawLine(
      canvas,
      size,
      diastolic,
      minValue,
      range,
      diastolicPaint,
    );
  }

  void _drawLine(
      Canvas canvas,
      Size size,
      List<double> values,
      double minValue,
      double range,
      Paint paint,
      ) {

    if (values.isEmpty) {
      return;
    }

    final path = Path();

    for (int i = 0;
    i < values.length;
    i++) {

      final x = values.length == 1
          ? size.width / 2
          : i *
          size.width /
          (values.length - 1);

      final normalized =
      range == 0
          ? 0.5
          : (values[i] -
          minValue) /
          range;

      final y =
          size.height -
              normalized *
                  (size.height - 12) -
              6;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      paint,
    );

    final pointPaint = Paint()
      ..color = paint.color
      ..style =
          PaintingStyle.fill;

    for (int i = 0;
    i < values.length;
    i++) {

      final x = values.length == 1
          ? size.width / 2
          : i *
          size.width /
          (values.length - 1);

      final normalized =
      range == 0
          ? 0.5
          : (values[i] -
          minValue) /
          range;

      final y =
          size.height -
              normalized *
                  (size.height - 12) -
              6;

      canvas.drawCircle(
        Offset(x, y),
        3.5,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _BloodPressurePainter
      oldDelegate,
      ) {
    return oldDelegate.systolic !=
        systolic ||
        oldDelegate.diastolic !=
            diastolic;
  }
}