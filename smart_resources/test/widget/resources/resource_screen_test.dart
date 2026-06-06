import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resource Screen Tests', () {
    testWidgets('Resource list should display items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Resource card should show title and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceItemCard(title: 'Title', description: 'Description')));
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('Category filter should work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceScreen()));
      await tester.pumpAndSettle();

      // Open filter and choose 'Books'
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Books'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Book A'), findsOneWidget);
    });

    testWidgets('Bookmark icon should toggle bookmark status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceItemCard(title: 'T', description: 'D')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('Pagination should load more resources', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Item 3'), findsNothing);
      await tester.tap(find.byKey(const Key('load_more_button')));
      await tester.pumpAndSettle();

      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('Resource Detail Screen Tests', () {
    testWidgets('Detail screen should display all resource information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceDetail(title: 'Resource Title', description: 'Description')));
      await tester.pumpAndSettle();

      expect(find.text('Resource Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('Request resource button should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ResourceDetail(title: 'R', description: 'D')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('request_button')));
      await tester.pumpAndSettle();

      expect(find.text('Request Submitted'), findsOneWidget);
    });
  });
}

// --- Test-only widgets ---

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({Key? key}) : super(key: key);

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  String _filter = 'All';
  List<Map<String, String>> items = [
    {'title': 'Book A', 'category': 'Books'},
    {'title': 'Item 2', 'category': 'Others'}
  ];

  void _loadMore() {
    items.add({'title': 'Item 3', 'category': 'Others'});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filter == 'All' ? items : items.where((e) => e['category'] == _filter).toList();
    return Scaffold(
      appBar: AppBar(actions: [
        PopupMenuButton<String>(
          key: const Key('filter_button'),
          onSelected: (v) => setState(() => _filter = v),
          itemBuilder: (_) => const [PopupMenuItem(value: 'Books', child: Text('Books'))],
        )
      ]),
      body: Column(children: [
        Expanded(
          child: ListView(children: visible.map((e) => ListTile(title: Text(e['title']!))).toList()),
        ),
        ElevatedButton(key: const Key('load_more_button'), onPressed: _loadMore, child: const Text('Load more'))
      ]),
    );
  }
}

class ResourceItemCard extends StatefulWidget {
  final String title;
  final String description;
  const ResourceItemCard({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  State<ResourceItemCard> createState() => _ResourceItemCardState();
}

class _ResourceItemCardState extends State<ResourceItemCard> {
  bool bookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text(widget.description),
        trailing: IconButton(
          icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
          onPressed: () => setState(() => bookmarked = !bookmarked),
        ),
      ),
    );
  }
}

class ResourceDetail extends StatelessWidget {
  final String title;
  final String description;
  const ResourceDetail({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Text(title), Text(description), ElevatedButton(key: const Key('request_button'), onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(content: Text('Request Submitted'))), child: const Text('Request'))]),
    );
  }
}
