import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LanguageState extends Equatable {
  final Locale locale;
  final bool isDropdownOpen;

  const LanguageState(this.locale, {this.isDropdownOpen = false});

  LanguageState copyWith({Locale? locale, bool? isDropdownOpen}) {
    return LanguageState(
      locale ?? this.locale,
      isDropdownOpen: isDropdownOpen ?? this.isDropdownOpen,
    );
  }

  @override
  List<Object> get props => [locale, isDropdownOpen];
}
