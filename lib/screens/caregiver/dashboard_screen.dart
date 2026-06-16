import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/routines/routines_bloc.dart';
import '../../models/routine.dart';
import '../../theme/app_theme.dart';
import '../onboarding_screen.dart';
import '../accessibility_screen.dart';
import 'editor_screen.dart';
import 'analytics_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
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
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.sageGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.exit_to_app, color: Colors.white, size: 16),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          },
        ),
      ),
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
              if (routinesState is RoutinesLoaded) {
                routines.addAll(routinesState.routines);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Routines',
                            style: textTheme.headlineMedium?.copyWith(
                              fontFamily: font,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Managing: Alex',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontFamily: font,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sageGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          final newRoutine = Routine(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: '',
                            iconPath: '🌅',
                            startTime: '08:00',
                            daysOfWeek: [1, 2, 3, 4, 5],
                            isActive: true,
                            tasks: [],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoutineEditorScreen(
                                routine: newRoutine,
                                isNew: true,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'New',
                          style: TextStyle(
                            fontFamily: font,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'ACTIVE ROUTINES',
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
                        return _buildCaregiverRoutineCard(
                          context,
                          routine: r,
                          font: font,
                        );
                      },
                    ),
                  ),

                  Row(
                    children: [
                      _buildFooterBtn(
                        context,
                        label: 'Analytics',
                        active: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CaregiverAnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFooterBtn(
                        context,
                        label: 'Settings',
                        active: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccessibilityScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFooterBtn(
                        context,
                        label: 'Notes',
                        active: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notes section is coming soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCaregiverRoutineCard(
    BuildContext context, {
    required Routine routine,
    required String font,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineEditorScreen(routine: routine, isNew: false),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
              child: Text(
                routine.iconPath,
                style: const TextStyle(fontSize: 24),
              ),
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
                    '${routine.startTime} - Daily - ${routine.tasks.length} tasks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: font,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: routine.isActive,
              activeColor: AppTheme.sageGreen,
              onChanged: (val) {
                context.read<RoutinesBloc>().add(
                  ToggleRoutineActive(routine.id, val),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBtn(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final font = context.watch<SettingsBloc>().state.selectedFont;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: active
              ? AppTheme.ochreGold.withOpacity(0.2)
              : theme.cardColor,
          foregroundColor: active
              ? AppTheme.ochreGold
              : textTheme.bodyLarge?.color,
          side: BorderSide(
            color: active ? AppTheme.ochreGold : theme.dividerColor,
            width: 1.5,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: active
                ? (theme.brightness == Brightness.dark
                      ? AppTheme.ochreGold
                      : const Color(0xFF9E701C))
                : theme.hintColor,
          ),
        ),
      ),
    );
  }
}
