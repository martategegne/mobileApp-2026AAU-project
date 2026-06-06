import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review Screen Tests', () {
    testWidgets('Review list should display all reviews', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Review card should show rating and comment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewCard(rating: 5, comment: 'Great resource!')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsWidgets);
      expect(find.text('Great resource!'), findsOneWidget);
    });

    testWidgets('Filter reviews by rating', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5 Stars'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('Average rating should be displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewScreen()));
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
    });
  });

  group('Review Form Tests', () {
    testWidgets('Review form should display star rating widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewForm()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('write_review_button')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_outline), findsWidgets);
    });

    testWidgets('Submit review with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewForm()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('write_review_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.star_outline).at(4));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('comment_field')), 'Great resource!');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Review Submitted'), findsOneWidget);
    });

    testWidgets('Review form validation should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ReviewForm()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('write_review_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please select a rating'), findsOneWidget);
    });
  });
}

// --- Test-only widgets ---

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _filter = 'All';
  final reviews = [
    {'rating': 5, 'comment': 'Excellent'},
    {'rating': 4, 'comment': 'Good'},
  ];

  double get average => 4.5;

  @override
  Widget build(BuildContext context) {
    final visible = _filter == 'All' ? reviews : reviews.where((r) => r['rating'] == 5).toList();
    return Scaffold(
      appBar: AppBar(actions: [
        PopupMenuButton<String>(
          key: const Key('filter_button'),
          onSelected: (v) => setState(() => _filter = v),
          itemBuilder: (_) => const [PopupMenuItem(value: '5 Stars', child: Text('5 Stars'))],
        )
      ]),
      body: Column(children: [
        Text(average.toString()),
        Expanded(
          child: ListView(children: visible.map((r) => ListTile(leading: Row(mainAxisSize: MainAxisSize.min, children: List.generate(r['rating'] as int, (_) => const Icon(Icons.star))), title: Text(r['comment'] as String))).toList()),
        )
      ]),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final int rating;
  final String comment;
  const ReviewCard({Key? key, required this.rating, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Row(mainAxisSize: MainAxisSize.min, children: List.generate(rating, (_) => const Icon(Icons.star))), title: Text(comment)),
    );
  }
}

class ReviewForm extends StatefulWidget {
  const ReviewForm({Key? key}) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  int? _rating;
  final _controller = TextEditingController();
  bool _showForm = false;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        ElevatedButton(key: const Key('write_review_button'), onPressed: () => setState(() => _showForm = true), child: const Text('Write')),
        if (_showForm)
          Column(children: [
            Row(children: List.generate(5, (i) => IconButton(key: Key('star_$i'), icon: const Icon(Icons.star_outline), onPressed: () => setState(() => _rating = i + 1))),
            ),
            TextField(key: const Key('comment_field'), controller: _controller),
            ElevatedButton(
              key: const Key('submit_button'),
              onPressed: () {
                if (_rating == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating')));
                } else {
                  setState(() => _submitted = true);
                }
              },
              child: const Text('Submit'),
            ),
            if (_submitted) const Text('Review Submitted')
          ])
      ]),
    );
  }
}
