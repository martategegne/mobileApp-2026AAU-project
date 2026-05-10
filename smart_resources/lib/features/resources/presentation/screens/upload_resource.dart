import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/resource_card.dart';

class ResourceList extends StatelessWidget {
  final bool isAdmin;

  const ResourceList({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final prefix = isAdmin ? '/admin' : '/student';

    final resources = [
      {
        'id': '1',
        'title': 'Advanced Calculus Notes',
        'description':
            'Complete guide to limits, derivatives, and integration techniques with solved problems.',
        'courseCode': 'MATH201',
        'rating': 5.0,
        'reviewCount': 1,
        'uses': 89,
        'fileType': 'PDF',
      },
      {
        'id': '2',
        'title': 'Data Structures Masterclass',
        'description':
            'Arrays, linked lists, trees, graphs, and algorithms visual explanations.',
        'courseCode': 'CS301',
        'rating': 5.0,
        'reviewCount': 1,
        'uses': 156,
        'fileType': 'PDF',
      },
      {
        'id': '3',
        'title': 'Operating Systems Concepts',
        'description':
            'Process scheduling, memory management, file systems — university level.',
        'courseCode': 'CS340',
        'rating': 0.0,
        'reviewCount': 0,
        'uses': 42,
        'fileType': 'PDF',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by course code or keyword...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.mediumGrey, size: 20),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  const Text('All Resources',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: resources.length,
                itemBuilder: (context, i) {
                  final r = resources[i];
                  return ResourceCard(
                    id: r['id'] as String,
                    title: r['title'] as String,
                    description: r['description'] as String,
                    courseCode: r['courseCode'] as String,
                    rating: r['rating'] as double,
                    reviewCount: r['reviewCount'] as int,
                    uses: r['uses'] as int,
                    fileType: r['fileType'] as String,
                    isAdmin: isAdmin,
                    isBookmarked: i == 0,
                    isStarred: i == 0,
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