import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../models/routine.dart';
import '../../models/task.dart';

// Events
abstract class FocusEvent {}

class StartFocusSession extends FocusEvent {
  final Routine routine;
  StartFocusSession(this.routine);
}

class ToggleTimer extends FocusEvent {}

class TickSeconds extends FocusEvent {}

class CompleteTaskStep extends FocusEvent {}

class SkipTaskStep extends FocusEvent {}

class CancelFocusSession extends FocusEvent {}

// States
class FocusState {
  final String activeRoutineId;
  final Routine? activeRoutine;
  final int currentTaskIndex;
  final int secondsRemaining;
  final bool isTimerRunning;
  final int skippedCount;
  final bool isSessionFinished;
  final Map<String, int> taskDurations; // Maps taskId -> elapsed seconds
  final String startTimeIso;

  FocusState({
    this.activeRoutineId = '',
    this.activeRoutine,
    this.currentTaskIndex = 0,
    this.secondsRemaining = 0,
    this.isTimerRunning = false,
    this.skippedCount = 0,
    this.isSessionFinished = false,
    this.taskDurations = const {},
    this.startTimeIso = '',
  });

  Task? get currentTask {
    if (activeRoutine == null ||
        currentTaskIndex >= activeRoutine!.tasks.length) {
      return null;
    }
    return activeRoutine!.tasks[currentTaskIndex];
  }

  FocusState copyWith({
    String? activeRoutineId,
    Routine? activeRoutine,
    int? currentTaskIndex,
    int? secondsRemaining,
    bool? isTimerRunning,
    int? skippedCount,
    bool? isSessionFinished,
    Map<String, int>? taskDurations,
    String? startTimeIso,
  }) {
    return FocusState(
      activeRoutineId: activeRoutineId ?? this.activeRoutineId,
      activeRoutine: activeRoutine ?? this.activeRoutine,
      currentTaskIndex: currentTaskIndex ?? this.currentTaskIndex,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      skippedCount: skippedCount ?? this.skippedCount,
      isSessionFinished: isSessionFinished ?? this.isSessionFinished,
      taskDurations: taskDurations ?? this.taskDurations,
      startTimeIso: startTimeIso ?? this.startTimeIso,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeRoutineId': activeRoutineId,
      'activeRoutine': activeRoutine?.toMap(),
      'currentTaskIndex': currentTaskIndex,
      'secondsRemaining': secondsRemaining,
      'isTimerRunning': isTimerRunning,
      'skippedCount': skippedCount,
      'isSessionFinished': isSessionFinished,
      'taskDurations': taskDurations,
      'startTimeIso': startTimeIso,
    };
  }

  factory FocusState.fromMap(Map<String, dynamic> map) {
    return FocusState(
      activeRoutineId: map['activeRoutineId'] ?? '',
      activeRoutine: map['activeRoutine'] != null
          ? Routine.fromMap(map['activeRoutine'])
          : null,
      currentTaskIndex: map['currentTaskIndex'] ?? 0,
      secondsRemaining: map['secondsRemaining'] ?? 0,
      isTimerRunning: map['isTimerRunning'] ?? false,
      skippedCount: map['skippedCount'] ?? 0,
      isSessionFinished: map['isSessionFinished'] ?? false,
      taskDurations: Map<String, int>.from(map['taskDurations'] ?? {}),
      startTimeIso: map['startTimeIso'] ?? '',
    );
  }
}

// Bloc implementation
class FocusBloc extends HydratedBloc<FocusEvent, FocusState> {
  Timer? _timer;

  FocusBloc() : super(FocusState()) {
    on<StartFocusSession>((event, emit) {
      _timer?.cancel();
      final firstTask = event.routine.tasks.isNotEmpty
          ? event.routine.tasks.first
          : null;
      emit(
        FocusState(
          activeRoutineId: event.routine.id,
          activeRoutine: event.routine,
          currentTaskIndex: 0,
          secondsRemaining: firstTask?.durationSeconds ?? 0,
          isTimerRunning: false,
          skippedCount: 0,
          isSessionFinished: false,
          taskDurations: {},
          startTimeIso: DateTime.now().toIso8601String(),
        ),
      );
    });

    on<ToggleTimer>((event, emit) {
      if (state.activeRoutine == null || state.isSessionFinished) return;

      if (state.isTimerRunning) {
        _timer?.cancel();
        emit(state.copyWith(isTimerRunning: false));
      } else {
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          add(TickSeconds());
        });
        emit(state.copyWith(isTimerRunning: true));
      }
    });

    on<TickSeconds>((event, emit) {
      if (state.secondsRemaining <= 1) {
        _timer?.cancel();
        add(CompleteTaskStep());
      } else {
        final currentTask = state.currentTask;
        if (currentTask != null) {
          final updatedDurations = Map<String, int>.from(state.taskDurations);
          final currentDuration = updatedDurations[currentTask.id] ?? 0;
          updatedDurations[currentTask.id] = currentDuration + 1;

          emit(
            state.copyWith(
              secondsRemaining: state.secondsRemaining - 1,
              taskDurations: updatedDurations,
            ),
          );
        }
      }
    });

    on<CompleteTaskStep>((event, emit) {
      _timer?.cancel();
      final currentTask = state.currentTask;
      if (currentTask == null || state.activeRoutine == null) return;

      final nextIndex = state.currentTaskIndex + 1;
      final isFinished = nextIndex >= state.activeRoutine!.tasks.length;

      if (isFinished) {
        emit(
          state.copyWith(
            currentTaskIndex: nextIndex,
            isTimerRunning: false,
            isSessionFinished: true,
            secondsRemaining: 0,
          ),
        );
      } else {
        final nextTask = state.activeRoutine!.tasks[nextIndex];
        emit(
          state.copyWith(
            currentTaskIndex: nextIndex,
            isTimerRunning: false,
            secondsRemaining: nextTask.durationSeconds,
          ),
        );
      }
    });

    on<SkipTaskStep>((event, emit) {
      _timer?.cancel();
      final currentTask = state.currentTask;
      if (currentTask == null || state.activeRoutine == null) return;

      final updatedDurations = Map<String, int>.from(state.taskDurations);
      updatedDurations[currentTask.id] = 0; // 0 duration means skipped

      final nextIndex = state.currentTaskIndex + 1;
      final isFinished = nextIndex >= state.activeRoutine!.tasks.length;

      if (isFinished) {
        emit(
          state.copyWith(
            currentTaskIndex: nextIndex,
            skippedCount: state.skippedCount + 1,
            isTimerRunning: false,
            isSessionFinished: true,
            secondsRemaining: 0,
            taskDurations: updatedDurations,
          ),
        );
      } else {
        final nextTask = state.activeRoutine!.tasks[nextIndex];
        emit(
          state.copyWith(
            currentTaskIndex: nextIndex,
            skippedCount: state.skippedCount + 1,
            isTimerRunning: false,
            secondsRemaining: nextTask.durationSeconds,
            taskDurations: updatedDurations,
          ),
        );
      }
    });

    on<CancelFocusSession>((event, emit) {
      _timer?.cancel();
      emit(FocusState());
    });
  }

  @override
  FocusState? fromJson(Map<String, dynamic> json) {
    final loadedState = FocusState.fromMap(json);
    if (loadedState.isTimerRunning &&
        loadedState.activeRoutine != null &&
        !loadedState.isSessionFinished) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(TickSeconds());
      });
    }
    return loadedState;
  }

  @override
  Map<String, dynamic>? toJson(FocusState state) {
    return state.toMap();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
