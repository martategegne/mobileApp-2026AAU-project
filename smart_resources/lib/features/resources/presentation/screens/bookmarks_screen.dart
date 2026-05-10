import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: [
                  Icon(Icons.bookmark_outline,
                      color: AppColors.primary, size: 22),
                  SizedBox(width: 10),
                  Text('Saved Resources',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _BookmarkCard(
                    title: 'Advanced Calculus Notes',
                    description:
                        'Complete guide to limits, derivatives, and integration techniques with solved problems.',
                    courseCode: 'MATH201',
                    rating: 5.0,
                    reviewCount: 1,
                    uses: 89,
                    isBookmarked: true,
                    isStarred: true,
                    onTap: () => context.go('/student/resources/1'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final String title;
  final String description;
  final String courseCode;
  final double rating;
  final int reviewCount;
  final int uses;
  final bool isBookmarked;
  final bool isStarred;
  final VoidCallback onTap;

  const _BookmarkCard({
    required this.title,
    required this.description,
    required this.courseCode,
    required this.rating,
    required this.reviewCount,
    required this.uses,
    required this.isBookmarked,
    required this.isStarred,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                const Icon(Icons.menu_book_outlined,
                    color: AppColors.mediumGrey, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tagBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(courseCode,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(
                    5,
                    (i) => Icon(
                          i < rating ? Icons.star : Icons.star_outline,
                          size: 14,
                          color: AppColors.starColor,
                        )),
                const SizedBox(width: 6),
                Text('$rating ($reviewCount reviews)',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.download_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('$uses  uses',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                Icon(Icons.bookmark,
                    size: 18,
                    color: isBookmarked
                        ? AppColors.warning
                        : AppColors.mediumGrey),
                const SizedBox(width: 8),
                Icon(Icons.star,
                    size: 18,
                    color:
                        isStarred ? AppColors.starColor : AppColors.mediumGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}