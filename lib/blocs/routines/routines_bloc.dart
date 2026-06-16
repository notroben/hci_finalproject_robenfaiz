import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/routine.dart';
import '../../models/history_log.dart';
import '../../services/database_service.dart';

// Events
abstract class RoutinesEvent {}

class LoadRoutines extends RoutinesEvent {}

class ToggleRoutineActive extends RoutinesEvent {
  final String routineId;
  final bool isActive;
  ToggleRoutineActive(this.routineId, this.isActive);
}

class SaveRoutineEvent extends RoutinesEvent {
  final Routine routine;
  SaveRoutineEvent(this.routine);
}

class DeleteRoutineEvent extends RoutinesEvent {
  final String routineId;
  DeleteRoutineEvent(this.routineId);
}

class CompleteRoutineEvent extends RoutinesEvent {
  final HistoryLog log;
  CompleteRoutineEvent(this.log);
}

// States
abstract class RoutinesState {}

class RoutinesLoading extends RoutinesState {}

class RoutinesLoaded extends RoutinesState {
  final List<Routine> routines;
  final List<HistoryLog> historyLogs;
  RoutinesLoaded({required this.routines, required this.historyLogs});
}

class RoutinesError extends RoutinesState {
  final String message;
  RoutinesError(this.message);
}

// Bloc
class RoutinesBloc extends Bloc<RoutinesEvent, RoutinesState> {
  final DatabaseService _db = DatabaseService();

  RoutinesBloc() : super(RoutinesLoading()) {
    on<LoadRoutines>((event, emit) async {
      emit(RoutinesLoading());
      try {
        final routines = await _db.getRoutines();
        final logs = await _db.getHistoryLogs();
        emit(RoutinesLoaded(routines: routines, historyLogs: logs));
      } catch (e) {
        emit(RoutinesError("Failed to load routines: ${e.toString()}"));
      }
    });

    on<ToggleRoutineActive>((event, emit) async {
      if (state is RoutinesLoaded) {
        final current = state as RoutinesLoaded;
        final index = current.routines.indexWhere((r) => r.id == event.routineId);
        if (index != -1) {
          final updated = current.routines[index].copyWith(isActive: event.isActive);
          await _db.saveRoutine(updated);
          add(LoadRoutines()); // Reload
        }
      }
    });

    on<SaveRoutineEvent>((event, emit) async {
      await _db.saveRoutine(event.routine);
      add(LoadRoutines());
    });

    on<DeleteRoutineEvent>((event, emit) async {
      await _db.deleteRoutine(event.routineId);
      add(LoadRoutines());
    });

    on<CompleteRoutineEvent>((event, emit) async {
      await _db.logRoutineExecution(event.log);
      add(LoadRoutines());
    });
  }
}
