import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/request_notifier.dart';
import '../widgets/request_item_card.dart';

class RequestsList extends ConsumerStatefulWidget {
  final bool isAdmin;
  const RequestsList({super.key, required this.isAdmin});

  @override
  ConsumerState<RequestsList> createState() => _RequestsListState();
}

class _RequestsListState extends ConsumerState<RequestsList> {
  String _activeTab = 'All';

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestNotifierProvider);
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Resource Requests'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ...['All', 'Open', 'Fulfilled'].map((tab) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = tab),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _activeTab == tab
                                  ? selectedColor
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _activeTab == tab
                                    ? selectedColor
                                    : theme.dividerColor,
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _activeTab == tab
                                    ? theme.colorScheme.onPrimary
                                    : unselectedColor,
                              ),
                            ),
                          ),
                        ),
                      )),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context.go(
                        widget.isAdmin
                            ? '/admin/requests/new'
                            : '/student/requests/new',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('+ New Request',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: requestsState.when(
                data: (requests) {
                  final filtered = requests.where((r) {
                    if (_activeTab == 'All') return true;
                    return r.status.toLowerCase() == _activeTab.toLowerCase();
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                        child: Text('No requests found.',
                            style: theme.textTheme.bodyMedium));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final r = filtered[i];
                      return RequestItemCard(
                        id: r.id,
                        title: r.title,
                        description: r.description,
                        courseCode: r.courseCode,
                        requestedBy: r.requestedBy,
                        time: r.time,
                        status: r.status,
                        isAdmin: widget.isAdmin,
                        showMarkFulfilled: widget.isAdmin,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
