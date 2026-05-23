import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/widgets/custom_button.dart';
import '../providers/resource_notifier.dart';
import '../widgets/rating_section.dart';
import '../../../../core/theme/app_colors.dart';

class ResourceDetails extends ConsumerWidget {
  final String resourceId;
  final bool isAdmin;

  const ResourceDetails(
      {super.key, required this.resourceId, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceState = ref.watch(resourceDetailsProvider(resourceId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: resourceState.when(
          data: (resource) {
            if (resource == null) {
              return const Center(child: Text('Resource not found.'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(isAdmin ? '/admin/resources' : '/student/resources'),
                        child: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          ref.read(resourceNotifierProvider.notifier).toggleBookmark(resource.id, !resource.isBookmarked);
                        },
                        child: Icon(
                          resource.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          color: resource.isBookmarked ? theme.colorScheme.secondary : theme.iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.tagBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(resource.courseCode,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 8),
                            Text(resource.fileType,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(resource.title,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < resource.rating.floor() ? Icons.star : (i < resource.rating ? Icons.star_half : Icons.star_outline),
                              color: AppColors.starColor,
                              size: 18,
                            )),
                            const SizedBox(width: 6),
                            Text('${resource.rating.toStringAsFixed(1)} (${resource.reviewCount})',
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(resource.description,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, height: 1.5)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: theme.textTheme.bodySmall?.color),
                            const SizedBox(width: 6),
                            Text(resource.uploader,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                            const SizedBox(width: 20),
                            Icon(Icons.calendar_today_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                            const SizedBox(width: 6),
                            Text('Recently', style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          label: 'Download Resource',
                          icon: const Icon(Icons.download_outlined, size: 18),
                          onPressed: () {
                            ref.read(resourceNotifierProvider.notifier).markDownloaded(resource.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started!')));
                          },
                        ),
                        const SizedBox(height: 28),
                        RatingSection(resourceId: resource.id),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}
