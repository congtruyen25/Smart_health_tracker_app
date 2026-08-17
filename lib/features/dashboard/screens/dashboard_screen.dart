import 'package:flutter/material.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/features/health/models/health_measurement.dart';
import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/app/theme/app_spacing.dart';
import '../../health/analysis/health_analyzer.dart';
import '../../health/analysis/health_status_helper.dart';
import '../../health/screens/add_health_measurement_screen.dart';
import '../../health/screens/health_history_screen.dart';
import '../../health/analysis/health_analysis_result.dart';
import '../widgets/greeting_header.dart';
import '../widgets/overall_health_card.dart';
import '../widgets/health_metric_card.dart';
import '../widgets/health_trend_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/app_bottom_navigation.dart';
import '../../health/analysis/health_threshold.dart';
import '../../profile/screens/me_screen.dart';
import '../../health/analysis/health_analysis_screen.dart';
import '../../health/screens/health_stats_screen.dart';
import '../../health/report/health_report_pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:smart_health_tracker/features/profile/models/user_profile.dart';
import '../../reminder/screens/reminder_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  HealthAnalysisResult? _getAnalysis() {
    final measurement = _latestMeasurement;

    if (measurement == null) {
      return null;
    }

    final threshold =
        _healthThreshold ??
            HealthThreshold.defaultThreshold;

    return HealthAnalyzer.analyzeMeasurement(
      measurement,
      threshold: threshold,
    );
  }

  HealthMeasurement? _latestMeasurement;
  UserProfile? _userProfile;
  HealthThreshold? _healthThreshold;
  bool _isLoading = true;
  int _refreshKey = 0;
  @override
  void initState() {
    super.initState();

    _loadLatestMeasurement();
    _loadUserProfile();
    _loadHealthThreshold();
  }
  Future<void> _loadUserProfile() async {
    final profile =
    await HealthDatabase.instance.getUserProfile();

    if (!mounted) return;

    setState(() {
      _userProfile = profile;
    });
  }
  Future<void> _loadHealthThreshold() async {
    try {
      final threshold =
      await HealthDatabase.instance.getHealthThreshold();

      if (!mounted) return;

      setState(() {
        _healthThreshold =
            threshold ?? HealthThreshold.defaultThreshold;
      });
    } catch (e) {
      debugPrint(
        'Failed to load health threshold: $e',
      );

      if (!mounted) return;

      setState(() {
        _healthThreshold =
            HealthThreshold.defaultThreshold;
      });
    }
  }
  Future<void> _loadLatestMeasurement() async {
    final measurement =
    await HealthDatabase.instance.getLatestMeasurement();

    if (!mounted) return;

    setState(() {
      _latestMeasurement = measurement;
      _isLoading = false;
    });
  }
  Future<void> _openHealthReport() async {
    try {
      final measurements =
      await HealthDatabase.instance.getMeasurements();

      if (!mounted) return;

      if (measurements.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No health measurements available for the report.',
            ),
          ),
        );

        return;
      }

      final pdfData =
      await HealthReportPdfService.generateReport(
        measurements: measurements,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Health Report'),
              ),
              body: PdfPreview(
                build: (format) async {
                  return pdfData;
                },
              ),
            );
          },
        ),
      );
    } catch (e) {
      debugPrint(
        'Failed to generate health report: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to generate health report.',
          ),
        ),
      );
    }
  }
  Widget _buildOverallHealthCard() {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final analysis = _getAnalysis();

    if (analysis == null) {
      return const OverallHealthCard(
        status: 'NO DATA',
        description:
        'Add a health measurement to see your health status.',
      );
    }

    return OverallHealthCard(
      status: HealthStatusHelper.label(
        analysis.overallStatus,
      ),
      description:
      'Based on your latest measurements',
    );
  }
  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Future<void> _onNavigationItemSelected(int index) async {
    switch (index) {
      case 0:
      // Home
      // Đang ở Dashboard nên không cần làm gì.
        break;

      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const HealthHistoryScreen(),
          ),
        );

        if (!mounted) return;

        await _loadLatestMeasurement();

        setState(() {
          _refreshKey++;
        });

        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const HealthStatsScreen(),
          ),
        );
        break;

      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MeScreen(),
          ),
        );

        if (!mounted) return;

        await _loadUserProfile();
        await _loadHealthThreshold();

        setState(() {
          _refreshKey++;
        });

        break;
    }
  }

  // ============================================================
  // BUILD DASHBOARD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              GreetingHeader(
                userName: _userProfile?.name ?? 'User',
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildStreak(),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              _buildOverallHealthCard(),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              const Text(
                "Today's Measurements",
                style: AppTextStyles.sectionTitle,
              ),

              const SizedBox(height: 12),

              _buildMetrics(),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              HealthTrendCard(
                refreshKey: _refreshKey,
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              const Text(
                'Quick Actions',
                style: AppTextStyles.sectionTitle,
              ),

              const SizedBox(height: 12),

              _buildQuickActions(),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onItemSelected:
        _onNavigationItemSelected,
      ),

      // ========================================================
      // ADD MEASUREMENT BUTTON
      // ========================================================

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const AddHealthMeasurementScreen(),
            ),
          );

          if (!mounted) return;

          await _loadLatestMeasurement();

          setState(() {
            _refreshKey++;
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,

        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
    );
  }

  // ============================================================
  // STREAK CARD
  // ============================================================

  Widget _buildStreak() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.medical_services_outlined,
            color: Color(0xFF9B7BFF),
            size: 28,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '7-day health tracking streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'You are keeping track of your health.',
                  style:
                  AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH METRICS
  // ============================================================

  Widget _buildMetrics() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final measurement = _latestMeasurement;

    if (measurement == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 40,
            ),
            SizedBox(height: 8),
            Text('No measurements yet'),
            SizedBox(height: 4),
            Text(
              'Add your first health measurement.',
            ),
          ],
        ),
      );
    }

    final analysis = _getAnalysis();

    if (analysis == null) {
      return const SizedBox.shrink();
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        // Heart Rate
        HealthMetricCard(
          icon: Icons.favorite_rounded,
          title: 'Heart Rate',
          value: measurement.heartRate.toStringAsFixed(0),
          unit: 'bpm',
          status: HealthStatusHelper.label(
            analysis.heartRateStatus,
          ),
          statusColor: HealthStatusHelper.color(
            analysis.heartRateStatus,
          ),
        ),

        // Blood Pressure
        HealthMetricCard(
          icon: Icons.monitor_heart_rounded,
          title: 'Blood Pressure',
          value:
          '${measurement.systolic.toStringAsFixed(0)}/'
              '${measurement.diastolic.toStringAsFixed(0)}',
          unit: 'mmHg',
          status: HealthStatusHelper.label(
            analysis.bloodPressureStatus,
          ),
          statusColor: HealthStatusHelper.color(
            analysis.bloodPressureStatus,
          ),
        ),

        // Blood Glucose
        HealthMetricCard(
          icon: Icons.water_drop_rounded,
          title: 'Blood Glucose',
          value: measurement.bloodGlucose.toStringAsFixed(1),
          unit: 'mmol/L',
          status: HealthStatusHelper.label(
            analysis.glucoseStatus,
          ),
          statusColor: HealthStatusHelper.color(
            analysis.glucoseStatus,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Row(
      children: [
        QuickActionCard(
          icon: Icons.add,
          label: 'Add',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const AddHealthMeasurementScreen(),
              ),
            );

            if (!mounted) return;

            await _loadLatestMeasurement();

            setState(() {
              _refreshKey++;
            });
          },
        ),

        const SizedBox(width: 8),

        QuickActionCard(
          icon: Icons.description_outlined,
          label: 'Report',
          onTap: _openHealthReport,
        ),

        const SizedBox(width: 8),

        QuickActionCard(
          icon: Icons.notifications_none,
          label: 'Remind',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const ReminderScreen(),
              ),
            );
          },
        ),

        const SizedBox(width: 8),

        QuickActionCard(
          icon: Icons.auto_awesome,
          label: 'Analyse',
          onTap: () {
            final analysis = _getAnalysis();

            if (analysis == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Add a health measurement first.',
                  ),
                ),
              );

              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Overall health: ${HealthStatusHelper.label(analysis.overallStatus)}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}