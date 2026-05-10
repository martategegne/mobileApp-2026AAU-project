import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/admin_action_row.dart';

class _AdminHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const _AdminHeader({required this.title, this.onBack});

  @override // replace the parent method with its own
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Admin',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
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
                  color:
                      isActive ? AppColors.tagBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i],
                        size: 14,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.mediumGrey),
                    const SizedBox(width: 4),
                    Text(tabs[i],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary)),
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
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.mediumGrey));
  }
}

class ManageRequests extends StatefulWidget {
  const ManageRequests({super.key});

  @override
  State<ManageRequests> createState() => _ManageRequestsState();
}

class _ManageRequestsState extends State<ManageRequests> {
  final List<Map<String, dynamic>> _requests = [
    {
      'name': 'physics exam',
      'code': 'PHY102',
      'requester': 'Stagegn',
      'status': 'open'
    },
    {
      'name': 'Chemistry Lab Manual',
      'code': 'CHEM202',
      'requester': 'Admin User',
      'status': 'fulfilled'
    },
    {
      'name': 'BIO101 Lab Manual An...',
      'code': 'BIO102',
      'requester': 'Alex Johnson',
      'status': 'open'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              activeIndex: 1,
              onTap: (i) {
                if (i == 0) context.go('/admin/panel/resources');
                if (i == 2) context.go('/admin/panel/users');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Manage Requests',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(flex: 3, child: _TableHeader('Request')),
                              Expanded(
                                  flex: 2, child: _TableHeader('Requester')),
                              Expanded(flex: 2, child: _TableHeader('Status')),
                              SizedBox(width: 24, child: _TableHeader('Act.')),
                            ],
                          ),
                          const Divider(height: 16),
                          ...List.generate(_requests.length, (i) {
                            final r = _requests[i];
                            return Column(
                              children: [
                                AdminRequestRow(
                                  requestName: r['name'],
                                  courseCode: r['code'],
                                  requester: r['requester'],
                                  status: r['status'],
                                  onDelete: () =>
                                      setState(() => _requests.removeAt(i)),
                                ),
                                if (i < _requests.length - 1)
                                  const Divider(
                                      height: 1, color: AppColors.cardBorder),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
