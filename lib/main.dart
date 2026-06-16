import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/routines/routines_bloc.dart';
import 'blocs/focus/focus_bloc.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific configurations
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If firebase config files are not present yet, it will throw.
  }

  // Initialize Hydrated Storage for State Persistence
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  HydratedBloc.storage = storage;

  runApp(const RutiniApp());
}

class RutiniApp extends StatelessWidget {
  const RutiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(create: (_) => SettingsBloc()),
        BlocProvider<RoutinesBloc>(create: (_) => RoutinesBloc()),
        BlocProvider<FocusBloc>(create: (_) => FocusBloc()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Rutini',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(
              fontName: settingsState.selectedFont,
              isDark: settingsState.themeMode == 'dark',
              isHighContrast: settingsState.themeMode == 'high_contrast',
            ),
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
