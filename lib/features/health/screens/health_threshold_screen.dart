import 'package:flutter/material.dart';

import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_spacing.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/features/health/analysis/health_threshold.dart';

class HealthThresholdScreen extends StatefulWidget {
  const HealthThresholdScreen({
    super.key,
  });

  @override
  State<HealthThresholdScreen> createState() =>
      _HealthThresholdScreenState();
}

class _HealthThresholdScreenState
    extends State<HealthThresholdScreen> {
  final _formKey = GlobalKey<FormState>();

  final _heartRateMinController =
  TextEditingController();

  final _heartRateMaxController =
  TextEditingController();

  final _systolicMinController =
  TextEditingController();

  final _systolicMaxController =
  TextEditingController();

  final _diastolicMinController =
  TextEditingController();

  final _diastolicMaxController =
  TextEditingController();

  final _glucoseMinController =
  TextEditingController();

  final _glucoseMaxController =
  TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadThreshold();
  }

  Future<void> _loadThreshold() async {
    try {
      final threshold =
      await HealthDatabase.instance
          .getHealthThreshold();

      final value = threshold ??
          HealthThreshold.defaultThreshold;

      _heartRateMinController.text =
          value.heartRateMin.toString();

      _heartRateMaxController.text =
          value.heartRateMax.toString();

      _systolicMinController.text =
          value.systolicMin.toString();

      _systolicMaxController.text =
          value.systolicMax.toString();

      _diastolicMinController.text =
          value.diastolicMin.toString();

      _diastolicMaxController.text =
          value.diastolicMax.toString();

      _glucoseMinController.text =
          value.glucoseMin.toString();

      _glucoseMaxController.text =
          value.glucoseMax.toString();
    } catch (e) {
      debugPrint(
        'Failed to load health threshold: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveThreshold() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final heartRateMin =
    double.parse(
      _heartRateMinController.text.trim(),
    );

    final heartRateMax =
    double.parse(
      _heartRateMaxController.text.trim(),
    );

    final systolicMin =
    double.parse(
      _systolicMinController.text.trim(),
    );

    final systolicMax =
    double.parse(
      _systolicMaxController.text.trim(),
    );

    final diastolicMin =
    double.parse(
      _diastolicMinController.text.trim(),
    );

    final diastolicMax =
    double.parse(
      _diastolicMaxController.text.trim(),
    );

    final glucoseMin =
    double.parse(
      _glucoseMinController.text.trim(),
    );

    final glucoseMax =
    double.parse(
      _glucoseMaxController.text.trim(),
    );

    if (heartRateMin >= heartRateMax ||
        systolicMin >= systolicMax ||
        diastolicMin >= diastolicMax ||
        glucoseMin >= glucoseMax) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Minimum value must be smaller than maximum value.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final threshold = HealthThreshold(
        heartRateMin: heartRateMin,
        heartRateMax: heartRateMax,
        systolicMin: systolicMin,
        systolicMax: systolicMax,
        diastolicMin: diastolicMin,
        diastolicMax: diastolicMax,
        glucoseMin: glucoseMin,
        glucoseMax: glucoseMax,
      );

      await HealthDatabase.instance
          .saveHealthThreshold(
        threshold.toMap(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Health thresholds saved successfully.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        'Failed to save health threshold: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save health thresholds.',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _heartRateMinController.dispose();
    _heartRateMaxController.dispose();
    _systolicMinController.dispose();
    _systolicMaxController.dispose();
    _diastolicMinController.dispose();
    _diastolicMaxController.dispose();
    _glucoseMinController.dispose();
    _glucoseMaxController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        backgroundColor:
        AppColors.background,
        elevation: 0,
        title: const Text(
          'Health Thresholds',
        ),
      ),

      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : SafeArea(
        child: Form(
          key: _formKey,

          child:
          SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildHeartRateSection(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildBloodPressureSection(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildGlucoseSection(),

                const SizedBox(
                  height: 32,
                ),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Health Limits',
          style: AppTextStyles.greeting,
        ),

        const SizedBox(height: 6),

        Text(
          'Set your personal safety thresholds. '
              'These values will be used to analyze '
              'your health measurements.',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildHeartRateSection() {
    return _buildSection(
      title: 'Heart Rate',
      unit: 'bpm',
      minController:
      _heartRateMinController,
      maxController:
      _heartRateMaxController,
      minHint: '60',
      maxHint: '100',
    );
  }

  Widget _buildBloodPressureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Blood Pressure',
        ),

        const SizedBox(height: 6),

        Text(
          'Enter the safe range for blood pressure. '
              'Blood pressure is recorded as Systolic / Diastolic (mmHg).',
          style: AppTextStyles.caption,
        ),

        const SizedBox(height: 12),

        // Example
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.monitor_heart_rounded,
                size: 22,
                color: AppColors.primary,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Example: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '120 / 80 mmHg',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text:
                        '  →  Systolic / Diastolic',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Systolic
        _buildRangeRow(
          label: 'Systolic (Tâm thu)',
          unit: 'mmHg',
          minController:
          _systolicMinController,
          maxController:
          _systolicMaxController,
          minHint: '90',
          maxHint: '120',
        ),

        const SizedBox(height: 12),

        // Diastolic
        _buildRangeRow(
          label: 'Diastolic (Tâm trương)',
          unit: 'mmHg',
          minController:
          _diastolicMinController,
          maxController:
          _diastolicMaxController,
          minHint: '60',
          maxHint: '80',
        ),
      ],
    );
  }

  Widget _buildGlucoseSection() {
    return _buildSection(
      title: 'Blood Glucose',
      unit: 'mmol/L',
      minController:
      _glucoseMinController,
      maxController:
      _glucoseMaxController,
      minHint: '3.9',
      maxHint: '7.8',
    );
  }

  Widget _buildSection({
    required String title,
    required String unit,
    required TextEditingController
    minController,
    required TextEditingController
    maxController,
    required String minHint,
    required String maxHint,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),

        const SizedBox(height: 12),

        _buildRangeRow(
          label: 'Safe range',
          unit: unit,
          minController: minController,
          maxController: maxController,
          minHint: minHint,
          maxHint: maxHint,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle,
    );
  }

  Widget _buildRangeRow({
    required String label,
    required String unit,
    required TextEditingController
    minController,
    required TextEditingController
    maxController,
    String? minHint,
    String? maxHint,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            controller: minController,
            label: 'Minimum',
            hint: minHint,
            unit: unit,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildNumberField(
            controller: maxController,
            label: 'Maximum',
            hint: maxHint,
            unit: unit,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController
    controller,
    required String label,
    required String? hint,
    required String unit,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),

      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: unit,

        filled: true,
        fillColor: AppColors.surface,

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Required';
        }

        final number =
        double.tryParse(
          value.trim(),
        );

        if (number == null) {
          return 'Invalid';
        }

        if (number < 0) {
          return 'Invalid';
        }

        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
        _isSaving
            ? null
            : _saveThreshold,

        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          AppColors.primary,
          foregroundColor:
          AppColors.background,
          elevation: 0,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),

        child: _isSaving
            ? const SizedBox(
          width: 22,
          height: 22,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Save Thresholds',
          style: TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }
}