import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../theme/app_theme.dart';

class CaregiverAnalyticsScreen extends StatelessWidget {
  const CaregiverAnalyticsScreen({super.key});

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
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Routines',
              style: textTheme.headlineSmall?.copyWith(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildMetricBox(
                  context,
                  title: 'Completion rate',
                  value: '86%',
                  font: font,
                ),
                const SizedBox(width: 16),
                _buildMetricBox(
                  context,
                  title: 'Avg. skipped tasks',
                  value: '0.8',
                  font: font,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('WEEKLY COMPLETIONS', font, theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(context, day: 'S', heightFactor: 0.4, font: font),
                  _buildBar(context, day: 'M', heightFactor: 0.8, font: font),
                  _buildBar(context, day: 'T', heightFactor: 0.9, font: font),
                  _buildBar(context, day: 'W', heightFactor: 0.75, font: font),
                  _buildBar(context, day: 'T', heightFactor: 0.85, font: font),
                  _buildBar(context, day: 'F', heightFactor: 0.95, font: font),
                  _buildBar(context, day: 'S', heightFactor: 0.5, font: font),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('THIS MONTH', font, theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                      return SizedBox(
                        width: 32,
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: font,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: List.generate(30, (index) {
                      final dayNum = index + 1;

                      Color circleBg = theme.dividerColor.withOpacity(0.2);
                      Color textCol =
                          theme.textTheme.bodyLarge?.color ?? Colors.black;

                      if (dayNum == 7 || dayNum == 14 || dayNum == 21) {
                        circleBg = AppTheme.ochreGold.withOpacity(
                          0.2,
                        ); // Partially done
                      } else if (dayNum == 3 || dayNum == 10 || dayNum == 17) {
                        circleBg = Colors.redAccent.withOpacity(0.15); // Missed
                        textCol = Colors.redAccent;
                      } else if (dayNum < DateTime.now().day) {
                        circleBg = AppTheme.sageGreen.withOpacity(
                          0.2,
                        ); // Fully done
                        textCol = AppTheme.sageGreen;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: circleBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontFamily: font,
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendKey(
                        context,
                        color: AppTheme.sageGreen,
                        label: 'All done',
                        font: font,
                      ),
                      _buildLegendKey(
                        context,
                        color: AppTheme.ochreGold,
                        label: 'Partially done',
                        font: font,
                      ),
                      _buildLegendKey(
                        context,
                        color: Colors.redAccent,
                        label: 'Missed',
                        font: font,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('HABIT SUGGESTIONS', font, theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.ochreGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.ochreGold, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Rinse mouth" is skipped often.',
                          style: textTheme.titleSmall?.copyWith(
                            fontFamily: font,
                            color: theme.brightness == Brightness.dark
                                ? AppTheme.ochreGold
                                : const Color(0xFF9E701C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Try moving it before brushing. It's been skipped 5 times this week.",
                          style: textTheme.bodySmall?.copyWith(
                            fontFamily: font,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildSectionLabel(String text, String font, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontFamily: font,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.hintColor,
      ),
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String title,
    required String value,
    required String font,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: font,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: font,
                color: AppTheme.sageGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required String day,
    required double heightFactor,
    required String font,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 24,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: AppTheme.sageGreen,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.bold,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendKey(
    BuildContext context, {
    required Color color,
    required String label,
    required String font,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: font,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
