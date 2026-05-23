import 'package:flutter/material.dart';
import 'package:smart_resources/core/theme/app_colors.dart';

class AdminResourceRow extends StatelessWidget {
  final String resourceName;
  final String courseCode;
  final String uploader;
  final bool isApproved;
  final VoidCallback onApprove;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const AdminResourceRow({
    super.key,
    required this.resourceName,
    required this.courseCode,
    required this.uploader,
    required this.isApproved,
    required this.onApprove,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(courseCode,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.75))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(uploader,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8))),
          ),
          Expanded(
            flex: 2,
            child: isApproved
                ? Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text('Approved',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500)),
                    ],
                  )
                : GestureDetector(
                    onTap: onApprove,
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.orange.shade700, size: 16),
                        const SizedBox(width: 4),
                        Text('Approve',
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
          ),
          if (onEdit != null) ...[
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit_outlined,
                  color: theme.iconTheme.color, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline,
                color: theme.colorScheme.error, size: 20),
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
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const AdminRequestRow({
    super.key,
    required this.requestName,
    required this.courseCode,
    required this.requester,
    required this.status,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(courseCode,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.75))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(requester,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.85))),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  isFulfilled ? Icons.check_circle : Icons.cancel,
                  color: isFulfilled ? Colors.green.shade600 : theme.colorScheme.error,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isFulfilled ? 'Fulfilled' : 'Open',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isFulfilled ? Colors.green.shade600 : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit_outlined,
                  color: theme.iconTheme.color, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline,
                color: theme.colorScheme.error, size: 20),
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
    final theme = Theme.of(context);
    final isActive = status == 'active';
    final isAdminRole = role.toLowerCase() == 'admin';
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(email,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.75)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isAdminRole
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : theme.dividerColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(role,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isAdminRole
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodySmall?.color)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.green.shade600 : theme.colorScheme.error,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggleStatus,
            child: Icon(
              isActive ? Icons.close : Icons.check,
              color: isActive ? theme.colorScheme.error : Colors.green.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline,
                color: theme.colorScheme.error, size: 18),
          ),
        ],
      ),
    );
  }
}
