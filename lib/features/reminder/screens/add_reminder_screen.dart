  import 'package:flutter/material.dart';
  import 'package:smart_health_tracker/features/reminder/services/notification_service.dart';
  import 'package:smart_health_tracker/app/theme/app_colors.dart';
  import 'package:smart_health_tracker/app/theme/app_spacing.dart';
  import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
  import 'package:smart_health_tracker/features/health/database/health_database.dart';
  import 'package:smart_health_tracker/features/reminder/models/health_reminder.dart';
  import 'package:smart_health_tracker/features/reminder/services/notification_service.dart';
  class AddReminderScreen extends StatefulWidget {
    final HealthReminder? reminder;

    const AddReminderScreen({
      super.key,
      this.reminder,
    });

    @override
    State<AddReminderScreen> createState() =>
        _AddReminderScreenState();
  }

  class _AddReminderScreenState
      extends State<AddReminderScreen> {
    final _formKey = GlobalKey<FormState>();

    final _titleController =
    TextEditingController();

    String _selectedType = 'Blood Pressure';

    TimeOfDay _selectedTime =
    const TimeOfDay(
      hour: 8,
      minute: 0,
    );

    bool _enabled = true;
    bool _isSaving = false;

    @override
    void initState() {
      super.initState();

      _loadReminder();
    }

    void _loadReminder() {
      final reminder = widget.reminder;

      if (reminder == null) {
        return;
      }

      _titleController.text =
          reminder.title;

      _selectedType =
          reminder.type;

      _selectedTime = TimeOfDay(
        hour: reminder.hour,
        minute: reminder.minute,
      );

      _enabled =
          reminder.enabled;
    }

    @override
    void dispose() {
      _titleController.dispose();

      super.dispose();
    }

    // ============================================================
    // SAVE
    // ============================================================

    Future<void> _saveReminder() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      final title = _titleController.text.trim();

      final reminder = HealthReminder(
        id: widget.reminder?.id,
        title: title,
        type: _selectedType,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        enabled: _enabled,
      );

      setState(() {
        _isSaving = true;
      });

      try {
        int reminderId;

        if (widget.reminder == null) {
          reminderId =
          await HealthDatabase.instance.insertReminder(
            reminder.toMap(),
          );
        } else {
          reminderId = widget.reminder!.id!;

          await HealthDatabase.instance.updateReminder(
            reminderId,
            reminder.toMap(),
          );
        }

        // Update notification
        await NotificationService.instance.cancelReminder(
          reminderId,
        );

// Schedule lại nếu reminder đang bật
        if (_enabled) {
          await NotificationService.instance.scheduleReminder(
            id: reminderId,
            title: reminder.title,
            type: reminder.type,
            hour: reminder.hour,
            minute: reminder.minute,
          );
        }
        // Check scheduled notifications
        await NotificationService.instance
            .checkPendingNotifications();

        if (!mounted) return;

        Navigator.pop(
          context,
          true,
        );
      } catch (e) {
        debugPrint(
          'Failed to save reminder: $e',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to save reminder.',
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

    // ============================================================
    // TIME PICKER
    // ============================================================

    Future<void> _selectTime() async {
      final time =
      await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (time == null) {
        return;
      }

      setState(() {
        _selectedTime = time;
      });
    }

    // ============================================================
    // BUILD
    // ============================================================

    @override
    Widget build(BuildContext context) {
      final isEditing =
          widget.reminder != null;

      return Scaffold(
        backgroundColor:
        AppColors.background,

        appBar: AppBar(
          backgroundColor:
          AppColors.background,
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
            isEditing
                ? 'Edit Reminder'
                : 'Add Reminder',
          ),
        ),

        body: SafeArea(
          child: Form(
            key: _formKey,

            child: SingleChildScrollView(
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

                  _buildSectionTitle(
                    'Reminder Information',
                  ),

                  const SizedBox(height: 12),

                  _buildTitleField(),

                  const SizedBox(height: 14),

                  _buildTypeDropdown(),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  _buildSectionTitle(
                    'Reminder Time',
                  ),

                  const SizedBox(height: 12),

                  _buildTimePicker(),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  _buildEnabledSwitch(),

                  const SizedBox(height: 32),

                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ============================================================
    // HEADER
    // ============================================================

    Widget _buildHeader() {
      final isEditing =
          widget.reminder != null;

      return Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            isEditing
                ? 'Edit your reminder'
                : 'Create a reminder',
            style: AppTextStyles.greeting,
          ),

          const SizedBox(height: 6),

          Text(
            isEditing
                ? 'Update your reminder details below.'
                : 'Set a reminder to help you track your health.',
            style: AppTextStyles.caption,
          ),
        ],
      );
    }

    // ============================================================
    // SECTION TITLE
    // ============================================================

    Widget _buildSectionTitle(
        String title,
        ) {
      return Text(
        title,
        style: AppTextStyles.sectionTitle,
      );
    }

    // ============================================================
    // TITLE
    // ============================================================

    Widget _buildTitleField() {
      return TextFormField(
        controller: _titleController,

        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        decoration: InputDecoration(
          labelText: 'Reminder Name',
          hintText:
          'e.g. Morning blood pressure',

          prefixIcon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
          ),

          filled: true,
          fillColor: AppColors.surface,

          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
          ),

          hintStyle: const TextStyle(
            color: AppColors.textMuted,
          ),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide:
            const BorderSide(
              color: AppColors.border,
            ),
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide:
            const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide:
            const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),

        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Please enter reminder name';
          }

          return null;
        },
      );
    }

    // ============================================================
    // TYPE
    // ============================================================

    Widget _buildTypeDropdown() {
      return DropdownButtonFormField<String>(
        initialValue: _selectedType,

        decoration: InputDecoration(
          labelText: 'Health Type',

          prefixIcon: const Icon(
            Icons.monitor_heart_outlined,
            color: AppColors.primary,
          ),

          filled: true,
          fillColor: AppColors.surface,

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide:
            const BorderSide(
              color: AppColors.border,
            ),
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide:
            const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide:
            const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),

        items: const [
          DropdownMenuItem(
            value: 'Blood Pressure',
            child: Text(
              'Blood Pressure',
            ),
          ),
          DropdownMenuItem(
            value: 'Heart Rate',
            child: Text(
              'Heart Rate',
            ),
          ),
          DropdownMenuItem(
            value: 'Blood Glucose',
            child: Text(
              'Blood Glucose',
            ),
          ),
          DropdownMenuItem(
            value: 'General',
            child: Text(
              'General',
            ),
          ),
        ],

        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _selectedType = value;
          });
        },
      );
    }

    // ============================================================
    // TIME
    // ============================================================

    Widget _buildTimePicker() {
      return InkWell(
        onTap: _selectTime,
        borderRadius:
        BorderRadius.circular(14),

        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),

          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.primary,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  _formatTime(
                    _selectedTime,
                  ),
                  style: const TextStyle(
                    color:
                    AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color:
                AppColors.textSecondary,
              ),
            ],
          ),
        ),
      );
    }

    // ============================================================
    // ENABLED
    // ============================================================

    Widget _buildEnabledSwitch() {
      return Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),

        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder enabled',
                    style: TextStyle(
                      color:
                      AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'You can turn this reminder on or off.',
                    style:
                    AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            Switch(
              value: _enabled,
              onChanged: (value) {
                setState(() {
                  _enabled = value;
                });
              },
              activeThumbColor:
              AppColors.primary,
            ),
          ],
        ),
      );
    }

    // ============================================================
    // SAVE BUTTON
    // ============================================================

    Widget _buildSaveButton() {
      final isEditing =
          widget.reminder != null;

      return SizedBox(
        width: double.infinity,
        height: 54,

        child: ElevatedButton(
          onPressed:
          _isSaving
              ? null
              : _saveReminder,

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
              : Text(
            isEditing
                ? 'Save Changes'
                : 'Save Reminder',
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
      );
    }

    // ============================================================
    // FORMAT TIME
    // ============================================================

    String _formatTime(
        TimeOfDay time,
        ) {
      final hour =
      time.hour.toString().padLeft(
        2,
        '0',
      );

      final minute =
      time.minute.toString().padLeft(
        2,
        '0',
      );

      return '$hour:$minute';
    }
  }