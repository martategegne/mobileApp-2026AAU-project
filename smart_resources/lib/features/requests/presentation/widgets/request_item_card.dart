import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/features/requests/data/models/request_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/request_notifier.dart';

class RequestItemCard extends ConsumerWidget {
  final String id;
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
    required this.id,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFulfilled = status == 'fulfilled';
    final currentUser = ref.watch(authNotifierProvider).user;
    final isOwner = currentUser?.name == requestedBy;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isFulfilled
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                child: Icon(
                  isFulfilled ? Icons.check_circle_outline : Icons.circle_outlined,
                  size: 16,
                  color: isFulfilled ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isFulfilled
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isFulfilled ? 'Fulfilled' : 'Open',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFulfilled ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(courseCode,
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary)),
              ),
              const SizedBox(width: 8),
              Text('Requested by  ',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
              Text(requestedBy,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Text('• $time',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (showMarkFulfilled && !isFulfilled)
                GestureDetector(
                  onTap: () => ref.read(requestNotifierProvider.notifier).fulfillRequest(id),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('Mark Fulfilled',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                    ],
                  ),
                )
              else if (isFulfilled)
                Text('Fulfilled',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              const Spacer(),
              if (isOwner) ...[
                GestureDetector(
                  onTap: () {
                    final model = RequestModel(
                      id: id,
                      title: title,
                      description: description,
                      courseCode: courseCode,
                      requestedBy: requestedBy,
                      time: time,
                      status: status,
                    );
                    context.go(isAdmin ? '/admin/requests/new' : '/student/requests/new', extra: model);
                  },
                  child: Icon(Icons.edit_outlined, size: 18, color: theme.iconTheme.color),
                ),
                const SizedBox(width: 12),
              ],
              if (isAdmin || isOwner)
                GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, ref);
                  },
                  child: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text('Are you sure you want to delete this request?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                ref.read(requestNotifierProvider.notifier).deleteRequest(id);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        );
      },
    );
  }
}
