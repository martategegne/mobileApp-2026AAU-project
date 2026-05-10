import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/request_item_card.dart';

class RequestsList extends StatefulWidget {
  final bool isAdmin;
  const RequestsList({super.key, required this.isAdmin});

  @override
  State<RequestsList> createState() => _RequestsListState();
}

class _RequestsListState extends State<RequestsList> {
  String _activeTab = 'All';

  final List<Map<String, dynamic>> _requests = [
    {
      'title': 'physics exam',
      'description': 'Looking for past midterms from 2023 or 2024.',
      'courseCode': 'PHY101',
      'requestedBy': 'Anatoli',
      'time': 'Apr 7',
      'status': 'open',
    },
    {
      'title': 'Chemistry Lab Manual',
      'description': 'Need the lab manual for the second semester.',
      'courseCode': 'CHEM202',
      'requestedBy': 'Admin User',
      'time': 'Mar 30',
      'status': 'fulfilled',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_activeTab == 'All') return _requests;
    return _requests
        .where((r) => r['status'] == _activeTab.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.isAdmin ? '/admin' : '/student';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resource Requests'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              // child: Row(
              //   children: [
              //     const Icon(Icons.notifications_outlined,
              //         color: AppColors.textPrimary),
              //     const SizedBox(width: 10),
              //     Container(
              //       padding:
              //           const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //       decoration: BoxDecoration(
              //         color: AppColors.lightGrey.withOpacity(0.5),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Text(
              //         widget.isAdmin ? 'Admin' : 'User',
              //         style: const TextStyle(
              //             fontSize: 12, color: AppColors.textSecondary),
              //       ),
              //     ),
              //   ],
              // ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _activeTab == tab
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : AppColors.lightGrey,
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _activeTab == tab
                                    ? AppColors.white
                                    : AppColors.textSecondary,
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
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('+ New Request',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final r = _filtered[i];
                  return RequestItemCard(
                    title: r['title'],
                    description: r['description'],
                    courseCode: r['courseCode'],
                    requestedBy: r['requestedBy'],
                    time: r['time'],
                    status: r['status'],
                    isAdmin: widget.isAdmin,
                    showMarkFulfilled: widget.isAdmin,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}