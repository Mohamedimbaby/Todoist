import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// State for language cubit
class LanguageState {
  final Locale locale;

  const LanguageState({required this.locale});

  LanguageState copyWith({Locale? locale}) {
    return LanguageState(locale: locale ?? this.locale);
  }
}

/// Cubit for managing app language
class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState(locale: Locale('en'))) {
    _loadLanguage();
  }

  static const _supportedLocales = [
    Locale('en'),
    Locale('de'),
  ];

  List<Locale> get supportedLocales => _supportedLocales;

  Future<void> _loadLanguage() async {
    try {
      final box = await Hive.openBox(AppConstants.settingsBox);
      final code = box.get(AppConstants.languageKey, defaultValue: 'en');
      emit(LanguageState(locale: Locale(code as String)));
    } catch (_) {
      // Keep default
    }
  }

  /// Set language
  Future<void> setLanguage(Locale locale) async {
    emit(state.copyWith(locale: locale));
    try {
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put(AppConstants.languageKey, locale.languageCode);
    } catch (_) {
      // Ignore save errors
    }
  }

  /// Get language name from locale
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      default:
        return locale.languageCode;
    }
  }

  /// Get flag emoji from locale
  String getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'de':
        return '🇩🇪';
      default:
        return '🌐';
    }
  }
}

