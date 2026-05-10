import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  final bool isAdmin;
  const ProfileScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final prefix = isAdmin ? '/admin' : '/student';
    final name = isAdmin ? 'Admin User' : 'Anatoli Chala';
    final email = isAdmin ? 'admin@studysphere.com' : 'student@studysphere.com';
    final role = isAdmin ? 'Admin' : 'User';
    final initial = isAdmin ? 'A' : 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(initial,
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(height: 16),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(role,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  StatTile(
                    icon: Icons.upload_outlined,
                    iconColor: AppColors.primary,
                    value: isAdmin ? '0' : '1',
                    label: 'Uploads',
                  ),
                  const SizedBox(width: 10),
                  StatTile(
                    icon: Icons.bookmark_outline,
                    iconColor: AppColors.primary,
                    value: isAdmin ? '2' : '1',
                    label: 'Saved',
                  ),
                  const SizedBox(width: 10),
                  StatTile(
                    icon: Icons.star_outline,
                    iconColor: AppColors.starColor,
                    value: isAdmin ? '0' : '1',
                    label: 'Reviews',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Admin Panel (admin only)
              if (isAdmin) ...[
                GestureDetector(
                  onTap: () => context.go('/admin/panel/resources'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined,
                            size: 20, color: AppColors.primary),
                        SizedBox(width: 12),
                        Text('Admin Panel',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Account Settings Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Settings',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    _SettingsItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () => context.go('$prefix/profile/edit'),
                    ),
                    _SettingsItem(
                      icon: Icons.settings_outlined,
                      label: 'Preferences',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _SettingsItem(
                      icon: Icons.logout,
                      label: 'Log Out',
                      textColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: () => context.go('/login'),
                    ),
                    if (!isAdmin) ...[
                      const SizedBox(height: 6),
                      _SettingsItem(
                        icon: Icons.delete_outline,
                        label: 'Delete Account',
                        textColor: AppColors.error,
                        iconColor: AppColors.error,
                        onTap: () => _showDeleteDialog(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'Are you sure you want to delete this account?',
          style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.lightGrey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    overlayColor: AppColors.lightGrey.withOpacity(0.1),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    overlayColor: AppColors.white.withOpacity(0.2),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 14, color: textColor ?? AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
