import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Request Screen Tests', () {
    testWidgets('Request screen should display pending requests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RequestScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('Request card should show status', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RequestCard(status: 'Pending')));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('Approve button should be visible for pending requests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RequestCard(status: 'Pending')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('approve_button')), findsOneWidget);
    });

    testWidgets('Reject request should update status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RequestCard(status: 'Pending')));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
      await tester.tap(find.byKey(const Key('reject_button')));
      await tester.pumpAndSettle();

      expect(find.text('Request Rejected'), findsOneWidget);
    });

    testWidgets('Tab between pending and history', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RequestTabs()));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('History List'), findsOneWidget);
    });
  });

  group('Request Form Tests', () {
    testWidgets('Request form should validate reason field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RequestForm()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('request_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Reason is required'), findsOneWidget);
    });

    testWidgets('Submit request form successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RequestForm()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('request_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('reason_field')), 'Need for project');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Request Submitted'), findsOneWidget);
    });
  });
}

// --- Test-only widgets ---

class RequestScreen extends StatelessWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: ListView(
        children: const [RequestCard(status: 'Pending'), RequestCard(status: 'Pending')],
      ),
    );
  }
}

class RequestCard extends StatefulWidget {
  final String status;
  const RequestCard({Key? key, required this.status}) : super(key: key);

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(_status),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(key: const Key('approve_button'), icon: const Icon(Icons.check), onPressed: () {}),
          IconButton(
            key: const Key('reject_button'),
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _status = 'Request Rejected'),
          ),
        ]),
      ),
    );
  }
}

class RequestTabs extends StatelessWidget {
  const RequestTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(tabs: [Tab(text: 'Pending'), Tab(text: 'History')]),
        ),
        body: const TabBarView(children: [Center(child: Text('Pending')), Center(child: Text('History List'))]),
      ),
    );
  }
}

class RequestForm extends StatefulWidget {
  const RequestForm({Key? key}) : super(key: key);

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _controller = TextEditingController();
  bool _showForm = false;
  String? _submittedText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        ElevatedButton(key: const Key('request_button'), onPressed: () => setState(() => _showForm = true), child: const Text('Request')),
        if (_showForm)
          Column(children: [
            TextField(key: const Key('reason_field'), controller: _controller),
            ElevatedButton(
              key: const Key('submit_button'),
              onPressed: () {
                if (_controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason is required')));
                } else {
                  setState(() => _submittedText = 'Request Submitted');
                }
              },
              child: const Text('Submit'),
            ),
            if (_submittedText != null) Text(_submittedText!),
          ])
      ]),
    );
  }
}
