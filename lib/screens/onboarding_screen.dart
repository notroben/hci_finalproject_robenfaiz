import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../theme/app_theme.dart';
import 'performer/dashboard_screen.dart';
import 'caregiver/pin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedRole = 'performer';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.sageGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rutini',
                      style: textTheme.headlineLarge?.copyWith(
                        fontFamily: context
                            .watch<SettingsBloc>()
                            .state
                            .selectedFont,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'One routine, one step at a time.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Card options selection
              Text(
                'WHO WILL USE THIS DEVICE?',
                style: textTheme.titleSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Option 1: Performer
              _buildRoleCard(
                context,
                role: 'performer',
                emoji: '🧒',
                title: "I'm following a routine",
                description: 'See daily tasks and complete them step by step',
                isSelected: _selectedRole == 'performer',
              ),
              const SizedBox(height: 16),

              // Option 2: Caregiver
              _buildRoleCard(
                context,
                role: 'caregiver',
                emoji: '🩺',
                title: "I'm a caregiver or therapist",
                description: 'Set up routines, schedules, and track progress',
                isSelected: _selectedRole == 'caregiver',
              ),
              const SizedBox(height: 24),

              // Action button
              ElevatedButton(
                onPressed: () {
                  context.read<SettingsBloc>().add(ToggleRole(_selectedRole));
                  if (_selectedRole == 'performer') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerformerDashboardScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CaregiverPinScreen(),
                      ),
                    );
                  }
                },
                child: Text(
                  _selectedRole == 'performer'
                      ? 'Continue as Performer'
                      : 'Continue as Caregiver',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No account needed to get started',
                style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String emoji,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final font = context.watch<SettingsBloc>().state.selectedFont;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.sageGreen : theme.dividerColor,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: font,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: font,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
