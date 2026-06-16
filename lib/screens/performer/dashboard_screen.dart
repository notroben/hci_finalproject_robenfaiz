import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/routines/routines_bloc.dart';
import '../../blocs/focus/focus_bloc.dart';
import '../../models/routine.dart';
import '../../theme/app_theme.dart';
import '../caregiver/pin_screen.dart';
import '../accessibility_screen.dart';
import 'focus_screen.dart';

class PerformerDashboardScreen extends StatefulWidget {
  const PerformerDashboardScreen({super.key});

  @override
  State<PerformerDashboardScreen> createState() =>
      _PerformerDashboardScreenState();
}

class _PerformerDashboardScreenState extends State<PerformerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RoutinesBloc>().add(LoadRoutines());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = context.watch<SettingsBloc>().state;
    final font = state.selectedFont;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: BlocBuilder<RoutinesBloc, RoutinesState>(
            builder: (context, routinesState) {
              if (routinesState is RoutinesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (routinesState is RoutinesError) {
                return Center(child: Text(routinesState.message));
              }

              final List<Routine> routines = [];
              final List<String> completedIds = [];

              if (routinesState is RoutinesLoaded) {
                routines.addAll(routinesState.routines);
                final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                for (var log in routinesState.historyLogs) {
                  final logDay = DateFormat(
                    'yyyy-MM-dd',
                  ).format(log.completedAt);
                  if (logDay == today && log.isCompletedFully) {
                    completedIds.add(log.routineId);
                  }
                }
              }

              final activeRoutines = routines.where((r) => r.isActive).toList();

              Routine? nextUpRoutine;
              if (activeRoutines.isNotEmpty) {
                nextUpRoutine = activeRoutines.firstWhere(
                  (r) => !completedIds.contains(r.id),
                  orElse: () => activeRoutines.first,
                );
              }

              final todayName = DateFormat('EEEE').format(DateTime.now());
              final totalToday = activeRoutines.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Good Morning',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontFamily: font,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('🌤️', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          Text(
                            '$todayName - $totalToday routines today',
                            style: textTheme.bodyMedium?.copyWith(
                              fontFamily: font,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 22,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CaregiverPinScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Next Up Hero Card
                  if (nextUpRoutine != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.sageGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEXT UP • STARTING IN 4 MIN',
                            style: textTheme.labelSmall?.copyWith(
                              fontFamily: font,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                nextUpRoutine.iconPath,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nextUpRoutine.title,
                                      style: textTheme.titleLarge?.copyWith(
                                        fontFamily: font,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${nextUpRoutine.tasks.length} tasks ~ ${nextUpRoutine.tasks.fold(0, (sum, t) => sum + t.durationSeconds) ~/ 60} min',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontFamily: font,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              context.read<FocusBloc>().add(
                                StartFocusSession(nextUpRoutine!),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ImmersiveFocusScreen(),
                                ),
                              );
                            },
                            child: const Center(
                              child: Text(
                                'Start Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Today's Routines Section
                  Text(
                    'TODAY\'S ROUTINES',
                    style: textTheme.titleSmall?.copyWith(
                      fontFamily: font,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: routines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = routines[index];
                        final isDone = completedIds.contains(r.id);
                        final isNext = nextUpRoutine?.id == r.id;

                        String statusLabel = 'upcoming';
                        Color statusColor = const Color(
                          0xFFE3B04B,
                        ); // Ochre tag

                        if (isDone) {
                          statusLabel = 'done';
                          statusColor = AppTheme.sageGreen;
                        } else if (!r.isActive) {
                          statusLabel = 'later';
                          statusColor = Colors.grey;
                        } else if (!isNext) {
                          statusLabel = 'later';
                          statusColor = Colors.grey;
                        }

                        return _buildRoutineRow(
                          context,
                          routine: r,
                          statusLabel: statusLabel,
                          statusColor: statusColor,
                          font: font,
                        );
                      },
                    ),
                  ),

                  // Bottom Settings Shortcut Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccessibilityScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.accessibility_new_rounded),
                        const SizedBox(width: 8),
                        Text(
                          'Accessibility Settings',
                          style: TextStyle(
                            fontFamily: font,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineRow(
    BuildContext context, {
    required Routine routine,
    required String statusLabel,
    required Color statusColor,
    required String font,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Text(routine.iconPath, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: font,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${routine.startTime} - ${routine.tasks.length} tasks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: font,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontFamily: font,
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
