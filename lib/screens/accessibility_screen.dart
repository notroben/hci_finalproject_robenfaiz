import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../theme/app_theme.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final settingsBloc = context.read<SettingsBloc>();
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
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility',
              style: textTheme.headlineSmall?.copyWith(fontFamily: font),
            ),
            Text(
              'Settings sync to all your devices',
              style: textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontFamily: font,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(context, 'READING FONT'),
            const SizedBox(height: 12),
            _buildFontOption(
              context,
              fontName: 'Atkinson Hyperlegible',
              description: 'Clear, balanced, highly readable typeface',
              isSelected:
                  state.selectedFont == 'Atkinson Hyperlegible' ||
                  state.selectedFont == 'Roboto',
              onTap: () {
                settingsBloc.add(UpdateSettings(font: 'Atkinson Hyperlegible'));
              },
            ),
            const SizedBox(height: 12),
            _buildFontOption(
              context,
              fontName: 'OpenDyslexic',
              description:
                  'Unique weighted letters designed for dyslexia support',
              isSelected: state.selectedFont == 'OpenDyslexic',
              onTap: () {
                settingsBloc.add(UpdateSettings(font: 'OpenDyslexic'));
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'COLOUR THEME'),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              label: 'Light',
              description: 'Warm bone background',
              isSelected: state.themeMode == 'light',
              onChanged: (val) {
                if (val) settingsBloc.add(UpdateSettings(theme: 'light'));
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              label: 'Dark',
              description: 'Soft dark background',
              isSelected: state.themeMode == 'dark',
              onChanged: (val) {
                if (val) settingsBloc.add(UpdateSettings(theme: 'dark'));
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              label: 'High contrast',
              description: 'Pure black, bold edges',
              isSelected: state.themeMode == 'high_contrast',
              onChanged: (val) {
                if (val)
                  settingsBloc.add(UpdateSettings(theme: 'high_contrast'));
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'NOTIFICATIONS'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gentle nudge reminders',
                          style: textTheme.titleMedium?.copyWith(
                            fontFamily: font,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Soft sound only, no jarring alerts',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontFamily: font,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.nudgeRemindersEnabled,
                    activeColor: AppTheme.sageGreen,
                    onChanged: (val) {
                      settingsBloc.add(UpdateSettings(nudge: val));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'VOICE READING SPEED'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Slow',
                        style: textTheme.bodySmall?.copyWith(fontFamily: font),
                      ),
                      Text(
                        '${state.ttsSpeechRate}x - gentle',
                        style: textTheme.labelLarge?.copyWith(
                          fontFamily: font,
                          color: AppTheme.sageGreen,
                        ),
                      ),
                      Text(
                        'Fast',
                        style: textTheme.bodySmall?.copyWith(fontFamily: font),
                      ),
                    ],
                  ),
                  Slider(
                    value: state.ttsSpeechRate,
                    min: 0.25,
                    max: 1.0,
                    divisions: 3,
                    activeColor: AppTheme.sageGreen,
                    onChanged: (val) {
                      settingsBloc.add(UpdateSettings(speechRate: val));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final font = context.watch<SettingsBloc>().state.selectedFont;
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontFamily: font,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.hintColor,
      ),
    );
  }

  Widget _buildFontOption(
    BuildContext context, {
    required String fontName,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.sageGreen : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fontName,
              style: TextStyle(
                fontFamily: fontName == 'OpenDyslexic'
                    ? 'OpenDyslexic'
                    : 'AtkinsonHyperlegible',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: context.watch<SettingsBloc>().state.selectedFont,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required String description,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final font = context.watch<SettingsBloc>().state.selectedFont;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: font,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontFamily: font,
                ),
              ),
            ],
          ),
          Switch(
            value: isSelected,
            activeColor: AppTheme.sageGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
