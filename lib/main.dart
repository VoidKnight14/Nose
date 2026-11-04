import 'dart:async';

import 'package:flutter/material.dart';
import 'models/agenda_event.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';
import 'widgets/event_detail_modal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MiColegioApp());
}

class MiColegioApp extends StatefulWidget {
  const MiColegioApp({super.key});

  @override
  State<MiColegioApp> createState() => _MiColegioAppState();
}

class _MiColegioAppState extends State<MiColegioApp> {
  late final AppState _appState;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _tapSubscription;
  String? _pendingEventId;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _tapSubscription = NotificationService.instance.taps.listen(
      _onNotificationTap,
    );
    _appState.loadFuture.then((_) async {
      if (!mounted) return;
      var remindersRescheduled = false;
      if (await _appState.claimFirstNotificationPermissionPrompt()) {
        final granted = await NotificationService.instance.requestPermission();
        if (granted && mounted) {
          await _appState.toggleNotifications(true);
          remindersRescheduled = true;
        }
      }
      if (!mounted) return;
      if (!remindersRescheduled) {
        unawaited(
          NotificationService.instance.rescheduleAll(
            _appState.events,
            enabled: _appState.notificationsEnabled,
          ),
        );
      }
      final id =
          NotificationService.instance.takeInitialEventId() ?? _pendingEventId;
      _pendingEventId = null;
      if (id != null) _openEvent(id);
    });
  }

  void _onNotificationTap(String eventId) {
    if (_appState.isLoading) {
      _pendingEventId = eventId;
      return;
    }
    _openEvent(eventId);
  }

  void _openEvent(String eventId) {
    AgendaEvent? event;
    for (final candidate in _appState.events) {
      if (candidate.id == eventId) {
        event = candidate;
        break;
      }
    }
    if (event == null) return;

    final context = _navigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openEvent(eventId);
      });
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EventDetailModal(event: event!),
    );
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
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
            navigatorKey: _navigatorKey,
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
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _appState.isLoading
                  ? const Scaffold(
                      key: ValueKey('loading'),
                      body: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    )
                  : _appState.hasStarted
                  ? const MainLayout(key: ValueKey('main_layout'))
                  : OnboardingScreen(
                      key: const ValueKey('onboarding_screen'),
                      onCompleted: () {
                        _appState.startApp();
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
