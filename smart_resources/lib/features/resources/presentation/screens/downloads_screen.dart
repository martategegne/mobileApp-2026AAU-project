import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloads = [
      {
        'title': 'Advanced Calculus Notes',
        'description': 'Complete guide to limits, derivatives, and integration techniques with',
        'time': 'Downloaded 2 days ago',
        'rating': 5.0,
        'reviewCount': 1,
        'uses': 69,
        'isStarred': true,
      },
      {
        'title': 'Data Structures Masterc...',
        'description': 'Arrays, linked lists, trees, graphs, and algorithms visual explanations.',
        'time': 'Downloaded 2 days ago',
        'rating': 5.0,
        'reviewCount': 1,
        'uses': 156,
        'isStarred': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('My Downloads',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ),
                  const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('User',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: downloads.length,
                itemBuilder: (context, i) {
                  final d = downloads[i];
                  return Container(
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(d['title'] as String,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary)),
                                      ),
                                      Text(d['time'] as String,
                                          style: const TextStyle(
                                              fontSize: 10, color: AppColors.mediumGrey)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(d['description'] as String,
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...List.generate(
                                5,
                                (j) => Icon(
                                      j < (d['rating'] as double)
                                          ? Icons.star
                                          : Icons.star_outline,
                                      size: 13,
                                      color: AppColors.starColor,
                                    )),
                            const SizedBox(width: 6),
                            Text('${d['rating']} (${d['reviewCount']} reviews)',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.download_outlined,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${d['uses']}  uses',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary)),
                            const Spacer(),
                            Icon(Icons.bookmark_outline,
                                size: 18, color: AppColors.mediumGrey),
                            const SizedBox(width: 8),
                            Icon(
                              (d['isStarred'] as bool) ? Icons.star : Icons.star_outline,
                              size: 18,
                              color: (d['isStarred'] as bool)
                                  ? AppColors.starColor
                                  : AppColors.mediumGrey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}