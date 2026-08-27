import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/agenda_event.dart';
import '../models/library_resource.dart';
import '../models/achievement.dart';

class AppState extends ChangeNotifier {
  // --- User Profile ---
  UserProfile userProfile = UserProfile(
    name: '',
    grade: '0',
    isConfigured: false,
  );

  // --- App Theme & Settings ---
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  // --- Events ---
  final List<AgendaEvent> _events = [];

  // --- Resources ---
  final List<LibraryResource> _resources = [];

  // --- Achievements ---
  final List<Achievement> _achievements = [];

  // --- Stats ---
  int consecutiveDays = 5;

  AppState() {
    _initInitialData();
  }

  List<AgendaEvent> get events => List.unmodifiable(_events);
  List<LibraryResource> get resources => List.unmodifiable(_resources);
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  // Computed stats
  int get unlockedAchievementsCount =>
      _achievements.where((a) => a.isUnlocked).length;

  int get totalDocumentsRead =>
      _resources.fold(0, (sum, res) => sum + res.readCount);

  double get overallAchievementProgress {
    if (_achievements.isEmpty) return 0.0;
    final totalProgress = _achievements.fold<double>(
      0.0,
      (sum, a) => sum + a.progressPercentage,
    );
    return (totalProgress / _achievements.length).clamp(0.0, 1.0);
  }

  AgendaEvent? get nextUpcomingEvent {
    final now = DateTime.now();
    final upcoming = _events
        .where((e) => !e.isCompleted && e.dateTime.isAfter(now.subtract(const Duration(hours: 12))))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.first;
  }

  void _initInitialData() {
    final now = DateTime.now();

    // Default Events matching prompt.md
    _events.addAll([
      AgendaEvent(
        id: '1',
        title: 'Examen de Matemática',
        type: EventType.examen,
        dateTime: now.add(const Duration(days: 2, hours: 3)),
        subject: 'Matemática',
        location: 'Aula 204',
        notes: 'Repasar derivadas e integrales básicas.',
      ),
      AgendaEvent(
        id: '2',
        title: 'Entrega de proyecto Flutter',
        type: EventType.entrega,
        dateTime: now.add(const Duration(days: 5, hours: 1)),
        subject: 'Informática',
        location: 'Laboratorio 3',
        notes: 'Subir código a repositorio GitHub.',
      ),
      AgendaEvent(
        id: '3',
        title: 'Presentación de Historia',
        type: EventType.presentacion,
        dateTime: now.add(const Duration(days: 8, hours: 2)),
        subject: 'Historia',
        location: 'Auditorio',
        notes: 'Traer diapositivas en pendrive.',
      ),
      AgendaEvent(
        id: '4',
        title: 'Reunión de Delegados',
        type: EventType.importante,
        dateTime: now.add(const Duration(days: 12)),
        subject: 'Institucional',
        location: 'Sala de Profesores',
        notes: 'Discutir actividades del mes.',
      ),
    ]);

    // Default Library Resources
    _resources.addAll([
      LibraryResource(
        id: 'r1',
        title: 'Álgebra básica y funciones',
        category: 'Matemática',
        fileType: 'PDF',
        fileSize: '2.4 MB',
        description: 'Material teórico y práctico para estudiar ecuaciones y funciones lineales y cuadráticas.',
        dateAdded: now.subtract(const Duration(days: 1)),
        readCount: 3,
      ),
      LibraryResource(
        id: 'r2',
        title: 'Guía de programación en Flutter',
        category: 'Informática',
        fileType: 'PDF',
        fileSize: '5.1 MB',
        description: 'Manual introductorio a Widgets, layouts y manejo de estados en Dart/Flutter.',
        dateAdded: now.subtract(const Duration(days: 2)),
        readCount: 5,
        isFavorite: true,
      ),
      LibraryResource(
        id: 'r3',
        title: 'Resumen de literatura clásica',
        category: 'Lengua',
        fileType: 'PDF',
        fileSize: '1.8 MB',
        description: 'Resumen temático sobre El Quijote y autores del Siglo de Oro.',
        dateAdded: now.subtract(const Duration(days: 4)),
      ),
      LibraryResource(
        id: 'r4',
        title: 'Introducción a la Química Orgánica',
        category: 'Ciencias',
        fileType: 'PDF',
        fileSize: '3.6 MB',
        description: 'Formulación y nomenclatura de compuestos orgánicos e hidrocarburos.',
        dateAdded: now.subtract(const Duration(days: 6)),
      ),
    ]);

    // Default Achievements
    _achievements.addAll([
      Achievement(
        id: 'a1',
        title: 'Primer paso',
        description: 'Abriste la aplicación por primera vez',
        iconEmoji: '🥇',
        iconData: Icons.star_outline,
        isUnlocked: true,
        unlockedAt: now.subtract(const Duration(days: 1)),
        requiredProgress: 1,
        currentProgress: 1,
      ),
      Achievement(
        id: 'a2',
        title: 'Lector constante',
        description: 'Abriste y leíste 5 documentos',
        iconEmoji: '📚',
        iconData: Icons.menu_book,
        isUnlocked: true,
        unlockedAt: now.subtract(const Duration(hours: 12)),
        requiredProgress: 5,
        currentProgress: 5,
      ),
      Achievement(
        id: 'a3',
        title: 'Organizado',
        description: 'Creaste al menos 3 eventos en tu agenda',
        iconEmoji: '📅',
        iconData: Icons.calendar_month,
        isUnlocked: true,
        unlockedAt: now.subtract(const Duration(days: 2)),
        requiredProgress: 3,
        currentProgress: 4,
      ),
      Achievement(
        id: 'a4',
        title: 'Estudioso pro',
        description: 'Completa 10 eventos de tu agenda',
        iconEmoji: '🎓',
        iconData: Icons.school,
        isUnlocked: false,
        requiredProgress: 10,
        currentProgress: 2,
      ),
      Achievement(
        id: 'a5',
        title: 'Bibliotecario',
        description: 'Guarda 3 documentos en tus favoritos',
        iconEmoji: '⭐',
        iconData: Icons.bookmark,
        isUnlocked: false,
        requiredProgress: 3,
        currentProgress: 1,
      ),
    ]);
  }

  // --- Profile Actions ---
  void updateUserProfile(String name, String grade) {
    userProfile = userProfile.copyWith(
      name: name.trim().isEmpty ? 'Estudiante' : name.trim(),
      grade: grade.trim().isEmpty ? 'General' : grade.trim(),
      isConfigured: true,
    );
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  // --- Event Actions ---
  void addEvent(AgendaEvent event) {
    _events.add(event);
    _checkEventAchievements();
    notifyListeners();
  }

  void updateEvent(AgendaEvent updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void toggleEventCompleted(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index].isCompleted = !_events[index].isCompleted;
      _checkCompletedAchievements();
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // --- Resource Actions ---
  void toggleFavoriteResource(String id) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index != -1) {
      _resources[index].isFavorite = !_resources[index].isFavorite;
      _checkFavoriteAchievements();
      notifyListeners();
    }
  }

  void incrementReadCount(String id) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index != -1) {
      _resources[index].readCount++;
      _checkReadAchievements();
      notifyListeners();
    }
  }

  // --- Achievement Triggers ---
  void _checkEventAchievements() {
    final achievementIndex = _achievements.indexWhere((a) => a.id == 'a3');
    if (achievementIndex != -1) {
      final ach = _achievements[achievementIndex];
      ach.currentProgress = _events.length;
      if (ach.currentProgress >= ach.requiredProgress && !ach.isUnlocked) {
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
      }
    }
  }

  void _checkCompletedAchievements() {
    final completedCount = _events.where((e) => e.isCompleted).length;
    final achievementIndex = _achievements.indexWhere((a) => a.id == 'a4');
    if (achievementIndex != -1) {
      final ach = _achievements[achievementIndex];
      ach.currentProgress = completedCount;
      if (ach.currentProgress >= ach.requiredProgress && !ach.isUnlocked) {
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
      }
    }
  }

  void _checkFavoriteAchievements() {
    final favCount = _resources.where((r) => r.isFavorite).length;
    final achievementIndex = _achievements.indexWhere((a) => a.id == 'a5');
    if (achievementIndex != -1) {
      final ach = _achievements[achievementIndex];
      ach.currentProgress = favCount;
      if (ach.currentProgress >= ach.requiredProgress && !ach.isUnlocked) {
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
      }
    }
  }

  void _checkReadAchievements() {
    final totalRead = totalDocumentsRead;
    final achievementIndex = _achievements.indexWhere((a) => a.id == 'a2');
    if (achievementIndex != -1) {
      final ach = _achievements[achievementIndex];
      ach.currentProgress = totalRead;
      if (ach.currentProgress >= ach.requiredProgress && !ach.isUnlocked) {
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
      }
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
