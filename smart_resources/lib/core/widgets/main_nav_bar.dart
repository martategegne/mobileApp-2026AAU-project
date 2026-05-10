import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import '../theme/app_colors.dart';

class MainNavBar extends StatelessWidget {
  final bool isAdmin;
  final Widget child;

  const MainNavBar({super.key, required this.isAdmin, required this.child});

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final prefix = isAdmin ? '/admin' : '/student';
    if (location.startsWith('$prefix/home')) return 0;
    if (location.startsWith('$prefix/resources')) return 1;
    if (location.startsWith('$prefix/requests')) return 2;
    if (location.startsWith('$prefix/bookmarks')) return 3;
    if (location.startsWith('$prefix/profile')) return 4;
    if (location.startsWith('$prefix/panel')) return 4;
    if (location.startsWith('$prefix/upload')) return 1;
    if (location.startsWith('$prefix/downloads')) return 0;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final prefix = isAdmin ? '/admin' : '/student';
    switch (index) {
      case 0:
        context.go('$prefix/home');
        break;
      case 1:
        context.go('$prefix/resources');
        break;
      case 2:
        context.go('$prefix/requests');
        break;
      case 3:
        context.go('$prefix/bookmarks');
        break;
      case 4:
        context.go('$prefix/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Resources'),
          BottomNavigationBarItem(
              icon: Icon(Icons.help_outlined),
              activeIcon: Icon(Icons.help_outlined),
              label: 'Requests'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
