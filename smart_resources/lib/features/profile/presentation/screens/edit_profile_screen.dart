import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class EditProfileScreen extends StatelessWidget {
  final bool isAdmin;
  const EditProfileScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final name = isAdmin ? 'Admin User' : 'Etagegn';
    final email = isAdmin ? 'admin@studysphere.com' : 'student@studysphere.com';
    final initial = isAdmin ? 'A' : 'E';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 20),

                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(initial,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Tap here to change profile',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        SizedBox(width: 4),
                        Icon(Icons.edit,
                            size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(hintText: name),
                  const SizedBox(height: 12),
                  CustomTextField(
                      hintText: email,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  const CustomTextField(
                      hintText: 'old password', obscureText: true),
                  const SizedBox(height: 12),
                  const CustomTextField(
                      hintText: 'new password', obscureText: true),
                  const SizedBox(height: 12),
                  const CustomTextField(
                      hintText: 'Confirm Password', obscureText: true),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Cancel',
                          isOutlined: true,
                          onPressed: () => context.go(
                            isAdmin ? '/admin/profile' : '/student/profile',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Save',
                          onPressed: () => context.go(
                            isAdmin ? '/admin/profile' : '/student/profile',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
