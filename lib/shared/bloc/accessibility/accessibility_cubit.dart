import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccessibilityState extends Equatable {
  final bool isElderlyMode;
  final double textScaleFactor;
  final bool isHighContrast;

  const AccessibilityState({
    this.isElderlyMode = false,
    this.textScaleFactor = 1.0,
    this.isHighContrast = false,
  });

  AccessibilityState copyWith({
    bool? isElderlyMode,
    double? textScaleFactor,
    bool? isHighContrast,
  }) {
    return AccessibilityState(
      isElderlyMode: isElderlyMode ?? this.isElderlyMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }

  @override
  List<Object?> get props => [isElderlyMode, textScaleFactor, isHighContrast];
}

class AccessibilityCubit extends Cubit<AccessibilityState> {
  static const double defaultTextScale = 1.0;
  static const double elderlyTextScale = 1.35;
  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.60;
  static const double scaleStep = 0.10;

  AccessibilityCubit() : super(const AccessibilityState());

  void toggleElderlyMode() {
    final next = !state.isElderlyMode;
    emit(
      state.copyWith(
        isElderlyMode: next,
        textScaleFactor: next ? elderlyTextScale : defaultTextScale,
      ),
    );
  }

  void setElderlyMode(bool enabled) {
    emit(
      state.copyWith(
        isElderlyMode: enabled,
        textScaleFactor: enabled ? elderlyTextScale : defaultTextScale,
      ),
    );
  }

  void toggleHighContrast() {
    emit(state.copyWith(isHighContrast: !state.isHighContrast));
  }

  void increaseTextScale() {
    _adjustTextScale(scaleStep);
  }

  void decreaseTextScale() {
    _adjustTextScale(-scaleStep);
  }

  void _adjustTextScale(double delta) {
    final newScale = (state.textScaleFactor + delta).clamp(
      minTextScale,
      maxTextScale,
    );
    final rounded = double.parse(newScale.toStringAsFixed(2));
    emit(
      state.copyWith(
        textScaleFactor: rounded,
        isElderlyMode: rounded == elderlyTextScale,
      ),
    );
  }

  void resetAccessibility() {
    emit(const AccessibilityState());
  }
}
