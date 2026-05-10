import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/student_dash.dart';
import '../../features/home/presentation/screens/admin_dash.dart';
import '../../features/resources/presentation/screens/resource_list.dart';
import '../../features/resources/presentation/screens/resource_details.dart';
import '../../features/resources/presentation/screens/upload_resource.dart';
import '../../features/resources/presentation/screens/bookmarks_screen.dart';
import '../../features/resources/presentation/screens/downloads_screen.dart';
import '../../features/requests/presentation/screens/requests_list.dart';
import '../../features/requests/presentation/screens/create_request.dart';
import '../../features/admin_panel/presentation/screens/manage_resources.dart';
import '../../features/admin_panel/presentation/screens/manage_requests.dart';
import '../../features/admin_panel/presentation/screens/manage_users.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../widgets/main_nav_bar.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Student Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavBar(isAdmin: false, child: child);
        },
        routes: [
          GoRoute(
            path: '/student/home',
            builder: (context, state) => const StudentDash(),
          ),
          GoRoute(
            path: '/student/resources',
            builder: (context, state) => const ResourceList(isAdmin: false),
          ),
          GoRoute(
            path: '/student/resources/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '1';
              return ResourceDetails(resourceId: id, isAdmin: false);
            },
          ),
          GoRoute(
            path: '/student/upload',
            builder: (context, state) => const UploadResource(isAdmin: false),
          ),
          GoRoute(
            path: '/student/requests',
            builder: (context, state) => const RequestsList(isAdmin: false),
          ),
          GoRoute(
            path: '/student/requests/new',
            builder: (context, state) => const CreateRequest(isAdmin: false),
          ),
          GoRoute(
            path: '/student/bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/student/downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: '/student/profile',
            builder: (context, state) => const ProfileScreen(isAdmin: false),
          ),
          GoRoute(
            path: '/student/profile/edit',
            builder: (context, state) =>
                const EditProfileScreen(isAdmin: false),
          ),
        ],
      ),

      // Admin Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavBar(isAdmin: true, child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/home',
            builder: (context, state) => const AdminDash(),
          ),
          GoRoute(
            path: '/admin/resources',
            builder: (context, state) => const ResourceList(isAdmin: true),
          ),
          GoRoute(
            path: '/admin/resources/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '1';
              return ResourceDetails(resourceId: id, isAdmin: true);
            },
          ),
          GoRoute(
            path: '/admin/upload',
            builder: (context, state) => const UploadResource(isAdmin: true),
          ),
          GoRoute(
            path: '/admin/requests',
            builder: (context, state) => const RequestsList(isAdmin: true),
          ),
          GoRoute(
            path: '/admin/requests/new',
            builder: (context, state) => const CreateRequest(isAdmin: true),
          ),
          GoRoute(
            path: '/admin/bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/admin/profile',
            builder: (context, state) => const ProfileScreen(isAdmin: true),
          ),
          GoRoute(
            path: '/admin/profile/edit',
            builder: (context, state) => const EditProfileScreen(isAdmin: true),
          ),
          GoRoute(
            path: '/admin/panel/resources',
            builder: (context, state) => const ManageResources(),
          ),
          GoRoute(
            path: '/admin/panel/requests',
            builder: (context, state) => const ManageRequests(),
          ),
          GoRoute(
            path: '/admin/panel/users',
            builder: (context, state) => const ManageUsers(),
          ),
        ],
      ),
    ],
  );
}
