import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class CreateRequest extends StatelessWidget {
  final bool isAdmin;

  const CreateRequest({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(
                      isAdmin ? '/admin/requests' : '/student/requests',
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Text('Resource Requests',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New Request Form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New Request',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 14),
                          const CustomTextField(hintText: 'Request Title'),
                          const SizedBox(height: 10),
                          const CustomTextField(
                              hintText: 'Course Code (e.g. CS101)'),
                          const SizedBox(height: 10),
                          const CustomTextField(
                            hintText: 'What exactly are you looking for?',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: 'Submit',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Your request have been added!',
                                            style: TextStyle(
                                                color: AppColors.success)),
                                        backgroundColor: AppColors.white,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    context.go(
                                      isAdmin
                                          ? '/admin/requests'
                                          : '/student/requests',
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  label: 'Cancel',
                                  isOutlined: true,
                                  onPressed: () => context.go(
                                    isAdmin
                                        ? '/admin/requests'
                                        : '/student/requests',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Community Requests',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _CommunityRequestCard(
                      courseCode: 'BIO101',
                      title: 'Need BIO101 Lab Manual Answers',
                      description:
                          "Does anyone have the completed lab manual for week 4? I'm stuck on the genetics section.",
                      requestedBy: 'Alex Johnson',
                      onMarkFulfilled: () {},
                    ),
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

class _CommunityRequestCard extends StatelessWidget {
  final String courseCode;
  final String title;
  final String description;
  final String requestedBy;
  final VoidCallback onMarkFulfilled;

  const _CommunityRequestCard({
    required this.courseCode,
    required this.title,
    required this.description,
    required this.requestedBy,
    required this.onMarkFulfilled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Requested by  ',
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGrey)),
              Text(requestedBy,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: onMarkFulfilled,
                child: const Text('Mark Fulfilled',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}