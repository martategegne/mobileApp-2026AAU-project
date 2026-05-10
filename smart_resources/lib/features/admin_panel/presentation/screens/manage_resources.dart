import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/admin_action_row.dart';

class ManageResources extends StatefulWidget {
  const ManageResources({super.key});

  @override
  State<ManageResources> createState() => _ManageResourcesState();
}

class _ManageResourcesState extends State<ManageResources> {
  final List<Map<String, dynamic>> _resources = [
    {
      'name': 'CS101 Midterm Study',
      'code': 'CS301',
      'uploader': 'Sarah Smith',
      'approved': true
    },
    {
      'name': 'Calculus II Final Exam',
      'code': 'MATH201',
      'uploader': 'Alex Johnson',
      'approved': false
    },
    {
      'name': 'Physics Mechanics',
      'code': 'PHY201',
      'uploader': 'Sarah Smith',
      'approved': true
    },
    {
      'name': 'Literature Essay',
      'code': 'ENG102',
      'uploader': 'Alex Johnson',
      'approved': false
    },
    {
      'name': 'Organic Chemistry',
      'code': 'CHEM201',
      'uploader': 'Sarah Smith',
      'approved': false
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
              activeIndex: 0,
              onTap: (i) {
                if (i == 1) context.go('/admin/panel/requests');
                if (i == 2) context.go('/admin/panel/users');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Manage Resources',
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
                              Expanded(
                                  flex: 3, child: _TableHeader('Resource')),
                              Expanded(
                                  flex: 2, child: _TableHeader('Uploader')),
                              Expanded(
                                  flex: 2, child: _TableHeader('Approval')),
                              SizedBox(width: 24, child: _TableHeader('Act.')),
                            ],
                          ),
                          const Divider(height: 16),
                          ...List.generate(_resources.length, (i) {
                            final r = _resources[i];
                            return Column(
                              children: [
                                AdminResourceRow(
                                  resourceName: r['name'],
                                  courseCode: r['code'],
                                  uploader: r['uploader'],
                                  isApproved: r['approved'],
                                  onApprove: () => setState(
                                      () => _resources[i]['approved'] = true),
                                  onDelete: () =>
                                      setState(() => _resources.removeAt(i)),
                                ),
                                if (i < _resources.length - 1)
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

class _AdminHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const _AdminHeader({required this.title, this.onBack});

  @override
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
