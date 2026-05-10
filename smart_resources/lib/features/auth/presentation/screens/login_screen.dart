import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/role_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
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
                  // Logo
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width:
                              MediaQuery.of(context).size.width > 600 ? 40 : 32,
                          height:
                              MediaQuery.of(context).size.width > 600 ? 40 : 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.school,
                              color: AppColors.white,
                              size: MediaQuery.of(context).size.width > 600
                                  ? 22
                                  : 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'StudySphere',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 600
                                ? 20
                                : 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Access your learning ecosystem',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                AppColors.lightGrey.withOpacity(0.3),
                            side: const BorderSide(color: AppColors.lightGrey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            overlayColor:
                                AppColors.primaryDark.withOpacity(0.1),
                          ),
                          child: const Text('Login',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/signup'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.lightGrey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            overlayColor:
                                AppColors.primaryDark.withOpacity(0.1),
                          ),
                          child: const Text('Sign Up',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const CustomTextField(
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  const CustomTextField(
                      hintText: 'Password', obscureText: true),
                  const SizedBox(height: 16),

                  RoleSelector(
                    selectedRole: _selectedRole,
                    onChanged: (role) => setState(() => _selectedRole = role),
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    label: 'Sign In',
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    onPressed: () {
                      if (_selectedRole == 'Admin') {
                        context.go('/admin/home');
                      } else {
                        context.go('/student/home');
                      }
                    },
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
