import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/focus/focus_bloc.dart';
import '../../theme/app_theme.dart';
import 'dashboard_screen.dart';

class RoutineCompletionScreen extends StatelessWidget {
  const RoutineCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = context.watch<SettingsBloc>().state;
    final focusState = context.read<FocusBloc>().state;
    final font = state.selectedFont;

    final completedRoutine = focusState.activeRoutine;
    final routineTitle = completedRoutine?.title ?? 'Routine';
    final totalTasks = completedRoutine?.tasks.length ?? 0;

    // Calculate total time spent
    final totalSeconds = focusState.taskDurations.values.fold(
      0,
      (sum, val) => sum + val,
    );
    final totalMinutesStr = "${(totalSeconds / 60).toStringAsFixed(0)}m";
    final skippedCount = focusState.skippedCount;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.sageGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.sageGreen, width: 3),
                  ),
                  child: const Center(
                    child: Text('⭐', style: TextStyle(fontSize: 54)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'All done!',
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: font,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You completed all your $routineTitle.\nGreat work today.',
                style: textTheme.bodyLarge?.copyWith(
                  fontFamily: font,
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    context,
                    value: '$totalTasks',
                    label: 'tasks done',
                    font: font,
                  ),
                  _buildStatCard(
                    context,
                    value: totalMinutesStr,
                    label: 'total time',
                    font: font,
                  ),
                  _buildStatCard(
                    context,
                    value: '$skippedCount',
                    label: 'skipped',
                    font: font,
                  ),
                ],
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.ochreGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.ochreGold, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A kind note from your caregiver:',
                      style: textTheme.titleSmall?.copyWith(
                        fontFamily: font,
                        color: theme.brightness == Brightness.dark
                            ? AppTheme.ochreGold
                            : const Color(0xFF9E701C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Amazing job this morning! Keep it up, I\'m proud of you."',
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: font,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  context.read<FocusBloc>().add(CancelFocusSession());
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerformerDashboardScreen(),
                    ),
                  );
                },
                child: Text(
                  'Back to home',
                  style: TextStyle(
                    fontFamily: font,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required String font,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: font,
              color: AppTheme.sageGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: font,
              color: theme.hintColor,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
