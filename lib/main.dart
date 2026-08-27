import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const MiColegioApp());
}

class MiColegioApp extends StatefulWidget {
  const MiColegioApp({super.key});

  @override
  State<MiColegioApp> createState() => _MiColegioAppState();
}

class _MiColegioAppState extends State<MiColegioApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'Nexora',
            debugShowCheckedModeBanner: false,
            themeMode: _appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4F46E5),
                brightness: Brightness.light,
              ),
              fontFamily: 'Roboto',
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF818CF8),
                brightness: Brightness.dark,
              ),
              fontFamily: 'Roboto',

              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            home: _appState.userProfile.isConfigured
            
                ? const MainLayout()
                : OnboardingScreen(
                    onCompleted: () {
                      setState(() {});
                    },
                  ),
          );
        },
      ),
    );
  }
}
