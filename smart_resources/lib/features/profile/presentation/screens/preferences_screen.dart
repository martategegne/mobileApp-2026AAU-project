import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/core/settings/settings_provider.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: settings.isDarkMode,
            onChanged: (value) => notifier.toggleDarkMode(value),
            activeColor: AppColors.primary,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive alerts for new resources and requests'),
            value: settings.notificationsEnabled,
            onChanged: (value) => notifier.toggleNotifications(value),
            activeColor: AppColors.primary,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Font Size',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.text_fields, size: 16),
                    Expanded(
                      child: Slider(
                        value: settings.fontSizeFactor,
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        label: settings.fontSizeFactor.toStringAsFixed(1),
                        onChanged: (value) => notifier.setFontSizeFactor(value),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.text_fields, size: 28),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
