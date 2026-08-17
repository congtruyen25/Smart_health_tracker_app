import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/health_measurement.dart';

enum HealthTrendMetric {
  heartRate,
  bloodPressure,
  glucose,
}

class HealthTrendChart extends StatefulWidget {
  final List<HealthMeasurement> measurements;

  const HealthTrendChart({
    super.key,
    required this.measurements,
  });

  @override
  State<HealthTrendChart> createState() =>
      _HealthTrendChartState();
}

class _HealthTrendChartState
    extends State<HealthTrendChart> {

  HealthTrendMetric _selectedMetric =
      HealthTrendMetric.heartRate;
  Widget _buildBloodPressureLegend() {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        _buildLegendItem(
          color: primary,
          label: 'Systolic',
        ),

        const SizedBox(width: 20),

        _buildLegendItem(
          color: primary.withValues(alpha: 0.5),
          label: 'Diastolic',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    if (widget.measurements.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // =====================================================
          // HEADER
          // =====================================================

          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 20,
                color:
                Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  '7-Day Health Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =====================================================
          // METRIC SELECTOR
          // =====================================================

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [

                _buildMetricChip(
                  metric: HealthTrendMetric.heartRate,
                  icon: Icons.favorite_rounded,
                  label: 'Heart Rate',
                ),

                const SizedBox(width: 8),

                _buildMetricChip(
                  metric: HealthTrendMetric.bloodPressure,
                  icon: Icons.monitor_heart_rounded,
                  label: 'Blood Pressure',
                ),

                const SizedBox(width: 8),

                _buildMetricChip(
                  metric: HealthTrendMetric.glucose,
                  icon: Icons.water_drop_rounded,
                  label: 'Glucose',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // =====================================================
          // CURRENT METRIC TITLE
          // =====================================================

          Text(
            _metricTitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (_selectedMetric == HealthTrendMetric.bloodPressure) ...[
            const SizedBox(height: 10),
            _buildBloodPressureLegend(),
          ],

          const SizedBox(height: 16),

          // =====================================================
          // CHART
          // =====================================================

          SizedBox(
            height: 220,
            child: LineChart(
              _buildChartData(context),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRIC CHIP
  // ============================================================

  Widget _buildMetricChip({
    required HealthTrendMetric metric,
    required IconData icon,
    required String label,
  }) {
    final isSelected =
        _selectedMetric == metric;

    final primary =
        Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = metric;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? primary
                : Theme.of(context)
                .dividerColor,
          ),
        ),

        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [

            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Theme.of(context)
                  .colorScheme
                  .onPrimary
                  : primary,
            ),

            const SizedBox(width: 6),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context)
                    .colorScheme
                    .onPrimary
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // METRIC TITLE
  // ============================================================

  String get _metricTitle {
    switch (_selectedMetric) {
      case HealthTrendMetric.heartRate:
        return 'Heart Rate';

      case HealthTrendMetric.bloodPressure:
        return 'Blood Pressure';

      case HealthTrendMetric.glucose:
        return 'Blood Glucose';
    }
  }

  // ============================================================
  // CHART DATA
  // ============================================================

  LineChartData _buildChartData(
      BuildContext context,
      ) {

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    final singleSpots = <FlSpot>[];

    for (int i = 0; i < widget.measurements.length; i++) {
      final measurement = widget.measurements[i];

      switch (_selectedMetric) {
        case HealthTrendMetric.heartRate:
          singleSpots.add(
            FlSpot(
              i.toDouble(),
              measurement.heartRate,
            ),
          );
          break;

        case HealthTrendMetric.bloodPressure:
          systolicSpots.add(
            FlSpot(
              i.toDouble(),
              measurement.systolic,
            ),
          );

          diastolicSpots.add(
            FlSpot(
              i.toDouble(),
              measurement.diastolic,
            ),
          );
          break;

        case HealthTrendMetric.glucose:
          singleSpots.add(
            FlSpot(
              i.toDouble(),
              measurement.bloodGlucose,
            ),
          );
          break;
      }
    }

    final allValues = <double>[];

    if (_selectedMetric == HealthTrendMetric.bloodPressure) {
      allValues.addAll(
        systolicSpots.map((spot) => spot.y),
      );

      allValues.addAll(
        diastolicSpots.map((spot) => spot.y),
      );
    } else {
      allValues.addAll(
        singleSpots.map((spot) => spot.y),
      );
    }

    final minValue = allValues.reduce(
          (a, b) => a < b ? a : b,
    );

    final maxValue = allValues.reduce(
          (a, b) => a > b ? a : b,
    );

    double interval;
    double padding;

    switch (_selectedMetric) {

      case HealthTrendMetric.heartRate:
        interval = 10;
        padding = 10;
        break;

      case HealthTrendMetric.bloodPressure:
        interval = 10;
        padding = 10;
        break;

      case HealthTrendMetric.glucose:
        interval = 1;
        padding = 1;
        break;
    }

    final minY =
    (minValue - padding)
        .clamp(0, double.infinity)
        .toDouble();

    final maxY =
        maxValue + padding;

    return LineChartData(

      minY: minY,
      maxY: maxY,

      // ========================================================
      // GRID
      // ========================================================

      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
      ),

      // ========================================================
      // BORDER
      // ========================================================

      borderData: FlBorderData(
        show: false,
      ),

      // ========================================================
      // TITLES
      // ========================================================

      titlesData: FlTitlesData(

        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),

        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),

        // ------------------------------------------------------
        // LEFT
        // ------------------------------------------------------

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: interval,

            getTitlesWidget:
                (value, meta) {

              return Text(
                _formatYAxisValue(value),
                style: TextStyle(
                  fontSize: 10,
                  color:
                  Colors.grey.shade600,
                ),
              );
            },
          ),
        ),

        // ------------------------------------------------------
        // BOTTOM
        // ------------------------------------------------------

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,

            getTitlesWidget:
                (value, meta) {

              final index =
              value.toInt();

              if (index < 0 ||
                  index >=
                      widget.measurements.length) {
                return const SizedBox.shrink();
              }

              final date =
                  widget.measurements[index]
                      .measuredAt;

              return Padding(
                padding:
                const EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  '${date.day}/${date.month}',
                  style: TextStyle(
                    fontSize: 10,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              );
            },
          ),
        ),
      ),

      // ========================================================
      // TOUCH / TOOLTIP
      // ========================================================

      lineTouchData: LineTouchData(
        enabled: true,

        touchTooltipData:
        LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              if (_selectedMetric ==
                  HealthTrendMetric.bloodPressure) {

                final label =
                spot.barIndex == 0
                    ? 'Systolic'
                    : 'Diastolic';

                return LineTooltipItem(
                  '$label: ${spot.y.toStringAsFixed(0)} mmHg',
                  const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                );
              }

              return LineTooltipItem(
                _formatTooltipValue(spot.y),
                const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList();
          },
        ),
      ),

      // ========================================================
      // LINE
      // ========================================================

      lineBarsData: _buildLineBars(
        context,
        singleSpots,
        systolicSpots,
        diastolicSpots,
      ),
    );
  }

  // ============================================================
  // Y AXIS FORMAT
  // ============================================================

  String _formatYAxisValue(
      double value,
      ) {

    switch (_selectedMetric) {

      case HealthTrendMetric.heartRate:
      case HealthTrendMetric.bloodPressure:
        return value
            .toInt()
            .toString();

      case HealthTrendMetric.glucose:
        return value
            .toStringAsFixed(1);
    }
  }

  // ============================================================
  // TOOLTIP FORMAT
  // ============================================================

  String _formatTooltipValue(
      double value,
      ) {

    switch (_selectedMetric) {

      case HealthTrendMetric.heartRate:
        return '${value.toStringAsFixed(0)} bpm';

      case HealthTrendMetric.bloodPressure:
        return '${value.toStringAsFixed(0)} mmHg';

      case HealthTrendMetric.glucose:
        return '${value.toStringAsFixed(1)} mmol/L';
    }
  }
  List<LineChartBarData> _buildLineBars(
      BuildContext context,
      List<FlSpot> singleSpots,
      List<FlSpot> systolicSpots,
      List<FlSpot> diastolicSpots,
      ) {
    final primary =
        Theme.of(context).colorScheme.primary;

    if (_selectedMetric == HealthTrendMetric.bloodPressure) {
      return [
        LineChartBarData(
          spots: systolicSpots,
          isCurved: true,
          barWidth: 3,
          color: primary,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),

        LineChartBarData(
          spots: diastolicSpots,
          isCurved: true,
          barWidth: 3,
          color: primary.withValues(alpha: 0.5),
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ];
    }

    return [
      LineChartBarData(
        spots: singleSpots,
        isCurved: true,
        barWidth: 3,
        color: primary,
        dotData: const FlDotData(
          show: true,
        ),
        belowBarData: BarAreaData(
          show: true,
        ),
      ),
    ];
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      ) {

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(24),

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

      child: const Column(
        children: [

          Icon(
            Icons.show_chart_rounded,
            size: 40,
          ),

          SizedBox(height: 10),

          Text(
            'No trend data available.',
            style: TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}