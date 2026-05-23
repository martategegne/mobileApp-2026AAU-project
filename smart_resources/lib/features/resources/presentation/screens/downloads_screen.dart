import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import '../providers/resource_notifier.dart';
import '../widgets/resource_card.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadedResourcesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Downloads'),
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
                  Icon(Icons.download_outlined,
                      color: AppColors.primary, size: 22),
                  SizedBox(width: 10),
                  Text('Downloaded Resources',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: downloadsAsync.when(
                data: (resources) {
                  if (resources.isEmpty) {
                    return const Center(child: Text('No downloaded resources yet.'));
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
