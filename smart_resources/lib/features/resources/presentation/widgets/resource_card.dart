import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ResourceCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final double rating;
  final int reviewCount;
  final int uses;
  final String fileType;
  final bool isAdmin;
  final bool isBookmarked;
  final bool isStarred;

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
    required this.isAdmin,
    this.isBookmarked = false,
    this.isStarred = false,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = isAdmin ? '/admin' : '/student';
    return GestureDetector(
      onTap: () => context.go('$prefix/resources/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_outlined, color: AppColors.mediumGrey, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tagBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(courseCode,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StarRating(rating: rating),
                const SizedBox(width: 6),
                Text(
                  rating > 0 ? '$rating ($reviewCount reviews)' : 'No ratings yet',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.download_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('$uses  uses', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                if (isAdmin) ...[
                  _IconBtn(icon: Icons.bookmark_outline, onTap: () {}),
                  _IconBtn(icon: Icons.star_outline, onTap: () {}),
                  _IconBtn(icon: Icons.edit_outlined, onTap: () {}),
                  _IconBtn(icon: Icons.delete_outline, color: AppColors.error, onTap: () {}),
                ] else ...[
                  _IconBtn(
                      icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked ? AppColors.warning : null,
                      onTap: () {}),
                  _IconBtn(
                      icon: isStarred ? Icons.star : Icons.star_outline,
                      color: isStarred ? AppColors.starColor : null,
                      onTap: () {}),
                ],
              ],
            ),
          ],
        ),
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
        child: Icon(icon, size: 18, color: color ?? AppColors.mediumGrey),
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