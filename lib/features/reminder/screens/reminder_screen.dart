import 'package:flutter/material.dart';
import 'package:smart_health_tracker/features/reminder/services/notification_service.dart';
import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_spacing.dart';
import 'package:smart_health_tracker/features/reminder/services/notification_service.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/features/reminder/models/health_reminder.dart';
import 'package:smart_health_tracker/features/reminder/screens/add_reminder_screen.dart';
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({
    super.key,
  });

  @override
  State<ReminderScreen> createState() =>
      _ReminderScreenState();
}

class _ReminderScreenState
    extends State<ReminderScreen> {
  late Future<List<HealthReminder>> _reminders;

  @override
  void initState() {
    super.initState();

    _loadReminders();
  }

  void _loadReminders() {
    _reminders =
        HealthDatabase.instance.getReminders();
  }

  Future<void> _deleteReminder(
      HealthReminder reminder,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Reminder',
          ),
          content: Text(
            'Are you sure you want to delete "${reminder.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
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

    if (confirm != true) {
      return;
    }

    try {
      await NotificationService.instance.cancelReminder(
        reminder.id!,
      );

      await HealthDatabase.instance.deleteReminder(
        reminder.id!,
      );

      if (!mounted) return;

      setState(() {
        _loadReminders();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reminder deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Failed to delete reminder: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete reminder.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleReminder(
      HealthReminder reminder,
      bool enabled,
      ) async {
    try {
      // Update database
      await HealthDatabase.instance.updateReminder(
        reminder.id!,
        {
          'enabled': enabled ? 1 : 0,
        },
      );

      // Cancel notification cũ trước
      await NotificationService.instance.cancelReminder(
        reminder.id!,
      );

      // Nếu bật → schedule lại
      if (enabled) {
        await NotificationService.instance.scheduleReminder(
          id: reminder.id!,
          title: reminder.title,
          type: reminder.type,
          hour: reminder.hour,
          minute: reminder.minute,
        );
      }

      if (!mounted) return;

      setState(() {
        _loadReminders();
      });
    } catch (e) {
      debugPrint(
        'Failed to update reminder: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update reminder.',
          ),
        ),
      );
    }
  }
  Future<void> _editReminder(
      HealthReminder reminder,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(
          reminder: reminder,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _loadReminders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Reminders',
        ),
      ),

      body: FutureBuilder<List<HealthReminder>>(
        future: _reminders,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load reminders.',
              ),
            );
          }

          final reminders =
              snapshot.data ?? [];

          if (reminders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              100,
            ),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder =
              reminders[index];

              return _buildReminderCard(
                reminder,
              );
            },
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const AddReminderScreen(),
            ),
          );

          if (result == true && mounted) {
            setState(() {
              _loadReminders();
            });
          }
        },
        backgroundColor:
        AppColors.primary,
        foregroundColor:
        AppColors.background,
        elevation: 0,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: AppColors.primary,
            ),

            const SizedBox(height: 16),

            const Text(
              'No reminders yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Create a reminder to help you '
                  'keep track of your health.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(
      HealthReminder reminder,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  reminder.type,
                  style:
                  AppTextStyles.caption,
                ),

                const SizedBox(height: 6),

                Text(
                  _formatTime(
                    reminder.hour,
                    reminder.minute,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Switch(
                value: reminder.enabled,
                onChanged: (value) {
                  _toggleReminder(
                    reminder,
                    value,
                  );
                },
                activeThumbColor:
                AppColors.primary,
              ),

              Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () {
                      _editReminder(reminder);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () {
                      _deleteReminder(
                        reminder,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(
      int hour,
      int minute,
      ) {
    final h =
    hour.toString().padLeft(2, '0');

    final m =
    minute.toString().padLeft(2, '0');

    return '$h:$m';
  }
}