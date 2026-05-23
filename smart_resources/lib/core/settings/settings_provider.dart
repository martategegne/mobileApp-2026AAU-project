import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final double fontSizeFactor;

  const SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.fontSizeFactor = 1.0,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    double? fontSizeFactor,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final userId = ref.watch(authNotifierProvider).user?.id;
    _loadSettings(userId);
    return const SettingsState();
  }

  static const _darkModeKey = 'isDarkMode';
  static const _notificationsKey = 'notificationsEnabled';
  static const _fontSizeKey = 'fontSizeFactor';

  String _prefKey(String key, String? userId) {
    return userId != null ? 'user_${userId}_$key' : 'global_$key';
  }

  Future<void> _loadSettings(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isDarkMode: prefs.getBool(_prefKey(_darkModeKey, userId)) ?? false,
      notificationsEnabled: prefs.getBool(_prefKey(_notificationsKey, userId)) ?? true,
      fontSizeFactor: prefs.getDouble(_prefKey(_fontSizeKey, userId)) ?? 1.0,
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(authNotifierProvider).user?.id;
    await prefs.setBool(_prefKey(_darkModeKey, userId), value);
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(authNotifierProvider).user?.id;
    await prefs.setBool(_prefKey(_notificationsKey, userId), value);
  }

  Future<void> setFontSizeFactor(double value) async {
    state = state.copyWith(fontSizeFactor: value);
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(authNotifierProvider).user?.id;
    await prefs.setDouble(_prefKey(_fontSizeKey, userId), value);
  }
}
