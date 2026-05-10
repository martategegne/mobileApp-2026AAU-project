import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RequestItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String courseCode;
  final String requestedBy;
  final String time;
  final String status; // 'open' or 'fulfilled'
  final bool isAdmin;
  final bool showMarkFulfilled;

  const RequestItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.requestedBy,
    required this.time,
    required this.status,
    required this.isAdmin,
    this.showMarkFulfilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFulfilled = status == 'fulfilled';
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
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    isFulfilled ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
                child: Icon(
                  isFulfilled ? Icons.check_circle_outline : Icons.circle_outlined,
                  size: 16,
                  color: isFulfilled ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isFulfilled
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isFulfilled ? 'Fulfilled' : 'Open',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFulfilled ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tagBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(courseCode,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              Text('Requested by  ',
                  style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey)),
              Text(requestedBy,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              Text('• $time',
                  style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (showMarkFulfilled && !isFulfilled)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Mark Fulfilled',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500)),
                  ],
                )
              else if (isFulfilled)
                const Text('Fulfilled',
                    style: TextStyle(fontSize: 12, color: AppColors.mediumGrey)),
              const Spacer(),
              if (isAdmin) ...[
                const Icon(Icons.edit_outlined, size: 18, color: AppColors.mediumGrey),
                const SizedBox(width: 12),
                const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              ] else
                const Icon(Icons.edit_outlined, size: 18, color: AppColors.mediumGrey),
            ],
          ),
        ],
      ),
    );
  }
}