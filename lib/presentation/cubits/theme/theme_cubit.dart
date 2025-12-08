import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// State for theme cubit
class ThemeState {
  final ThemeMode mode;

  const ThemeState({required this.mode});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
}

/// Cubit for managing app theme
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(mode: ThemeMode.system)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(AppConstants.settingsBox);
      final modeIndex = box.get(AppConstants.themeKey, defaultValue: 0) as int;
      emit(ThemeState(mode: ThemeMode.values[modeIndex]));
    } catch (_) {
      // Keep default
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    try {
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put(AppConstants.themeKey, mode.index);
    } catch (_) {
      // Ignore save errors
    }
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode =
        state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

