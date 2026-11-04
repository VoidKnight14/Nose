import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agenda_event.dart';
import '../models/event_task.dart';
import '../models/library_resource.dart';
import '../services/library_storage.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  // --- Keys for SharedPreferences ---
  static const _keyIsDarkMode = 'isDarkMode';
  static const _keyNotificationsEnabled = 'notificationsEnabled';
  static const _keyHasStarted = 'hasStarted';
  static const _keyNotificationPermissionPrompted =
      'notificationPermissionPrompted';
  static const _keyEvents = 'events';
  static const _keyResources = 'resources';
  static const _keySubjects = 'subjects';

  // --- Loading State & Future for deterministic tests ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  late final Future<void> loadFuture;

  // --- Error tracking for damaged data ---
  bool eventsContainerCorrupted = false;
  int omittedEventsCount = 0;
  bool resourcesContainerCorrupted = false;
  int omittedResourcesCount = 0;

  String? get eventsErrorMessage {
    if (eventsContainerCorrupted) {
      return 'El contenedor local de eventos está dañado y no se pudo leer. Los datos originales se conservan sin sobrescribir.';
    }
    if (omittedEventsCount > 0) {
      return 'Se omitieron $omittedEventsCount evento(s) con datos incompletos o fechas inválidas.';
    }
    return null;
  }

  String? get resourcesErrorMessage {
    if (resourcesContainerCorrupted) {
      return 'El contenedor local de recursos está dañado y no se pudo leer. Los datos originales se conservan sin sobrescribir.';
    }
    if (omittedResourcesCount > 0) {
      return 'Se omitieron $omittedResourcesCount recurso(s) con datos incompletos o fechas inválidas.';
    }
    return null;
  }

  // --- App Theme & Settings ---
  bool isDarkMode = true;
  bool notificationsEnabled = false;

  // --- App Launch State ---
  bool hasStarted = false;

  // --- Events ---
  final List<AgendaEvent> _events = [];

  // --- Resources (Empty by default) ---
  final List<LibraryResource> _resources = [];

  // --- Subjects (Empty by default) ---
  final List<String> _subjects = [];

  AppState() {
    loadFuture = _loadFromStorage();
  }

  Future<void> ensureLoaded() => loadFuture;

  Future<bool> claimFirstNotificationPermissionPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyNotificationPermissionPrompted) ?? false) {
      return false;
    }
    await prefs.setBool(_keyNotificationPermissionPrompted, true);
    return true;
  }

  List<AgendaEvent> get events => List.unmodifiable(_events);
  List<LibraryResource> get resources => List.unmodifiable(_resources);
  List<String> get subjects => List.unmodifiable(_subjects);

  AgendaEvent? get nextUpcomingEvent {
    final now = DateTime.now();
    final upcoming = _events
        .where((e) => !e.isCompleted && e.dateTime.isAfter(now))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.first;
  }

  // --- Persistence: Load ---
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      isDarkMode = prefs.getBool(_keyIsDarkMode) ?? true;
      notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? false;
      hasStarted = prefs.getBool(_keyHasStarted) ?? false;

      final eventsJson = prefs.getString(_keyEvents);
      if (eventsJson != null && eventsJson.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(eventsJson);
          if (decoded is List) {
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                try {
                  _events.add(AgendaEvent.fromJson(item));
                } catch (_) {
                  omittedEventsCount++;
                }
              } else {
                omittedEventsCount++;
              }
            }
          } else {
            // Container exists but is not a valid JSON list
            eventsContainerCorrupted = true;
          }
        } catch (_) {
          // JSON syntax error: corrupt container string preserved without overwrite
          eventsContainerCorrupted = true;
        }
      }

      final resourcesJson = prefs.getString(_keyResources);
      if (resourcesJson != null && resourcesJson.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(resourcesJson);
          if (decoded is List) {
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                try {
                  _resources.add(LibraryResource.fromJson(item));
                } catch (_) {
                  omittedResourcesCount++;
                }
              } else {
                omittedResourcesCount++;
              }
            }
          } else {
            // Container exists but is not a valid JSON list
            resourcesContainerCorrupted = true;
          }
        } catch (_) {
          // JSON syntax error: corrupt container string preserved without overwrite
          resourcesContainerCorrupted = true;
        }
      }

      final subjectsJson = prefs.getString(_keySubjects);
      if (subjectsJson != null && subjectsJson.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(subjectsJson);
          if (decoded is List) {
            for (final item in decoded) {
              _rememberSubject(item?.toString() ?? '');
            }
          }
        } catch (_) {
          // Materias ilegibles: se empieza con la lista vacía.
        }
      }
    } catch (_) {
      // If SharedPreferences fails during load, start fresh with defaults
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Persistence: Save with concurrency serialization ---
  bool _isSaving = false;
  bool _hasSavePending = false;

  Future<void> _saveToStorage() async {
    if (_isSaving) {
      _hasSavePending = true;
      return;
    }
    _isSaving = true;

    try {
      do {
        _hasSavePending = false;
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(_keyIsDarkMode, isDarkMode);
        await prefs.setBool(_keyNotificationsEnabled, notificationsEnabled);
        await prefs.setBool(_keyHasStarted, hasStarted);

        // Never overwrite corrupt container string with empty or partial list
        if (!eventsContainerCorrupted) {
          await prefs.setString(
            _keyEvents,
            jsonEncode(_events.map((e) => e.toJson()).toList()),
          );
        }

        if (!resourcesContainerCorrupted) {
          await prefs.setString(
            _keyResources,
            jsonEncode(_resources.map((r) => r.toJson()).toList()),
          );
        }

        await prefs.setString(_keySubjects, jsonEncode(_subjects));
      } while (_hasSavePending);
    } catch (_) {
      // Silently fail — next save will retry
    } finally {
      _isSaving = false;
    }
  }

  // --- App Flow Actions ---
  void startApp() {
    hasStarted = true;
    notifyListeners();
    _saveToStorage();
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
    _saveToStorage();
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    await _saveToStorage();
    if (value) {
      await NotificationService.instance.rescheduleAll(_events, enabled: true);
    } else {
      await NotificationService.instance.cancelAll();
    }
  }

  // --- Event Actions (immutable via copyWith) ---
  void addEvent(AgendaEvent event) {
    _rememberSubject(event.subject);
    _events.add(event);
    notifyListeners();
    _saveToStorage();
    _syncReminder(event);
  }

  void updateEvent(AgendaEvent updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _rememberSubject(updatedEvent.subject);
      _events[index] = updatedEvent;
      notifyListeners();
      _saveToStorage();
      _syncReminder(updatedEvent);
    }
  }

  void toggleEventCompleted(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isCompleted: !_events[index].isCompleted,
      );
      notifyListeners();
      _saveToStorage();
      _syncReminder(_events[index]);
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveToStorage();
    unawaited(NotificationService.instance.cancel(id));
  }

  // --- Event Checklist ---
  void addEventTask(String eventId, String title) {
    final value = title.trim();
    if (value.isEmpty) return;

    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final event = _events[index];
    final task = EventTask(
      id: '${DateTime.now().microsecondsSinceEpoch}-${event.tasks.length}',
      title: value,
    );
    _events[index] = event.copyWith(tasks: [...event.tasks, task]);
    notifyListeners();
    _saveToStorage();
  }

  void toggleEventTask(String eventId, String taskId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final event = _events[index];
    final taskIndex = event.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final tasks = [...event.tasks];
    tasks[taskIndex] = tasks[taskIndex].copyWith(
      isDone: !tasks[taskIndex].isDone,
    );
    _events[index] = event.copyWith(tasks: tasks);
    notifyListeners();
    _saveToStorage();
  }

  void deleteEventTask(String eventId, String taskId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final event = _events[index];
    final tasks = event.tasks.where((t) => t.id != taskId).toList();
    if (tasks.length == event.tasks.length) return;

    _events[index] = event.copyWith(tasks: tasks);
    notifyListeners();
    _saveToStorage();
  }

  void _syncReminder(AgendaEvent event) {
    unawaited(
      NotificationService.instance.syncEvent(
        event,
        enabled: notificationsEnabled,
      ),
    );
  }

  // --- Subjects ---
  void addSubject(String name) {
    final value = name.trim();
    if (value.isEmpty) return;
    if (_subjects.any((s) => s.toLowerCase() == value.toLowerCase())) return;

    _subjects.add(value);
    notifyListeners();
    _saveToStorage();
  }

  void removeSubject(String name) {
    final previousLength = _subjects.length;
    _subjects.removeWhere((s) => s.toLowerCase() == name.toLowerCase());
    if (_subjects.length == previousLength) return;

    notifyListeners();
    _saveToStorage();
  }

  /// Registra una materia usada en un evento o recurso, sin duplicarla.
  void _rememberSubject(String name) {
    final value = name.trim();
    if (value.isEmpty || value.toLowerCase() == 'general') return;
    if (_subjects.any((s) => s.toLowerCase() == value.toLowerCase())) return;
    _subjects.add(value);
  }

  // --- Resource Actions (immutable via copyWith) ---
  void addResource(LibraryResource resource) {
    _rememberSubject(resource.category);
    _resources.add(resource);
    notifyListeners();
    _saveToStorage();
  }

  void deleteResource(String id) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final localPath = _resources[index].localPath;
    _resources.removeAt(index);
    notifyListeners();
    _saveToStorage();
    unawaited(LibraryStorage.delete(localPath));
  }

  void toggleFavoriteResource(String id) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index != -1) {
      _resources[index] = _resources[index].copyWith(
        isFavorite: !_resources[index].isFavorite,
      );
      notifyListeners();
      _saveToStorage();
    }
  }

  void incrementReadCount(String id) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index != -1) {
      _resources[index] = _resources[index].copyWith(
        readCount: _resources[index].readCount + 1,
      );
      notifyListeners();
      _saveToStorage();
    }
  }
}

// Global InheritedNotifier provider pattern for simple dependency injection without external packages
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
