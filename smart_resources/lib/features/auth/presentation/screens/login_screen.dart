import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_notifier.dart';
import '../widgets/role_selector.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'User';

  // Field error states
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final emailRegex = RegExp(r'^[^\@\s]+@[^\@\s]+\.[^\@\s]+$');

    String? emailErr;
    String? passErr;

    if (email.isEmpty) {
      emailErr = 'Email is required.';
    } else if (!emailRegex.hasMatch(email)) {
      emailErr = 'Please enter a valid email address.';
    }

    if (password.isEmpty) {
      passErr = 'Password is required.';
    } else if (password.length < 6) {
      passErr = 'Password must be at least 6 characters.';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  Future<void> _signIn() async {
    if (!_validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await ref.read(authNotifierProvider.notifier).login(email, password, _selectedRole);

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.error != null) {
      setState(() {
        _emailError = 'Invalid email or password.';
        _passwordError = 'Invalid email or password.';
      });
      return;
    }

    if (authState.user?.isAdmin ?? false) {
      context.go('/admin/home');
    } else {
      context.go('/student/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final surfaceColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurface.withOpacity(0.75);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.35)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width > 600 ? 40 : 32,
                          height: MediaQuery.of(context).size.width > 600 ? 40 : 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.school,
                              color: AppColors.white,
                              size: MediaQuery.of(context).size.width > 600 ? 22 : 18),
                        ),
                        const SizedBox(width: 10),
                        Text('StudySphere',
                            style: theme.textTheme.titleLarge?.copyWith(color: textColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text('Welcome back',
                        style: theme.textTheme.headlineMedium?.copyWith(color: textColor)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Access your learning ecosystem',
                        style: theme.textTheme.bodyMedium?.copyWith(color: secondaryText)),
                  ),
                  const SizedBox(height: 24),
                  // Login / Sign Up toggle
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                            side: const BorderSide(color: AppColors.lightGrey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Login',
                              style: TextStyle(
                                  color: textColor, fontWeight: FontWeight.w600)),
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
                          ),
                          child: Text('Sign Up',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  _ValidatedField(
                    key: const Key('email_field'),
                    controller: _emailController,
                    hintText: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password field
                  _ValidatedField(
                    key: const Key('password_field'),
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),

                  RoleSelector(
                    selectedRole: _selectedRole,
                    onChanged: (role) => setState(() => _selectedRole = role),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    key: const Key('login_button'),
                    label: authState.isLoading ? 'Signing in...' : 'Sign In',
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    onPressed: authState.isLoading ? null : _signIn,
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

class _ValidatedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const _ValidatedField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          cursorColor: theme.colorScheme.primary,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
            filled: true,
            fillColor: hasError
                ? Colors.red.withOpacity(0.05)
                : theme.inputDecorationTheme.fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : theme.dividerColor,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade600 : theme.colorScheme.primary,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
