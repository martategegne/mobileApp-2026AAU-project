import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/resources/data/models/resource_model.dart';
import 'package:smart_resources/features/resources/presentation/providers/resource_notifier.dart';

class ResourceCard extends ConsumerWidget {
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final double rating;
  final int reviewCount;
  final int uses;
  final String fileType;
  final String uploader;
  final bool isAdmin;
  final bool isBookmarked;
  final bool isStarred; // mapped to isDownloaded
  final String? filePath;

  const ResourceCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.rating,
    required this.reviewCount,
    required this.uses,
    required this.fileType,
    required this.uploader,
    required this.isAdmin,
    this.isBookmarked = false,
    this.isStarred = false,
    this.filePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefix = isAdmin ? '/admin' : '/student';
    final currentUser = ref.watch(authNotifierProvider).user;
    final isOwner = currentUser?.name == uploader;

    return GestureDetector(
      onTap: () => context.go('$prefix/resources/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_outlined, color: theme.textTheme.bodySmall?.color?.withOpacity(0.75), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(courseCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StarRating(rating: rating),
                const SizedBox(width: 6),
                Text(
                  rating > 0 ? '${rating.toStringAsFixed(1)} ($reviewCount reviews)' : 'No ratings yet',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.download_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text('$uses uses', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                const Spacer(),
                if (isAdmin || isOwner) ...[
                  _IconBtn(
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: isBookmarked ? AppColors.warning : null,
                    onTap: () => ref.read(resourceNotifierProvider.notifier).toggleBookmark(id, !isBookmarked),
                  ),
                  _IconBtn(
                    icon: isStarred ? Icons.file_download_done : Icons.download_for_offline_outlined,
                    color: isStarred ? AppColors.success : null,
                    onTap: () => ref.read(resourceNotifierProvider.notifier).markDownloaded(id),
                  ),
                  _IconBtn(
                    icon: Icons.delete_outline,
                    color: AppColors.error,
                    onTap: () => _showDeleteDialog(context, ref),
                  ),
                ] else ...[
                  _IconBtn(
                      icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked ? AppColors.warning : null,
                      onTap: () => ref.read(resourceNotifierProvider.notifier).toggleBookmark(id, !isBookmarked)),
                  _IconBtn(
                      icon: isStarred ? Icons.file_download_done : Icons.download_for_offline_outlined,
                      color: isStarred ? AppColors.success : null,
                      onTap: () => ref.read(resourceNotifierProvider.notifier).markDownloaded(id)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(resourceNotifierProvider.notifier).deleteResource(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(icon, size: 18, color: color ?? Theme.of(context).iconTheme.color),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating.floor() ? Icons.star : (i < rating ? Icons.star_half : Icons.star_outline),
          size: 14,
          color: AppColors.starColor,
        );
      }),
    );
  }
}
