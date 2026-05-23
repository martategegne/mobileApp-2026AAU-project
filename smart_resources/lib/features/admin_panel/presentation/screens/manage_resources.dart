import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/resources/presentation/providers/resource_notifier.dart';
import '../widgets/admin_action_row.dart';
import '../../../../core/theme/app_colors.dart';

class ManageResources extends ConsumerWidget {
  const ManageResources({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resourcesState = ref.watch(resourceNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _AdminHeader(
                title: 'Admin Panel', onBack: () => context.go('/admin/home')),
            _AdminTabBar(
              tabs: const ['Resources', 'Requests', 'Users'],
              icons: const [
                Icons.menu_book_outlined,
                Icons.search_outlined,
                Icons.person_outline
              ],
              activeIndex: 0,
              onTap: (i) {
                if (i == 1) context.go('/admin/panel/requests');
                if (i == 2) context.go('/admin/panel/users');
              },
            ),
            Expanded(
              child: resourcesState.when(
                data: (resources) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manage Resources',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                    flex: 3, child: _TableHeader('Resource')),
                                Expanded(
                                    flex: 2, child: _TableHeader('Uploader')),
                                Expanded(
                                    flex: 2, child: _TableHeader('Approval')),
                                SizedBox(width: 50, child: _TableHeader('Act.')),
                              ],
                            ),
                            const Divider(height: 16),
                            if (resources.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('No resources found.'),
                              ),
                            ...List.generate(resources.length, (i) {
                              final r = resources[i];
                              return Column(
                                children: [
                                  AdminResourceRow(
                                    resourceName: r.title,
                                    courseCode: r.courseCode,
                                    uploader: r.uploader,
                                    isApproved: r.isApproved,
                                    onApprove: () => ref
                                        .read(resourceNotifierProvider.notifier)
                                        .approveResource(r.id),
                                    onEdit: null,
                                    onDelete: () => _showDeleteDialog(context, ref, r.id),
                                  ),
                                  if (i < resources.length - 1)
                                    Divider(height: 1, color: theme.dividerColor),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Delete Resource'),
          content: const Text('Are you sure you want to delete this resource?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                ref.read(resourceNotifierProvider.notifier).deleteResource(id);
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

class _AdminHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const _AdminHeader({required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
           Icon(Icons.notifications_outlined, color: theme.iconTheme.color),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Admin', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8))),
          ),
        ],
      ),
    );
  }
}

class _AdminTabBar extends StatelessWidget {
  final List<String> tabs;
  final List<IconData> icons;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _AdminTabBar({
    required this.tabs,
    required this.icons,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i],
                        size: 14,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(tabs[i],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(text,
        style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.75)));
  }
}
