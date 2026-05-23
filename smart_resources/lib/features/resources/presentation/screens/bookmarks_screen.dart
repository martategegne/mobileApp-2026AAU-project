import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import '../providers/resource_notifier.dart';
import '../widgets/resource_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedResourcesProvider);

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: [
                  Icon(Icons.bookmark_outline,
                      color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('Saved Resources',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: bookmarksAsync.when(
                data: (resources) {
                  if (resources.isEmpty) {
                    return const Center(child: Text('No saved resources yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      return ResourceCard(
                        id: resource.id,
                        title: resource.title,
                        description: resource.description,
                        courseCode: resource.courseCode,
                        rating: resource.rating,
                        reviewCount: resource.reviewCount,
                        uses: resource.uses,
                        fileType: resource.fileType,
                        uploader: resource.uploader, // Added missing uploader
                        isAdmin: false,
                        isBookmarked: resource.isBookmarked,
                        isStarred: resource.isDownloaded,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
