import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: SmartStudyApp()));
}

class SmartStudyApp extends ConsumerWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp.router(
      title: 'Smart Study',
      theme: AppTheme.theme(settings.isDarkMode, settings.fontSizeFactor),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
