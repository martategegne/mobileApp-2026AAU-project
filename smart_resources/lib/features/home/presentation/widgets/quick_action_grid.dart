import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuickActionGrid extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onUpload;
  final VoidCallback onRequest;
  final VoidCallback onBookmarks;
  final VoidCallback onSecondary;

  const QuickActionGrid({
    super.key,
    required this.isAdmin,
    required this.onUpload,
    required this.onRequest,
    required this.onBookmarks,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _ActionCard(
          icon: Icons.upload_outlined,
          iconColor: const Color.fromARGB(255, 12, 150, 74),
          title: 'Upload',
          subtitle: 'Share resources',
          onTap: onUpload,
        ),
        _ActionCard(
          icon: Icons.help_outline,
          iconColor: AppColors.warning,
          title: 'Request',
          subtitle: 'Ask for materials',
          onTap: onRequest,
        ),
        _ActionCard(
          icon: Icons.bookmark_outline,
          iconColor: const Color.fromARGB(255, 18, 95, 188),
          title: 'Bookmarks',
          subtitle: 'Saved resources',
          onTap: onBookmarks,
        ),
        _ActionCard(
          icon: isAdmin
              ? Icons.rate_review_outlined
              : Icons.download_for_offline_outlined,
          iconColor: const Color.fromARGB(255, 168, 70, 244),
          title: isAdmin ? 'Rate & Review' : 'Downloads',
          subtitle: isAdmin ? 'Feedback on resources' : 'Fetch downloads',
          onTap: onSecondary,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: iconColor, size: 35),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
