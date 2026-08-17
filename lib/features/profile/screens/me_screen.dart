import 'package:flutter/material.dart';
import 'package:smart_health_tracker/features/reminder/services/notification_service.dart';
import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_spacing.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/features/health/screens/health_threshold_screen.dart';
import 'package:smart_health_tracker/features/profile/screens/personal_information_screen.dart';
class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
      await HealthDatabase.instance.getUserProfile();

      if (!mounted) return;

      setState(() {
        if (profile != null && profile.name.trim().isNotEmpty) {
          _userName = profile.name;
        } else {
          _userName = 'Maya';
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load profile: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openPersonalInformation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const PersonalInformationScreen(),
      ),
    );

    if (!mounted) return;

    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Me'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildSectionTitle(
                'Health Profile',
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                subtitle:
                'Name, age, gender, height and weight',
                onTap: _openPersonalInformation,
              ),

              const SizedBox(height: 10),

              _buildInfoCard(
                icon: Icons.tune_rounded,
                title: 'Health Thresholds',
                subtitle: 'Set your health safety limits',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const HealthThresholdScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildSectionTitle(
                'Tools',
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.description_outlined,
                title: 'Health Report',
                subtitle:
                'View and export your health report',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await NotificationService.instance.showTestNotification();
                },
                child: const Text('Test Notification'),
              ),
              const SizedBox(height: 10),

              _buildInfoCard(
                icon: Icons.notifications_none_rounded,
                title: 'Reminders',
                subtitle:
                'Manage your health reminders',
                onTap: () {},
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildSectionTitle(
                'About',
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.info_outline_rounded,
                title: 'About Smart Health Tracker',
                subtitle:
                'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? 'Loading...' : _userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Your health profile',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
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
      ) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle,
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}