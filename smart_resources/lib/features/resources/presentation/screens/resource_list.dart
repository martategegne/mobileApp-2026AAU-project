import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import '../providers/resource_notifier.dart';
import '../widgets/resource_card.dart';

class ResourceList extends ConsumerStatefulWidget {
  final bool isAdmin;

  const ResourceList({super.key, required this.isAdmin});

  @override
  ConsumerState<ResourceList> createState() => _ResourceListState();
}

class _ResourceListState extends ConsumerState<ResourceList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.isAdmin ? '/admin' : '/student';
    final resourcesState = ref.watch(resourceNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Resources'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: 'Search by course code or keyword...',
                  prefixIcon: Icon(Icons.search,
                      color: theme.iconTheme.color, size: 20),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.menu_book_outlined,
                      size: 18, color: theme.textTheme.bodyLarge?.color),
                  const SizedBox(width: 8),
                  Text('All Resources',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => context.go('$prefix/upload'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: resourcesState.when(
                data: (resources) {
                  final filtered = resources.where((resource) {
                    if (_searchQuery.isEmpty) return true;
                    final lowerQuery = _searchQuery.toLowerCase();
                    return resource.title.toLowerCase().contains(lowerQuery) ||
                        resource.description.toLowerCase().contains(lowerQuery) ||
                        resource.courseCode.toLowerCase().contains(lowerQuery) ||
                        resource.uploader.toLowerCase().contains(lowerQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No resources match your search.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final resource = filtered[i];
                      return ResourceCard(
                        id: resource.id,
                        title: resource.title,
                        description: resource.description,
                        courseCode: resource.courseCode,
                        rating: resource.rating,
                        reviewCount: resource.reviewCount,
                        uses: resource.uses,
                        fileType: resource.fileType,
                        uploader: resource.uploader,
                        isAdmin: widget.isAdmin,
                        isBookmarked: resource.isBookmarked,
                        isStarred: resource.isDownloaded,
                        filePath: resource.filePath,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Failed to load resources. ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
