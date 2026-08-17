import 'package:flutter/material.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_spacing.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/features/health/models/health_measurement.dart';
class AddHealthMeasurementScreen extends StatefulWidget {
  final HealthMeasurement? measurement;

  const AddHealthMeasurementScreen({
    super.key,
    this.measurement,
  });

  @override
  State<AddHealthMeasurementScreen> createState() =>
      _AddHealthMeasurementScreenState();
}

class _AddHealthMeasurementScreenState
    extends State<AddHealthMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _measurementTime = DateTime.now();
  @override
  void initState() {
    super.initState();

    _loadMeasurement();
  }

  void _loadMeasurement() {
    final data = widget.measurement;

    if (data == null) {
      return;
    }

    _systolicController.text =
        data.systolic.toString();

    _diastolicController.text =
        data.diastolic.toString();

    _heartRateController.text =
        data.heartRate.toString();

    _glucoseController.text =
        data.bloodGlucose.toString();

    _noteController.text =
        data.note ?? '';

    _measurementTime = data.measuredAt;
  }
  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _glucoseController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: Text(
          widget.measurement == null
              ? 'Add Measurement'
              : 'Edit Measurement',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Blood Pressure',
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        controller: _systolicController,
                        label: 'Systolic',
                        hint: '120',
                        suffix: 'mmHg',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildNumberField(
                        controller: _diastolicController,
                        label: 'Diastolic',
                        hint: '80',
                        suffix: 'mmHg',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Heart Rate',
                ),

                const SizedBox(height: 12),

                _buildNumberField(
                  controller: _heartRateController,
                  label: 'Heart Rate',
                  hint: '72',
                  suffix: 'bpm',
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Blood Glucose',
                ),

                const SizedBox(height: 12),

                _buildNumberField(
                  controller: _glucoseController,
                  label: 'Blood Glucose',
                  hint: '5.2',
                  suffix: 'mmol/L',
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Measurement Time',
                ),

                const SizedBox(height: 12),

                _buildDateTimePicker(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Note',
                ),

                const SizedBox(height: 12),

                _buildNoteField(),

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
    final isEditing = widget.measurement != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing
              ? 'Edit your measurement'
              : 'Record your health',
          style: AppTextStyles.greeting,
        ),

        const SizedBox(height: 6),

        Text(
          isEditing
              ? 'Update your health measurements below.'
              : 'Enter your latest measurements below.',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: const TextInputType.numberWithOptions(
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
        suffixText: suffix,

        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textMuted,
        ),

        suffixStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),

        filled: true,
        fillColor: AppColors.surface,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }

        final number = double.tryParse(value.trim());

        if (number == null) {
          return 'Please enter a valid number';
        }

        if (label == 'Systolic') {
          if (number < 50 || number > 300) {
            return 'Enter a value between 50 and 300';
          }
        }

        if (label == 'Diastolic') {
          if (number < 30 || number > 200) {
            return 'Enter a value between 30 and 200';
          }
        }

        if (label == 'Heart Rate') {
          if (number < 20 || number > 250) {
            return 'Enter a value between 20 and 250';
          }
        }

        if (label == 'Blood Glucose') {
          if (number < 1 || number > 30) {
            return 'Enter a value between 1 and 30';
          }
        }

        return null;
      },
    );
  }

  Widget _buildDateTimePicker() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _selectDateTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 20,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                _formatDateTime(_measurementTime),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,

      maxLines: 3,

      style: const TextStyle(
        color: AppColors.textPrimary,
      ),

      decoration: InputDecoration(
        hintText: 'How are you feeling?',
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
        ),

        filled: true,
        fillColor: AppColors.surface,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveMeasurement,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          widget.measurement == null
              ? 'Save Measurement'
              : 'Save Changes',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _measurementTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _measurementTime,
      ),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _measurementTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final systolic =
    double.parse(_systolicController.text.trim());

    final diastolic =
    double.parse(_diastolicController.text.trim());

    final heartRate =
    double.parse(_heartRateController.text.trim());

    final bloodGlucose =
    double.parse(_glucoseController.text.trim());

    if (systolic <= diastolic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Systolic pressure must be higher than diastolic pressure.',
          ),
        ),
      );

      return;
    }

    final measurement = HealthMeasurement(
      // ⭐ Giữ ID cũ khi Edit
      id: widget.measurement?.id,
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      bloodGlucose: bloodGlucose,
      measuredAt: _measurementTime,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      if (widget.measurement == null) {
        // ========================================
        // CREATE - Thêm chỉ số mới
        // ========================================

        final id =
        await HealthDatabase.instance.insertMeasurement(
          measurement.toMap(),
        );

        debugPrint(
          'Measurement saved with ID: $id',
        );
      } else {
        // ========================================
        // UPDATE - Sửa chỉ số hiện tại
        // ========================================

        final result =
        await HealthDatabase.instance.updateMeasurement(
          widget.measurement!.id!,
          measurement.toMap(),
        );

        debugPrint(
          'Measurement updated. Rows affected: $result',
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

    } catch (e) {
      debugPrint(
        'Failed to save measurement: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save measurement.',
          ),
        ),
      );
    }
  }
  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }
}