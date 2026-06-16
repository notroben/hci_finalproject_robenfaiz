import 'task.dart';

class Routine {
  final String id;
  final String title;
  final String iconPath; // Emojis like '🌅', '🥪', '🎒', '🌙' are used as icons
  final String startTime; // Format: 'HH:MM'
  final List<int> daysOfWeek; // 1 = Monday, ..., 7 = Sunday
  final bool isActive;
  final List<Task> tasks;

  Routine({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.startTime,
    required this.daysOfWeek,
    this.isActive = true,
    this.tasks = const [],
  });

  Routine copyWith({
    String? id,
    String? title,
    String? iconPath,
    String? startTime,
    List<int>? daysOfWeek,
    bool? isActive,
    List<Task>? tasks,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      iconPath: iconPath ?? this.iconPath,
      startTime: startTime ?? this.startTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'iconPath': iconPath,
      'startTime': startTime,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      iconPath: map['iconPath'] ?? '🌅',
      startTime: map['startTime'] ?? '08:00',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      isActive: map['isActive'] ?? true,
      tasks: (map['tasks'] as List? ?? []).map((t) => Task.fromMap(t)).toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
    );
  }
}
