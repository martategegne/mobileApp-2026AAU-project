import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/core/widgets/custom_button.dart';
import 'package:smart_resources/core/widgets/custom_text_field.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  const EditProfileScreen({super.key, required this.isAdmin});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).updateProfile(
          user.id,
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.isNotEmpty
              ? _passwordController.text
              : user.password,
        );

    final authState = ref.read(authNotifierProvider);
    if (authState.error == null) {
      if (mounted) {
        context.go(widget.isAdmin ? '/admin/profile' : '/student/profile');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final initial = (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),

                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Text(initial,
                          style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: 'Full Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: 'New Password (Optional)',
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: 'Confirm Password',
                    obscureText: true,
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Cancel',
                          isOutlined: true,
                          onPressed: () => context.go(
                            widget.isAdmin ? '/admin/profile' : '/student/profile',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Save',
                          onPressed: _saveProfile,
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
