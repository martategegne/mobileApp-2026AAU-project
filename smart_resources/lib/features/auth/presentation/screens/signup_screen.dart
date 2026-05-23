import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_notifier.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Field error states
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final emailRegex = RegExp(r'^[^\@\s]+@[^\@\s]+\.[^\@\s]+$');

    String? nameErr;
    String? emailErr;
    String? passErr;
    String? confirmErr;

    if (name.isEmpty) nameErr = 'Full name is required.';

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

    if (confirm.isEmpty) {
      confirmErr = 'Please confirm your password.';
    } else if (confirm != password) {
      confirmErr = 'Passwords do not match.';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });

    return nameErr == null && emailErr == null && passErr == null && confirmErr == null;
  }

  Future<void> _createAccount() async {
    if (!_validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref.read(authNotifierProvider.notifier).signup(name, email, password);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authNotifierProvider).error ?? 'Sign up failed. Please try again.';
      setState(() {
        _emailError = error;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully. Welcome!'),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/student/home');
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
                            color: AppColors.primary,
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
                    child: Text('Create account',
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
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Login',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Sign Up',
                              style: TextStyle(
                                  color: textColor, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  _ValidatedField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _ValidatedField(
                    controller: _emailController,
                    hintText: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  _ValidatedField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password
                  _ValidatedField(
                    controller: _confirmController,
                    hintText: 'Confirm Password',
                    obscureText: _obscureConfirm,
                    errorText: _confirmError,
                    onChanged: (_) {
                      if (_confirmError != null) setState(() => _confirmError = null);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    label: authState.isLoading ? 'Creating account...' : 'Create Account',
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    onPressed: authState.isLoading ? null : _createAccount,
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
              Flexible(
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
