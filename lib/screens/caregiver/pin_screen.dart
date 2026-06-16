import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../theme/app_theme.dart';
import '../../services/haptics_service.dart';
import 'dashboard_screen.dart';

class CaregiverPinScreen extends StatefulWidget {
  const CaregiverPinScreen({super.key});

  @override
  State<CaregiverPinScreen> createState() => _CaregiverPinScreenState();
}

class _CaregiverPinScreenState extends State<CaregiverPinScreen> {
  String _inputPin = '';
  final int _maxPinLength = 4;
  String _errorMessage = '';

  void _onKeyPress(String val) {
    HapticsService.triggerLight();
    if (_inputPin.length < _maxPinLength) {
      setState(() {
        _inputPin += val;
        _errorMessage = '';
      });
    }

    if (_inputPin.length == _maxPinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    HapticsService.triggerLight();
    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _verifyPin() {
    final correctPin = context.read<SettingsBloc>().state.caregiverPin;
    if (_inputPin == correctPin) {
      HapticsService.triggerSuccessPattern();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()),
      );
    } else {
      HapticsService.triggerHeavy();
      setState(() {
        _inputPin = '';
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
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
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                    const Text('🔐', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Caregiver area',
                      style: textTheme.headlineSmall?.copyWith(
                        fontFamily: font,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your PIN to continue',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontFamily: font,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_maxPinLength, (index) {
                  final active = index < _inputPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: active ? AppTheme.sageGreen : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active ? AppTheme.sageGreen : theme.dividerColor,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              _buildKeyboard(context),

              const SizedBox(height: 16),
              Text(
                'Or use Biometrics',
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: font,
                  color: AppTheme.sageGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context) {
    return Column(
      children: [
        Row(children: [_buildKey('1'), _buildKey('2'), _buildKey('3')]),
        Row(children: [_buildKey('4'), _buildKey('5'), _buildKey('6')]),
        Row(children: [_buildKey('7'), _buildKey('8'), _buildKey('9')]),
        Row(
          children: [
            _buildActionKey(
              'back',
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
            ),
            _buildKey('0'),
            _buildActionKey(
              'enter',
              label: 'enter',
              onTap: () {
                if (_inputPin.isNotEmpty) _verifyPin();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: theme.dividerColor),
          ),
          onPressed: () => _onKeyPress(value),
          child: Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
    String key, {
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: key == 'enter'
                ? AppTheme.sageGreen
                : theme.cardColor,
            foregroundColor: key == 'enter'
                ? Colors.white
                : theme.textTheme.bodyLarge?.color,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: key == 'enter'
                  ? BorderSide.none
                  : BorderSide(color: theme.dividerColor),
            ),
          ),
          onPressed: onTap,
          child: icon != null
              ? Icon(icon, size: 22)
              : Text(
                  label ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
