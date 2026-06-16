import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/routine.dart';
import '../models/task.dart';
import '../models/history_log.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  FirebaseFirestore? _firestore;
  bool _useMock = true;

  // Local caching arrays for mock fallback data
  final List<Routine> _mockRoutines = [];
  final List<HistoryLog> _mockLogs = [];

  DatabaseService._internal() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _firestore!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        _useMock = false;
      } else {
        _useMock = true;
        _loadMockData();
      }
    } catch (e) {
      _useMock = true;
      _loadMockData();
    }
  }

  void _loadMockData() {
    if (_mockRoutines.isNotEmpty) return;

    _mockRoutines.addAll([
      Routine(
        id: 'r1',
        title: 'Morning Routine',
        iconPath: '🌅',
        startTime: '07:00',
        daysOfWeek: [1, 2, 3, 4, 5],
        isActive: true,
        tasks: [
          Task(
            id: 't1_1',
            title: 'Take a shower',
            description: 'Take a fresh shower for 10 minutes.',
            orderIndex: 0,
            durationSeconds: 600,
          ),
          Task(
            id: 't1_2',
            title: 'Brush your teeth',
            description:
                'Use circular motions for 2 minutes. Don\'t forget the back teeth.',
            orderIndex: 1,
            durationSeconds: 120,
          ),
          Task(
            id: 't1_3',
            title: 'Get dressed',
            description: 'Put on your school uniform.',
            orderIndex: 2,
            durationSeconds: 300,
          ),
        ],
      ),
      Routine(
        id: 'r2',
        title: 'Breakfast Prep',
        iconPath: '🥪',
        startTime: '08:30',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        isActive: true,
        tasks: [
          Task(
            id: 't2_1',
            title: 'Wash hands',
            description: 'Wash hands thoroughly with soap for 20 seconds.',
            orderIndex: 0,
            durationSeconds: 20,
          ),
          Task(
            id: 't2_2',
            title: 'Make toast',
            description: 'Toast bread slices and apply butter or jam.',
            orderIndex: 1,
            durationSeconds: 180,
          ),
        ],
      ),
      Routine(
        id: 'r3',
        title: 'Get Ready for School',
        iconPath: '🎒',
        startTime: '07:45',
        daysOfWeek: [1, 2, 3, 4, 5],
        isActive: false,
        tasks: [
          Task(
            id: 't3_1',
            title: 'Pack bag',
            description: 'Check your schedule and pack all books.',
            orderIndex: 0,
            durationSeconds: 300,
          ),
        ],
      ),
      Routine(
        id: 'r4',
        title: 'Wind Down',
        iconPath: '🌙',
        startTime: '20:00',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        isActive: true,
        tasks: [
          Task(
            id: 't4_1',
            title: 'Read a book',
            description: 'Read a chapter of your favorite book.',
            orderIndex: 0,
            durationSeconds: 900,
          ),
          Task(
            id: 't4_2',
            title: 'Turn off screens',
            description: 'Put phone to charge and turn off all monitors.',
            orderIndex: 1,
            durationSeconds: 60,
          ),
        ],
      ),
    ]);

    final now = DateTime.now();
    for (int i = 7; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      bool completed = day.weekday <= 5;
      _mockLogs.add(
        HistoryLog(
          id: 'log_$i',
          userId: 'local_user',
          routineId: 'r1',
          routineTitle: 'Morning Routine',
          startedAt: day.subtract(const Duration(minutes: 20)),
          completedAt: day,
          isCompletedFully: completed,
          skippedTasksCount: completed ? 0 : 1,
          taskCompletionDetails: [
            {'taskId': 't1_1', 'durationSeconds': 580, 'isSkipped': false},
            {'taskId': 't1_2', 'durationSeconds': 120, 'isSkipped': false},
            {'taskId': 't1_3', 'durationSeconds': 290, 'isSkipped': !completed},
          ],
        ),
      );
    }
  }

  Future<List<Routine>> getRoutines() async {
    if (_useMock) {
      return List.from(_mockRoutines);
    }

    try {
      final snapshot = await _firestore!.collection('routines').get();
      return snapshot.docs
          .map((doc) => Routine.fromMap(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      return List.from(_mockRoutines);
    }
  }

  Future<void> saveRoutine(Routine routine) async {
    if (_useMock) {
      final index = _mockRoutines.indexWhere((r) => r.id == routine.id);
      if (index != -1) {
        _mockRoutines[index] = routine;
      } else {
        _mockRoutines.add(routine);
      }
      return;
    }

    try {
      await _firestore!
          .collection('routines')
          .doc(routine.id)
          .set(routine.toMap());
    } catch (e) {
      final index = _mockRoutines.indexWhere((r) => r.id == routine.id);
      if (index != -1) _mockRoutines[index] = routine;
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    if (_useMock) {
      _mockRoutines.removeWhere((r) => r.id == routineId);
      return;
    }

    try {
      await _firestore!.collection('routines').doc(routineId).delete();
    } catch (e) {
      _mockRoutines.removeWhere((r) => r.id == routineId);
    }
  }

  Future<List<HistoryLog>> getHistoryLogs() async {
    if (_useMock) {
      return List.from(_mockLogs);
    }

    try {
      final snapshot = await _firestore!
          .collection('history_logs')
          .orderBy('completedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => HistoryLog.fromMap(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      return List.from(_mockLogs);
    }
  }

  Future<void> logRoutineExecution(HistoryLog log) async {
    if (_useMock) {
      _mockLogs.add(log);
      return;
    }

    try {
      await _firestore!.collection('history_logs').doc(log.id).set(log.toMap());
    } catch (e) {
      _mockLogs.add(log);
    }
  }
}
