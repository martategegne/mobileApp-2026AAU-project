import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/rating_section.dart';

class ResourceDetails extends StatelessWidget {
  final String resourceId;
  final bool isAdmin;

  const ResourceDetails({super.key, required this.resourceId, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(isAdmin ? '/admin/resources' : '/student/resources'),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.bookmark_outline, color: AppColors.textPrimary),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.tagBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('CS101',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 8),
                        const Text('Study Guides',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('CS101 Midterm Study Guide',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    // Star rating
                    Row(
                      children: [
                        ...List.generate(
                            5,
                            (i) => Icon(
                                  i < 4 ? Icons.star : Icons.star_half,
                                  color: AppColors.starColor,
                                  size: 18,
                                )),
                        const SizedBox(width: 6),
                        const Text('4.8  (12)',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comprehensive study guide covering chapters 1-5, including practice problems for algorithms and data structures.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    // Meta info
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.mediumGrey),
                        const SizedBox(width: 6),
                        const Text('Alem Abebe',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 20),
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.mediumGrey),
                        const SizedBox(width: 6),
                        const Text('2023-10-15',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.description_outlined,
                            size: 16, color: AppColors.mediumGrey),
                        const SizedBox(width: 6),
                        const Text('PDF',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Download Resource',
                      icon: const Icon(Icons.download_outlined, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your download have started!',
                                style: TextStyle(color: AppColors.success)),
                            backgroundColor: AppColors.white,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const RatingSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}