import 'package:flutter/material.dart';

import 'package:smart_health_tracker/app/theme/app_colors.dart';
import 'package:smart_health_tracker/app/theme/app_spacing.dart';
import 'package:smart_health_tracker/app/theme/app_text_styles.dart';
import 'package:smart_health_tracker/features/health/database/health_database.dart';
import 'package:smart_health_tracker/features/profile/models/user_profile.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({
    super.key,
  });

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;

  UserProfile? _profile;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final profile =
      await HealthDatabase.instance.getUserProfile();

      if (!mounted) return;

      if (profile != null) {
        _profile = profile;

        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _heightController.text = profile.height.toString();
        _weightController.text = profile.weight.toString();

        _selectedGender = profile.gender;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Failed to load profile: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load personal information.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your gender.',
          ),
        ),
      );

      return;
    }

    final name = _nameController.text.trim();
    final age = int.parse(
      _ageController.text.trim(),
    );
    final height = double.parse(
      _heightController.text.trim(),
    );
    final weight = double.parse(
      _weightController.text.trim(),
    );

    final profile = UserProfile(
      id: _profile?.id,
      name: name,
      age: age,
      gender: _selectedGender!,
      height: height,
      weight: weight,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      if (_profile == null) {
        final id =
        await HealthDatabase.instance
            .insertUserProfile(
          profile.toMap(),
        );

        _profile = UserProfile(
          id: id,
          name: profile.name,
          age: profile.age,
          gender: profile.gender,
          height: profile.height,
          weight: profile.weight,
        );
      } else {
        await HealthDatabase.instance
            .updateUserProfile(
          _profile!.id!,
          profile.toMap(),
        );

        _profile = profile;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Personal information saved successfully.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Failed to save profile: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save personal information.',
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
  // BUILD
  // ============================================================

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

        title: const Text(
          'Personal Information',
        ),
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
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
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                _buildHeader(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Basic Information',
                ),

                const SizedBox(
                  height: 12,
                ),

                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 14),

                _buildNumberField(
                  controller: _ageController,
                  label: 'Age',
                  hint: '20',
                  suffix: 'years',
                ),

                const SizedBox(height: 14),

                _buildGenderDropdown(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Body Information',
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        controller:
                        _heightController,
                        label: 'Height',
                        hint: '165',
                        suffix: 'cm',
                        decimal: true,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildNumberField(
                        controller:
                        _weightController,
                        label: 'Weight',
                        hint: '55',
                        suffix: 'kg',
                        decimal: true,
                      ),
                    ),
                  ],
                ),

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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: AppTextStyles.greeting,
        ),

        const SizedBox(height: 6),

        Text(
          'Keep your health profile up to date.',
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
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,

      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
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
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
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
          return 'Please enter your name';
        }

        return null;
      },
    );
  }

  // ============================================================
  // NUMBER FIELD
  // ============================================================

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    bool decimal = false,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType:
      TextInputType.numberWithOptions(
        decimal: decimal,
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

        filled: true,
        fillColor: AppColors.surface,

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

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
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
          return 'Please enter $label';
        }

        final number = double.tryParse(
          value.trim(),
        );

        if (number == null) {
          return 'Please enter a valid number';
        }

        if (label == 'Age') {
          if (number < 1 || number > 120) {
            return 'Enter an age between 1 and 120';
          }
        }

        if (label == 'Height') {
          if (number < 50 || number > 250) {
            return 'Enter a height between 50 and 250 cm';
          }
        }

        if (label == 'Weight') {
          if (number < 10 || number > 300) {
            return 'Enter a weight between 10 and 300 kg';
          }
        }

        return null;
      },
    );
  }

  // ============================================================
  // GENDER
  // ============================================================

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,

      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(
          Icons.wc_outlined,
          color: AppColors.primary,
        ),

        filled: true,
        fillColor: AppColors.surface,

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),

      items: const [
        DropdownMenuItem(
          value: 'Male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'Female',
          child: Text('Female'),
        ),
        DropdownMenuItem(
          value: 'Other',
          child: Text('Other'),
        ),
      ],

      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },

      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return 'Please select your gender';
        }

        return null;
      },
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton(
        onPressed:
        _isSaving ? null : _saveProfile,

        style: ElevatedButton.styleFrom(
          backgroundColor:
          AppColors.primary,

          foregroundColor:
          AppColors.background,

          elevation: 0,

          shape: RoundedRectangleBorder(
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
          _profile == null
              ? 'Save Information'
              : 'Save Changes',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}