import 'package:hydrated_bloc/hydrated_bloc.dart';

// Events
abstract class SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final String? font;
  final String? theme;
  final bool? nudge;
  final double? speechRate;

  UpdateSettings({this.font, this.theme, this.nudge, this.speechRate});
}

class ToggleRole extends SettingsEvent {
  final String newRole;
  ToggleRole(this.newRole);
}

// State
class SettingsState {
  final String selectedFont; // 'Roboto', 'Atkinson Hyperlegible', 'OpenDyslexic'
  final String themeMode; // 'light', 'dark', 'high_contrast'
  final bool nudgeRemindersEnabled;
  final double ttsSpeechRate;
  final String activeRole; // 'performer' or 'caregiver'
  final String caregiverPin;

  SettingsState({
    this.selectedFont = 'Roboto',
    this.themeMode = 'light',
    this.nudgeRemindersEnabled = true,
    this.ttsSpeechRate = 0.5,
    this.activeRole = 'performer',
    this.caregiverPin = '0000',
  });

  SettingsState copyWith({
    String? selectedFont,
    String? themeMode,
    bool? nudgeRemindersEnabled,
    double? ttsSpeechRate,
    String? activeRole,
    String? caregiverPin,
  }) {
    return SettingsState(
      selectedFont: selectedFont ?? this.selectedFont,
      themeMode: themeMode ?? this.themeMode,
      nudgeRemindersEnabled: nudgeRemindersEnabled ?? this.nudgeRemindersEnabled,
      ttsSpeechRate: ttsSpeechRate ?? this.ttsSpeechRate,
      activeRole: activeRole ?? this.activeRole,
      caregiverPin: caregiverPin ?? this.caregiverPin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedFont': selectedFont,
      'themeMode': themeMode,
      'nudgeRemindersEnabled': nudgeRemindersEnabled,
      'ttsSpeechRate': ttsSpeechRate,
      'activeRole': activeRole,
      'caregiverPin': caregiverPin,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      selectedFont: map['selectedFont'] ?? 'Roboto',
      themeMode: map['themeMode'] ?? 'light',
      nudgeRemindersEnabled: map['nudgeRemindersEnabled'] ?? true,
      ttsSpeechRate: (map['ttsSpeechRate'] ?? 0.5).toDouble(),
      activeRole: map['activeRole'] ?? 'performer',
      caregiverPin: map['caregiverPin'] ?? '0000',
    );
  }
}

// Bloc
class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<UpdateSettings>((event, emit) {
      emit(state.copyWith(
        selectedFont: event.font,
        themeMode: event.theme,
        nudgeRemindersEnabled: event.nudge,
        ttsSpeechRate: event.speechRate,
      ));
    });

    on<ToggleRole>((event, emit) {
      emit(state.copyWith(activeRole: event.newRole));
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toMap();
  }
}
