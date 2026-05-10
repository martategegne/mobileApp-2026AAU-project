import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AdminResourceRow extends StatelessWidget {
  final String resourceName;
  final String courseCode;
  final String uploader;
  final bool isApproved;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  const AdminResourceRow({
    super.key,
    required this.resourceName,
    required this.courseCode,
    required this.uploader,
    required this.isApproved,
    required this.onApprove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resourceName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(courseCode,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mediumGrey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(uploader,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: isApproved
                ? const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 16),
                      SizedBox(width: 4),
                      Text('Approved',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500)),
                    ],
                  )
                : GestureDetector(
                    onTap: onApprove,
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: AppColors.warning, size: 16),
                        SizedBox(width: 4),
                        Text('Approve',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}

class AdminRequestRow extends StatelessWidget {
  final String requestName;
  final String courseCode;
  final String requester;
  final String status; // 'open' or 'fulfilled'
  final VoidCallback onDelete;

  const AdminRequestRow({
    super.key,
    required this.requestName,
    required this.courseCode,
    required this.requester,
    required this.status,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isFulfilled = status == 'fulfilled';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(requestName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(courseCode,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mediumGrey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(requester,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  isFulfilled ? Icons.check_circle : Icons.cancel,
                  color: isFulfilled ? AppColors.success : AppColors.error,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isFulfilled ? 'Fulfilled' : 'Open',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isFulfilled ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}

class AdminUserRow extends StatelessWidget {
  final String userName;
  final String email;
  final String role;
  final String status; // 'active' or 'suspended'
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const AdminUserRow({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    required this.status,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(email,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.mediumGrey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: role == 'admin'
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(role,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: role == 'admin'
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggleStatus,
            child: Icon(
              isActive
                  ? Icons.close
                  : Icons.check, // ✅ X when active, check when suspended
              color: isActive
                  ? AppColors.error
                  : AppColors.success, // red X, green check
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 18),
          ),
        ],
      ),
    );
  }
}
