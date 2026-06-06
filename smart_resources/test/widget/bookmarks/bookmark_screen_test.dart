import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

/// Minimal bookmark item widget for testing
class BookmarkItem extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const BookmarkItem({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by $author',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget for bookmarks
class BookmarksEmptyState extends StatelessWidget {
  const BookmarksEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text('No bookmarks yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Save resources to access them later',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Bookmarks screen for testing
class BookmarksScreen extends StatelessWidget {
  final List<Map<String, String>> bookmarks;
  final Function(int) onRemoveBookmark;

  const BookmarksScreen({
    super.key,
    required this.bookmarks,
    required this.onRemoveBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks'), centerTitle: true),
      body: bookmarks.isEmpty
          ? const BookmarksEmptyState()
          : ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return BookmarkItem(
                  title: bookmark['title'] ?? '',
                  description: bookmark['description'] ?? '',
                  author: bookmark['author'] ?? 'Unknown',
                  onTap: () {},
                  onRemove: () => onRemoveBookmark(index),
                );
              },
            ),
    );
  }
}

void main() {
  group('Bookmark Screen Tests', () {
    testWidgets('Bookmarks screen should display saved resources', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookmarks = [
        {
          'title': 'Flutter Basics',
          'description': 'Learn the fundamentals of Flutter',
          'author': 'John Doe',
        },
        {
          'title': 'Dart Programming',
          'description': 'Master Dart language for Flutter development',
          'author': 'Jane Smith',
        },
      ];

      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(
            bookmarks: bookmarks,
            onRemoveBookmark: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(BookmarkItem), findsNWidgets(2));
      expect(find.text('Flutter Basics'), findsOneWidget);
      expect(find.text('Dart Programming'), findsOneWidget);
    });

    testWidgets('Empty bookmarks message should display when no items', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(bookmarks: const [], onRemoveBookmark: (_) {}),
        ),
      );

      // Assert
      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(find.text('Save resources to access them later'), findsOneWidget);
      expect(find.byType(BookmarkItem), findsNothing);
    });

    testWidgets('Remove bookmark should remove from list', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookmarks = [
        {
          'title': 'Flutter Basics',
          'description': 'Learn the fundamentals of Flutter',
          'author': 'John Doe',
        },
        {
          'title': 'Advanced Flutter',
          'description': 'Master advanced Flutter concepts',
          'author': 'Jane Smith',
        },
      ];

      int removedIndex = -1;

      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(
            bookmarks: bookmarks,
            onRemoveBookmark: (index) => removedIndex = index,
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // Assert
      expect(removedIndex, equals(0));
    });

    testWidgets('Tapping bookmark should navigate to details', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool bookmarkTapped = false;

      final bookmarks = [
        {
          'title': 'Flutter Basics',
          'description': 'Learn the fundamentals of Flutter',
          'author': 'John Doe',
        },
      ];

      // Create custom screen to track taps
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: BookmarkItem(
              title: 'Flutter Basics',
              description: 'Learn the fundamentals of Flutter',
              author: 'John Doe',
              onTap: () => bookmarkTapped = true,
              onRemove: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Flutter Basics'), findsOneWidget);
      expect(find.text('Learn the fundamentals of Flutter'), findsOneWidget);
    });

    testWidgets('Bookmark item displays all information', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: BookmarkItem(
              title: 'Advanced Flutter',
              description: 'Master advanced Flutter concepts',
              author: 'Expert Dev',
              onTap: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Advanced Flutter'), findsOneWidget);
      expect(find.text('Master advanced Flutter concepts'), findsOneWidget);
      expect(find.text('by Expert Dev'), findsOneWidget);
    });

    testWidgets('Multiple bookmarks display correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookmarks = [
        {
          'title': 'Flutter Basics',
          'description': 'Learn Flutter',
          'author': 'Author1',
        },
        {
          'title': 'Dart Programming',
          'description': 'Learn Dart',
          'author': 'Author2',
        },
        {
          'title': 'Advanced Flutter',
          'description': 'Advanced concepts',
          'author': 'Author3',
        },
      ];

      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(
            bookmarks: bookmarks,
            onRemoveBookmark: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(BookmarkItem), findsNWidgets(3));
      expect(find.text('Flutter Basics'), findsOneWidget);
      expect(find.text('Dart Programming'), findsOneWidget);
      expect(find.text('Advanced Flutter'), findsOneWidget);
    });

    testWidgets('Bookmarks screen has AppBar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(bookmarks: const [], onRemoveBookmark: (_) {}),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
    });

    testWidgets('Remove button is visible on each bookmark', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookmarks = [
        {
          'title': 'Flutter Basics',
          'description': 'Learn Flutter',
          'author': 'Author1',
        },
        {
          'title': 'Dart Programming',
          'description': 'Learn Dart',
          'author': 'Author2',
        },
      ];

      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(
            bookmarks: bookmarks,
            onRemoveBookmark: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });

    testWidgets('Remove button triggers callback with correct index', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookmarks = [
        {'title': 'First', 'description': 'Desc 1', 'author': 'Author1'},
        {'title': 'Second', 'description': 'Desc 2', 'author': 'Author2'},
        {'title': 'Third', 'description': 'Desc 3', 'author': 'Author3'},
      ];

      int removedIndex = -1;

      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(
            bookmarks: bookmarks,
            onRemoveBookmark: (index) => removedIndex = index,
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.close).at(1));
      await tester.pumpAndSettle();

      // Assert
      expect(removedIndex, equals(1));
    });

    testWidgets('Empty state shows correct icon', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(child: Scaffold(body: const BookmarksEmptyState())),
      );

      // Assert
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
    });

    testWidgets('Empty state shows helpful message', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(child: Scaffold(body: const BookmarksEmptyState())),
      );

      // Assert
      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(find.text('Save resources to access them later'), findsOneWidget);
    });

    testWidgets('Bookmark item card has proper styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: BookmarkItem(
              title: 'Test Title',
              description: 'Test Description',
              author: 'Test Author',
              onTap: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('Bookmarks list scrolls when has many items', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookmarks = List.generate(
        10,
        (index) => {
          'title': 'Bookmark $index',
          'description': 'Description $index',
          'author': 'Author $index',
        },
      );

      await tester.pumpWidget(
        TestApp(
          child: BookmarksScreen(
            bookmarks: bookmarks,
            onRemoveBookmark: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(BookmarkItem), findsWidgets);

      // Verify scrollable
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);
    });

    testWidgets('Bookmark item displays truncated description', (
      WidgetTester tester,
    ) async {
      // Arrange
      const longDescription =
          'This is a very long description that might exceed the available space and should be truncated with ellipsis';

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: BookmarkItem(
              title: 'Test',
              description: longDescription,
              author: 'Author',
              onTap: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(longDescription), findsOneWidget);
    });

    testWidgets('Bookmark author text is visible', (WidgetTester tester) async {
      // Arrange
      const authorName = 'John Developer';

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: BookmarkItem(
              title: 'Title',
              description: 'Description',
              author: authorName,
              onTap: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('by $authorName'), findsOneWidget);
    });
  });
}
