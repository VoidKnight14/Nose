import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:name_none/main.dart';
import 'package:name_none/models/agenda_event.dart';
import 'package:name_none/screens/agenda_tab.dart';
import 'package:name_none/state/app_state.dart';
import 'package:name_none/widgets/add_event_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'App smoke test - shows onboarding on first launch with data notice',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MiColegioApp());
      await tester.pumpAndSettle();

      expect(find.text('Nexora'), findsOneWidget);
      expect(
        find.text(
          'Nexora guarda tus datos solo en este dispositivo. Al desinstalar la app, se borrarán y no podrán recuperarse.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('completar el onboarding lo guarda y no reaparece', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MiColegioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido 👋'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('hasStarted'), isTrue);

    // Simula un segundo arranque con los datos ya guardados.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MiColegioApp());
    await tester.pumpAndSettle();

    expect(find.text('Comenzar'), findsNothing);
    expect(find.text('Bienvenido 👋'), findsOneWidget);
  });

  testWidgets(
    'editar un evento antiguo abre el selector de fecha sin errores',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();

      final oldEvent = AgendaEvent(
        id: 'old-1',
        title: 'Evento antiguo',
        type: EventType.entrega,
        dateTime: DateTime.now().subtract(const Duration(days: 90)),
        subject: 'Historia',
      );
      appState.addEvent(oldEvent);

      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: ctx,
                    builder: (_) => AddEventDialog(eventToEdit: oldEvent),
                  ),
                  child: const Text('Abrir edición'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir edición'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);

      Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEventDialog), findsNothing);
      expect(appState.events.single.title, 'Evento antiguo');
    },
  );

  testWidgets('seleccionar un día en Agenda filtra sus eventos', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final tomorrow = today.add(const Duration(days: 1));

    SharedPreferences.setMockInitialValues({
      'hasStarted': true,
      'events': jsonEncode([
        AgendaEvent(
          id: 'today',
          title: 'Evento de hoy',
          type: EventType.examen,
          dateTime: today,
          subject: 'Matemática',
        ).toJson(),
        AgendaEvent(
          id: 'tomorrow',
          title: 'Evento de mañana',
          type: EventType.otro,
          dateTime: tomorrow,
          subject: 'Lengua',
        ).toJson(),
      ]),
    });

    await tester.pumpWidget(const MiColegioApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();

    expect(find.text('Evento de hoy'), findsOneWidget);
    expect(find.text('Evento de mañana'), findsOneWidget);

    await tester.tap(find.text('${now.day}').first);
    await tester.pumpAndSettle();

    expect(find.text('Evento de hoy'), findsOneWidget);
    expect(find.text('Evento de mañana'), findsNothing);
  });

  testWidgets('Agenda cabe en el ancho de un teléfono', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.ensureLoaded();

    await tester.pumpWidget(
      AppStateScope(
        notifier: appState,
        child: const MaterialApp(home: AgendaTab()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
