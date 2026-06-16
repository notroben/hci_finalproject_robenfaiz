class UserProfile {
  final String uid;
  final String role; // 'performer' or 'caregiver'
  final String caregiverPin;
  final String selectedFont; // 'Roboto', 'Atkinson Hyperlegible', 'OpenDyslexic'
  final String themeMode; // 'light', 'dark', 'high_contrast'
  final bool nudgeRemindersEnabled;
  final double ttsSpeechRate;

  UserProfile({
    required this.uid,
    this.role = 'performer',
    this.caregiverPin = '0000',
    this.selectedFont = 'Roboto',
    this.themeMode = 'light',
    this.nudgeRemindersEnabled = true,
    this.ttsSpeechRate = 0.5,
  });

  UserProfile copyWith({
    String? uid,
    String? role,
    String? caregiverPin,
    String? selectedFont,
    String? themeMode,
    bool? nudgeRemindersEnabled,
    double? ttsSpeechRate,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      caregiverPin: caregiverPin ?? this.caregiverPin,
      selectedFont: selectedFont ?? this.selectedFont,
      themeMode: themeMode ?? this.themeMode,
      nudgeRemindersEnabled: nudgeRemindersEnabled ?? this.nudgeRemindersEnabled,
      ttsSpeechRate: ttsSpeechRate ?? this.ttsSpeechRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'caregiverPin': caregiverPin,
      'selectedFont': selectedFont,
      'themeMode': themeMode,
      'nudgeRemindersEnabled': nudgeRemindersEnabled,
      'ttsSpeechRate': ttsSpeechRate,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'performer',
      caregiverPin: map['caregiverPin'] ?? '0000',
      selectedFont: map['selectedFont'] ?? 'Roboto',
      themeMode: map['themeMode'] ?? 'light',
      nudgeRemindersEnabled: map['nudgeRemindersEnabled'] ?? true,
      ttsSpeechRate: (map['ttsSpeechRate'] ?? 0.5).toDouble(),
    );
  }
}
