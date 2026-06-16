class HistoryLog {
  final String id;
  final String userId;
  final String routineId;
  final String routineTitle;
  final DateTime startedAt;
  final DateTime completedAt;
  final bool isCompletedFully;
  final int skippedTasksCount;
  final List<Map<String, dynamic>> taskCompletionDetails; // List of map with 'taskId', 'durationSeconds', 'isSkipped'

  HistoryLog({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.routineTitle,
    required this.startedAt,
    required this.completedAt,
    required this.isCompletedFully,
    required this.skippedTasksCount,
    required this.taskCompletionDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'routineId': routineId,
      'routineTitle': routineTitle,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'isCompletedFully': isCompletedFully,
      'skippedTasksCount': skippedTasksCount,
      'taskCompletionDetails': taskCompletionDetails,
    };
  }

  factory HistoryLog.fromMap(Map<String, dynamic> map) {
    return HistoryLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      routineId: map['routineId'] ?? '',
      routineTitle: map['routineTitle'] ?? '',
      startedAt: DateTime.parse(map['startedAt'] ?? DateTime.now().toIso8601String()),
      completedAt: DateTime.parse(map['completedAt'] ?? DateTime.now().toIso8601String()),
      isCompletedFully: map['isCompletedFully'] ?? false,
      skippedTasksCount: map['skippedTasksCount'] ?? 0,
      taskCompletionDetails: List<Map<String, dynamic>>.from(map['taskCompletionDetails'] ?? []),
    );
  }
}
