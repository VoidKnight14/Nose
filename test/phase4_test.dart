import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:name_none/models/agenda_event.dart';
import 'package:name_none/models/event_task.dart';
import 'package:name_none/models/library_resource.dart';
import 'package:name_none/state/app_state.dart';
import 'package:name_none/widgets/event_detail_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AgendaEvent event({
    String subject = 'Matemática',
    List<EventTask> tasks = const [],
  }) {
    return AgendaEvent(
      id: 'e-1',
      title: 'Examen final',
      type: EventType.examen,
      dateTime: DateTime(2026, 11, 20, 9),
      subject: subject,
      tasks: tasks,
    );
  }

  group('Checklist de un evento', () {
    test('un evento guardado antes de la Fase 4 no tiene tareas', () {
      final restored = AgendaEvent.fromJson({
        'id': 'old',
        'title': 'Evento viejo',
        'type': 'examen',
        'dateTime': DateTime(2026, 11, 5).toIso8601String(),
        'subject': 'Historia',
      });

      expect(restored.tasks, isEmpty);
    });

    test('toJson y fromJson conservan las tareas y su estado', () {
      final restored = AgendaEvent.fromJson(
        event(
          tasks: const [
            EventTask(id: 't-1', title: 'Repasar apuntes', isDone: true),
            EventTask(id: 't-2', title: 'Resolver ejercicios'),
          ],
        ).toJson(),
      );

      expect(restored.tasks.length, equals(2));
      expect(restored.tasks.first.title, equals('Repasar apuntes'));
      expect(restored.tasks.first.isDone, isTrue);
      expect(restored.tasks.last.isDone, isFalse);
    });

    test('una tarea dañada no invalida el evento completo', () {
      final restored = AgendaEvent.fromJson({
        'id': 'e-2',
        'title': 'Evento',
        'type': 'examen',
        'dateTime': DateTime(2026, 11, 5).toIso8601String(),
        'subject': 'Historia',
        'tasks': [
          {'id': 't-1', 'title': 'Válida'},
          {'title': 'Sin identificador'},
        ],
      });

      expect(restored.tasks.length, equals(1));
      expect(restored.tasks.single.title, equals('Válida'));
    });

    testWidgets('el detalle muestra el checklist y permite completar un paso', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();
      appState.addEvent(
        event(
          tasks: const [EventTask(id: 't-1', title: 'Repasar apuntes')],
        ),
      );

      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: MaterialApp(
            home: Scaffold(
              body: EventDetailModal(event: appState.events.single),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repasar apuntes'), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(appState.events.single.tasks.single.isDone, isTrue);
    });

    test('agregar, completar y eliminar pasos se guarda en disco', () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();
      appState.addEvent(event());
      appState.addEventTask('e-1', 'Repasar apuntes');
      appState.addEventTask('e-1', '   ');
      await pumpEventQueue();

      expect(appState.events.single.tasks.length, equals(1));
      final taskId = appState.events.single.tasks.single.id;

      appState.toggleEventTask('e-1', taskId);
      await pumpEventQueue();

      final reloaded = AppState();
      await reloaded.ensureLoaded();
      expect(reloaded.events.single.tasks.single.isDone, isTrue);

      appState.deleteEventTask('e-1', taskId);
      await pumpEventQueue();
      expect(appState.events.single.tasks, isEmpty);
    });
  });

  group('Materias personalizadas', () {
    test('se agregan sin duplicados y se pueden eliminar', () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();

      appState.addSubject('Física');
      appState.addSubject('física');
      appState.addSubject('  ');

      expect(appState.subjects, equals(['Física']));

      appState.removeSubject('FÍSICA');
      expect(appState.subjects, isEmpty);
    });

    test('se registran desde eventos y recursos, ignorando General', () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();

      appState.addEvent(event(subject: 'Química'));
      appState.updateEvent(event(subject: 'Biología'));
      appState.addResource(
        LibraryResource(
          id: 'r-1',
          title: 'Apunte',
          category: 'Historia',
          fileType: 'PDF',
          fileSize: '1 MB',
          description: '',
          dateAdded: DateTime(2026, 11, 5),
        ),
      );
      appState.addEvent(event(subject: 'General'));

      expect(appState.subjects, equals(['Química', 'Biología', 'Historia']));
    });

    test('las materias se conservan al reiniciar la app', () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();

      appState.addSubject('Física');
      appState.addEvent(event(subject: 'Química'));
      await pumpEventQueue();

      final reloaded = AppState();
      await reloaded.ensureLoaded();
      expect(reloaded.subjects, equals(['Física', 'Química']));
    });
  });
}
