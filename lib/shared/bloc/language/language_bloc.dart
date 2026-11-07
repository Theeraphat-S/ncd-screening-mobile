import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ncd_screening_mobile/shared/bloc/language/language_event.dart';
import 'package:ncd_screening_mobile/shared/bloc/language/language_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thai is the default: the app is used by Thai health staff and villagers.
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _prefKey = 'app_locale';
  static const Locale defaultLocale = Locale('th');
  static const List<String> _supported = ['th', 'en'];

  LanguageBloc() : super(const LanguageState(defaultLocale)) {
    on<InitializeLanguageEvent>(_initializeLanguage);
    on<ChangeLanguageEvent>(_changeLanguage);
    on<ToggleDropdownEvent>(_toggleDropdown);
  }

  Future<void> _initializeLanguage(
    InitializeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      final locale = (saved != null && _supported.contains(saved))
          ? Locale(saved)
          : defaultLocale;
      Intl.defaultLocale = locale.languageCode;
      emit(state.copyWith(locale: locale));
    } catch (e) {
      // Storage unavailable: keep the default Thai locale.
      debugPrint('Error during language initialization: $e');
    }
  }

  Future<void> _changeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      Intl.defaultLocale = event.locale.languageCode;
      emit(state.copyWith(locale: event.locale));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, event.locale.languageCode);
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  void _toggleDropdown(ToggleDropdownEvent event, Emitter<LanguageState> emit) {
    emit(state.copyWith(isDropdownOpen: event.isOpen));
  }
}
