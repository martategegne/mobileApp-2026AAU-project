import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/home/presentation/providers/activity_notifier.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/activity_card.dart';
import '../../../../core/theme/app_colors.dart';

class StudentDash extends ConsumerWidget {
  const StudentDash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final activitiesState = ref.watch(activityNotifierProvider);

    final prefix = user?.isAdmin ?? false ? '/admin' : '/student';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Teal header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Study',
                        style: TextStyle(
                          fontSize: 20,
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onPrimary),
                  onPressed: () => context.push('$prefix/notifications'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role ?? 'User',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Welcome back text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.name ?? 'User'}',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Share resources • learn together',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        QuickActionGrid(
                          isAdmin: false,
                          onUpload: () => context.go('/student/upload'),
                          onRequest: () => context.go('/student/requests'),
                          onBookmarks: () => context.go('/student/bookmarks'),
                          onSecondary: () => context.go('/student/downloads'),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        activitiesState.when(
                          data: (activities) {
                            if (activities.isEmpty) {
                              return Text(
                                'No recent activity to show.',
                                style: theme.textTheme.bodySmall,
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: activities.length,
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                IconData icon;
                                Color color;
                                switch (activity.type) {
                                  case 'upload':
                                    icon = Icons.upload_outlined;
                                    color = AppColors.primary;
                                    break;
                                  case 'request':
                                    icon = Icons.help_outline;
                                    color = AppColors.warning;
                                    break;
                                  case 'bookmark':
                                    icon = Icons.bookmark_outline;
                                    color = AppColors.starColor;
                                    break;
                                  case 'download':
                                    icon = Icons.download_outlined;
                                    color = Colors.blue;
                                    break;
                                  case 'review':
                                    icon = Icons.star_outline;
                                    color = Colors.orange;
                                    break;
                                  case 'profile_update':
                                    icon = Icons.person_outline;
                                    color = Colors.teal;
                                    break;
                                  case 'signup':
                                    icon = Icons.person_add_outlined;
                                    color = Colors.green;
                                    break;
                                  default:
                                    icon = Icons.notifications_none;
                                    color = AppColors.mediumGrey;
                                }
                                
                                final timeParts = activity.time.split(' ');
                                final timeStr = timeParts.length > 1 ? timeParts[1].substring(0, 5) : activity.time;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ActivityCard(
                                    icon: icon,
                                    iconColor: color,
                                    title: "You ${activity.title}",
                                    time: timeStr,
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                        ),
                        const SizedBox(height: 100), // Extra space for scrolling
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
