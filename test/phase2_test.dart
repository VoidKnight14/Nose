import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:name_none/models/agenda_event.dart';
import 'package:name_none/state/app_state.dart';
import 'package:name_none/widgets/add_event_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recordatorios en AgendaEvent', () {
    test('un evento guardado antes de la Fase 2 no tiene recordatorio', () {
      final event = AgendaEvent.fromJson({
        'id': 'old',
        'title': 'Evento viejo',
        'type': 'examen',
        'dateTime': DateTime.now().toIso8601String(),
        'subject': 'Historia',
      });

      expect(event.reminderMinutes, equals(-1));
    });

    test('toJson y fromJson conservan los minutos de recordatorio', () {
      final event = AgendaEvent(
        id: 'r-1',
        title: 'Parcial',
        type: EventType.examen,
        dateTime: DateTime(2026, 11, 5, 9),
        subject: 'Matemática',
        reminderMinutes: 60,
      );

      final restored = AgendaEvent.fromJson(event.toJson());
      expect(restored.reminderMinutes, equals(60));
      expect(
        restored.copyWith(reminderMinutes: -1).reminderMinutes,
        equals(-1),
      );
    });
  });

  test('la preferencia de notificaciones se guarda y se recarga', () async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.ensureLoaded();
    expect(appState.notificationsEnabled, isFalse);

    await appState.toggleNotifications(true);

    final reloaded = AppState();
    await reloaded.ensureLoaded();
    expect(reloaded.notificationsEnabled, isTrue);
  });

  test(
    'el permiso inicial de notificaciones se solicita una sola vez',
    () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();

      expect(await appState.claimFirstNotificationPermissionPrompt(), isTrue);
      expect(await appState.claimFirstNotificationPermissionPrompt(), isFalse);

      final reloaded = AppState();
      await reloaded.ensureLoaded();
      expect(await reloaded.claimFirstNotificationPermissionPrompt(), isFalse);
    },
  );

  testWidgets('el formulario guarda el recordatorio elegido', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.ensureLoaded();

    await tester.pumpWidget(
      AppStateScope(
        notifier: appState,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: ctx,
                  builder: (_) => const AddEventDialog(),
                ),
                child: const Text('Nuevo evento'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Nuevo evento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Parcial de prueba');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 minutos antes').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Guardar Evento'));
    await tester.tap(find.text('Guardar Evento'));
    await tester.pumpAndSettle();

    expect(appState.events.single.reminderMinutes, equals(10));
  });
}
