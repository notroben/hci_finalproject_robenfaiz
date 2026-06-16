import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../blocs/focus/focus_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/routines/routines_bloc.dart';
import '../../models/history_log.dart';
import '../../theme/app_theme.dart';
import '../../services/haptics_service.dart';
import '../../services/tts_service.dart';
import 'completion_screen.dart';

class ImmersiveFocusScreen extends StatefulWidget {
  const ImmersiveFocusScreen({super.key});

  @override
  State<ImmersiveFocusScreen> createState() => _ImmersiveFocusScreenState();
}

class _ImmersiveFocusScreenState extends State<ImmersiveFocusScreen> {
  final TtsService _tts = TtsService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentTask();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    _tts.stop();
    super.dispose();
  }

  void _speakCurrentTask() {
    final focusState = context.read<FocusBloc>().state;
    final settingsState = context.read<SettingsBloc>().state;
    final currentTask = focusState.currentTask;

    if (currentTask != null) {
      final speechText = "${currentTask.title}. ${currentTask.description}";
      _tts.speak(speechText, rate: settingsState.ttsSpeechRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;
    final font = settingsState.selectedFont;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.deepForest,
        textTheme: AppTheme.getTextTheme(font, Colors.white),
      ),
      child: Scaffold(
        body: BlocConsumer<FocusBloc, FocusState>(
          listener: (context, focusState) {
            if (!focusState.isSessionFinished) {
              HapticsService.triggerLight();
              _speakCurrentTask();
            } else {
              HapticsService.triggerSuccessPattern();
              _tts.speak(
                "Congratulations! All done.",
                rate: settingsState.ttsSpeechRate,
              );

              final taskCompletionDetails = focusState.taskDurations.entries
                  .map((e) {
                    return {
                      'taskId': e.key,
                      'durationSeconds': e.value,
                      'isSkipped': e.value == 0,
                    };
                  })
                  .toList();

              final newLog = HistoryLog(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: 'local_user',
                routineId: focusState.activeRoutineId,
                routineTitle: focusState.activeRoutine?.title ?? '',
                startedAt: DateTime.parse(focusState.startTimeIso),
                completedAt: DateTime.now(),
                isCompletedFully: focusState.skippedCount == 0,
                skippedTasksCount: focusState.skippedCount,
                taskCompletionDetails: taskCompletionDetails,
              );

              context.read<RoutinesBloc>().add(CompleteRoutineEvent(newLog));

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoutineCompletionScreen(),
                ),
              );
            }
          },
          builder: (context, focusState) {
            final activeRoutine = focusState.activeRoutine;
            final currentTask = focusState.currentTask;

            if (activeRoutine == null || currentTask == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final totalSteps = activeRoutine.tasks.length;
            final activeStepNum = focusState.currentTaskIndex + 1;
            final progressVal = activeStepNum / totalSteps;

            // Timer display builder
            final minutes = focusState.secondsRemaining ~/ 60;
            final seconds = focusState.secondsRemaining % 60;
            final timerString =
                "$minutes:${seconds.toString().padLeft(2, '0')}";

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🌅 ${activeRoutine.title}',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Task $activeStepNum of $totalSteps',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.ochreGold,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪥', style: TextStyle(fontSize: 72)),
                          const SizedBox(height: 24),
                          Text(
                            currentTask.title,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentTask.description,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 18,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white38,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              HapticsService.triggerMedium();
                              context.read<FocusBloc>().add(ToggleTimer());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  focusState.isTimerRunning
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  focusState.isTimerRunning
                                      ? 'Pause Task'
                                      : 'Start Now',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            timerString,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'suggested time',
                            style: TextStyle(
                              fontFamily: font,
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sageGreen,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        HapticsService.triggerHeavy();
                        context.read<FocusBloc>().add(CompleteTaskStep());
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white24),
                        ),
                      ),
                      onPressed: () {
                        HapticsService.triggerMedium();
                        context.read<FocusBloc>().add(SkipTaskStep());
                      },
                      child: Text(
                        'Skip this step',
                        style: TextStyle(
                          fontFamily: font,
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
