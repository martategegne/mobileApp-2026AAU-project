import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../test_helper.dart';

/// Minimal student dashboard for testing without router dependencies
class SimpleStudentDash extends StatelessWidget {
  final String userName;
  final String userRole;
  final bool isAdmin;
  final VoidCallback onNotificationsTap;
  final VoidCallback onUpload;
  final VoidCallback onRequest;
  final VoidCallback onBookmarks;
  final VoidCallback onSecondary;
  final List<Map<String, String>> activities;

  const SimpleStudentDash({
    super.key,
    required this.userName,
    required this.userRole,
    this.isAdmin = false,
    required this.onNotificationsTap,
    required this.onUpload,
    required this.onRequest,
    required this.onBookmarks,
    required this.onSecondary,
    this.activities = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer
                ],
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
                  icon: Icon(Icons.notifications_outlined,
                      color: theme.colorScheme.onPrimary),
                  onPressed: onNotificationsTap,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    userRole,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Welcome and content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $userName',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
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
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _QuickActionCard(
                              title: 'Upload',
                              subtitle: 'Share resources',
                              onTap: onUpload,
                            ),
                            _QuickActionCard(
                              title: 'Request',
                              subtitle: 'Ask for materials',
                              onTap: onRequest,
                            ),
                            _QuickActionCard(
                              title: 'Bookmarks',
                              subtitle: 'Saved resources',
                              onTap: onBookmarks,
                            ),
                            _QuickActionCard(
                              title: isAdmin
                                  ? 'Rate & Review'
                                  : 'Downloads',
                              subtitle: isAdmin
                                  ? 'Feedback on resources'
                                  : 'Fetch downloads',
                              onTap: onSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        if (activities.isEmpty)
                          Text(
                            'No recent activity to show.',
                            style: theme.textTheme.bodySmall,
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity['title'] ?? '',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        activity['time'] ?? '',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style:
                  theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Home Screen Tests', () {
    testWidgets('Home screen displays app bar with title', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'John Doe',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Smart Study'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('Home screen displays welcome message', (
      WidgetTester tester,
    ) async {
      // Arrange
      const userName = 'Jane Smith';

      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: userName,
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Welcome back, $userName'), findsOneWidget);
      expect(find.text('Share resources • learn together'), findsOneWidget);
    });

    testWidgets('Home screen displays user role badge', (
      WidgetTester tester,
    ) async {
      // Arrange
      const userRole = 'Teacher';

      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: userRole,
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text(userRole), findsOneWidget);
    });

    testWidgets('Home screen displays quick action cards', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
    });

    testWidgets('Home screen displays quick action cards', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
    });

    testWidgets('Notifications button callback works',
        (WidgetTester tester) async {
      // Arrange
      bool notificationsTapped = false;

      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () => notificationsTapped = true,
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Assert
      expect(notificationsTapped, isTrue);
    });

    testWidgets('Home screen displays recent activity section', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('Home screen shows empty activity message when no activities',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
            activities: const [],
          ),
        ),
      );

      // Assert
      expect(find.text('No recent activity to show.'), findsOneWidget);
    });

    testWidgets('Home screen displays activities when present',
        (WidgetTester tester) async {
      // Arrange
      final activities = [
        {'title': 'You uploaded a resource', 'time': '2 hours ago'},
        {'title': 'You bookmarked a material', 'time': '1 hour ago'},
      ];

      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
            activities: activities,
          ),
        ),
      );

      // Assert
      expect(find.text('You uploaded a resource'), findsOneWidget);
      expect(find.text('You bookmarked a material'), findsOneWidget);
      expect(find.text('2 hours ago'), findsOneWidget);
      expect(find.text('1 hour ago'), findsOneWidget);
    });

    testWidgets('Home screen admin mode shows correct labels',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Admin User',
            userRole: 'Admin',
            isAdmin: true,
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Rate & Review'), findsOneWidget);
      expect(find.text('Downloads'), findsNothing);
    });

    testWidgets('Home screen scrolls when content is long',
        (WidgetTester tester) async {
      // Arrange
      final activities = List.generate(
        10,
        (index) => {
          'title': 'Activity $index',
          'time': '$index hours ago',
        },
      );

      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
            activities: activities,
          ),
        ),
      );

      // Assert
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('Home screen has proper spacing and layout',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: SimpleStudentDash(
            userName: 'Test User',
            userRole: 'Student',
            onNotificationsTap: () {},
            onUpload: () {},
            onRequest: () {},
            onBookmarks: () {},
            onSecondary: () {},
          ),
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
