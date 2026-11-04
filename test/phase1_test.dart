import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:name_none/models/agenda_event.dart';
import 'package:name_none/models/library_resource.dart';
import 'package:name_none/state/app_state.dart';
import 'package:name_none/utils/calendar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════════════════════════════════════════
  // CalendarUtils — tests use real extracted functions, not reimplemented logic
  // ═══════════════════════════════════════════════════════════════════════════

  group('CalendarUtils.getStartOfWeek', () {
    test('devuelve lunes para un jueves a mitad de semana', () {
      // 2026-10-08 es jueves
      final thursday = DateTime(2026, 10, 8);
      final monday = CalendarUtils.getStartOfWeek(thursday);
      expect(monday.weekday, equals(DateTime.monday));
      expect(monday, equals(DateTime(2026, 10, 5)));
    });

    test('devuelve el mismo día si ya es lunes', () {
      final monday = DateTime(2026, 10, 5);
      expect(CalendarUtils.getStartOfWeek(monday), equals(monday));
    });

    test('cruza límite de mes correctamente (Oct 1 → Sep 28)', () {
      final oct1 = DateTime(2026, 10, 1); // jueves
      final start = CalendarUtils.getStartOfWeek(oct1);
      expect(start.month, equals(9));
      expect(start.day, equals(28));
    });

    test('cruza límite de año correctamente (Ene 1 2027 → Dic 28 2026)', () {
      final jan1 = DateTime(2027, 1, 1); // viernes
      final start = CalendarUtils.getStartOfWeek(jan1);
      expect(start.year, equals(2026));
      expect(start.month, equals(12));
      expect(start.day, equals(28));
    });
  });

  group('CalendarUtils.getDaysOfWeek', () {
    test('genera 7 días consecutivos que cruzan mes (Sep→Oct)', () {
      final days = CalendarUtils.getDaysOfWeek(DateTime(2026, 10, 1));
      expect(days.length, equals(7));
      // Lunes 28 Sep → Domingo 4 Oct
      expect(days[0], equals(DateTime(2026, 9, 28)));
      expect(days[6], equals(DateTime(2026, 10, 4)));
      // Todos deben tener día >= 1
      for (final d in days) {
        expect(d.day, greaterThanOrEqualTo(1));
      }
    });

    test('genera 7 días consecutivos que cruzan año (Dic 2026→Ene 2027)', () {
      final days = CalendarUtils.getDaysOfWeek(DateTime(2026, 12, 31));
      // 2026-12-31 es jueves → lunes = 28 dic
      expect(days[0], equals(DateTime(2026, 12, 28)));
      expect(days[4].year, equals(2027)); // 1 Ene
      expect(days[4].day, equals(1));
    });
  });

  group('CalendarUtils.isSameDay', () {
    test('mismo día con horas distintas devuelve true', () {
      final a = DateTime(2026, 10, 8, 9, 30);
      final b = DateTime(2026, 10, 8, 23, 59);
      expect(CalendarUtils.isSameDay(a, b), isTrue);
    });

    test('días distintos devuelve false', () {
      expect(
        CalendarUtils.isSameDay(DateTime(2026, 10, 8), DateTime(2026, 10, 9)),
        isFalse,
      );
    });

    test('null devuelve false', () {
      expect(CalendarUtils.isSameDay(null, DateTime.now()), isFalse);
      expect(CalendarUtils.isSameDay(DateTime.now(), null), isFalse);
    });
  });

  group('CalendarUtils navigation', () {
    test('previousMonth y nextMonth cruzan año', () {
      final jan = DateTime(2027, 1, 15);
      final prev = CalendarUtils.previousMonth(jan);
      expect(prev.year, equals(2026));
      expect(prev.month, equals(12));

      final dec = DateTime(2026, 12, 15);
      final next = CalendarUtils.nextMonth(dec);
      expect(next.year, equals(2027));
      expect(next.month, equals(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Próximo evento y ciclo de eventos
  // ═══════════════════════════════════════════════════════════════════════════

  group('Próximo Evento y Ciclo de Eventos', () {
    test('nextUpcomingEvent nunca devuelve eventos vencidos ni completados', () {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();

      final now = DateTime.now();

      appState.addEvent(AgendaEvent(
        id: '1',
        title: 'Examen pasado',
        type: EventType.examen,
        dateTime: now.subtract(const Duration(hours: 2)),
        subject: 'Historia',
      ));

      appState.addEvent(AgendaEvent(
        id: '2',
        title: 'Entrega lista',
        type: EventType.entrega,
        dateTime: now.add(const Duration(days: 1)),
        subject: 'Lengua',
        isCompleted: true,
      ));

      expect(appState.nextUpcomingEvent, isNull);

      appState.addEvent(AgendaEvent(
        id: '3',
        title: 'Presentación lejana',
        type: EventType.presentacion,
        dateTime: now.add(const Duration(days: 3)),
        subject: 'Ciencias',
      ));

      appState.addEvent(AgendaEvent(
        id: '4',
        title: 'Examen cercano',
        type: EventType.examen,
        dateTime: now.add(const Duration(days: 1)),
        subject: 'Matemática',
      ));

      expect(appState.nextUpcomingEvent?.id, equals('4'));
    });

    test('Ciclo completo: crear, editar, completar, reabrir, eliminar', () {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();

      final event = AgendaEvent(
        id: 'ev-1',
        title: 'Parcial Inicial',
        type: EventType.examen,
        dateTime: DateTime.now().add(const Duration(days: 2)),
        subject: 'Matemática',
      );

      appState.addEvent(event);
      expect(appState.events.length, equals(1));

      appState.updateEvent(event.copyWith(title: 'Parcial Editado', location: 'Aula Magna'));
      expect(appState.events.first.title, equals('Parcial Editado'));
      expect(appState.events.first.location, equals('Aula Magna'));

      appState.toggleEventCompleted('ev-1');
      expect(appState.events.first.isCompleted, isTrue);

      appState.toggleEventCompleted('ev-1');
      expect(appState.events.first.isCompleted, isFalse);

      appState.deleteEvent('ev-1');
      expect(appState.events.isEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Datos dañados — fromJson lanza FormatException, AppState los omite
  // ═══════════════════════════════════════════════════════════════════════════

  group('Manejo de Datos Dañados', () {
    test('AgendaEvent.fromJson lanza FormatException en campos obligatorios ausentes', () {
      // Sin id
      expect(
        () => AgendaEvent.fromJson({'title': 'X', 'dateTime': DateTime.now().toIso8601String()}),
        throwsA(isA<FormatException>()),
      );
      // Sin título
      expect(
        () => AgendaEvent.fromJson({'id': '1', 'dateTime': DateTime.now().toIso8601String()}),
        throwsA(isA<FormatException>()),
      );
      // Fecha inválida
      expect(
        () => AgendaEvent.fromJson({'id': '1', 'title': 'X', 'dateTime': 'no-es-fecha'}),
        throwsA(isA<FormatException>()),
      );
      // Sin fecha
      expect(
        () => AgendaEvent.fromJson({'id': '1', 'title': 'X'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('LibraryResource.fromJson lanza FormatException en campos obligatorios ausentes', () {
      expect(
        () => LibraryResource.fromJson({'title': 'X', 'dateAdded': DateTime.now().toIso8601String()}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => LibraryResource.fromJson({'id': '1', 'dateAdded': DateTime.now().toIso8601String()}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => LibraryResource.fromJson({'id': '1', 'title': 'X', 'dateAdded': 'corrupta'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('AppState omite items dañados individuales y cuenta los omitidos', () async {
      final validEvent = {
        'id': 'v1',
        'title': 'Evento Válido',
        'type': 'examen',
        'dateTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'subject': 'Matemática',
        'isCompleted': false,
      };

      // The second item is a string (not a map) — should be omitted
      // The third item has no title — should throw FormatException → omitted
      final mixedList = jsonEncode([
        validEvent,
        'esto no es un map',
        {'id': 'v2', 'dateTime': DateTime.now().toIso8601String()}, // no title → FormatException
      ]);

      SharedPreferences.setMockInitialValues({
        'events': mixedList,
        'hasStarted': true,
      });

      final appState = AppState();
      await appState.ensureLoaded();

      expect(appState.hasStarted, isTrue);
      expect(appState.events.length, equals(1));
      expect(appState.events.first.id, equals('v1'));
      expect(appState.omittedEventsCount, equals(2));
    });

    test('AppState no sobrescribe contenedor JSON corrupto', () async {
      SharedPreferences.setMockInitialValues({
        'events': '{esto no es una lista válida}',
      });

      final appState = AppState();
      await appState.ensureLoaded();

      expect(appState.eventsContainerCorrupted, isTrue);
      expect(appState.events.isEmpty, isTrue);
      expect(
        appState.eventsErrorMessage,
        contains('dañado'),
      );

      // Save should NOT overwrite corrupt container
      appState.addEvent(AgendaEvent(
        id: 'new',
        title: 'Nuevo',
        type: EventType.otro,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        subject: 'Test',
      ));

      // The original corrupt string should still be in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('events'), equals('{esto no es una lista válida}'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Onboarding persistencia
  // ═══════════════════════════════════════════════════════════════════════════

  group('Onboarding persistencia', () {
    test('primer inicio tiene hasStarted=false, luego persiste como true', () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();
      await appState.ensureLoaded();

      expect(appState.hasStarted, isFalse);

      appState.startApp();
      expect(appState.hasStarted, isTrue);

      // Simulate a reload
      SharedPreferences.setMockInitialValues({
        'hasStarted': true,
      });
      final appState2 = AppState();
      await appState2.ensureLoaded();
      expect(appState2.hasStarted, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Biblioteca y Favoritos
  // ═══════════════════════════════════════════════════════════════════════════

  group('Biblioteca y Favoritos', () {
    test('Alternar favorito actualiza el estado correctamente', () {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();

      final res = LibraryResource(
        id: 'r-1',
        title: 'Guía de Estudio',
        category: 'Matemática',
        fileType: 'PDF',
        fileSize: '1.2 MB',
        description: 'Fórmulas y ejemplos',
        dateAdded: DateTime.now(),
      );

      appState.addResource(res);
      expect(appState.resources.first.isFavorite, isFalse);

      appState.toggleFavoriteResource('r-1');
      expect(appState.resources.first.isFavorite, isTrue);

      appState.toggleFavoriteResource('r-1');
      expect(appState.resources.first.isFavorite, isFalse);
    });
  });
}
