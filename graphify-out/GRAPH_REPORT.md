# Graph Report - Nexora  (2026-11-04)

## Corpus Check
- 44 files · ~19,910 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 28 file(s) not represented in the graph (top: .xml 7, (none) 4, .plist 4)

## Summary
- 481 nodes · 556 edges · 28 communities (23 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a15de9ef`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_state.dart
- package:flutter/material.dart
- agenda_tab.dart
- main.dart
- onboarding_screen.dart
- AppDelegate
- add_event_dialog.dart
- pubspec.yaml
- library_storage_io.dart
- library_storage_types.dart
- phase1_test.dart
- library_resource.dart
- manifest.json
- calendar_utils.dart
- analysis_options.yaml
- notification_service.dart
- Nexora
- Observaciones que hay que resolver
- Prompt de arquitectura y desarrollo para Nexora
- main_layout.dart
- LaunchImage.imageset/README.md
- add_resource_dialog.dart
- library_tab.dart
- event_task.dart

## God Nodes (most connected - your core abstractions)
1. `dependencies` - 11 edges
2. `Nexora` - 8 edges
3. `Observaciones que hay que resolver` - 8 edges
4. `Prompt de arquitectura y desarrollo para Nexora` - 7 edges
5. `Compilación y Ejecución` - 6 edges
6. `Notas Técnicas` - 6 edges
7. `AppDelegate` - 5 edges
8. `Fases del producto` - 5 edges
9. `EventType` - 4 edges
10. `_OnboardingScreenState` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Notas Técnicas` --references--> `MainActivity`  [INFERRED]
  README.md → android/app/src/main/kotlin/com/nexora/app/MainActivity.kt

## Import Cycles
- None detected.

## Communities (28 total, 5 thin omitted)

### Community 0 - "app_state.dart"
Cohesion: 0.04
Nodes (44): addEvent, addEventTask, addResource, addSubject, claimFirstNotificationPermissionPrompt, deleteEvent, deleteEventTask, deleteResource (+36 more)

### Community 1 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (33): AgendaEvent, build, _buildDayStrip, _buildEventListItem, createState, _focusedDate, _goToToday, _months (+25 more)

### Community 2 - "agenda_tab.dart"
Cohesion: 0.11
Nodes (16): copyWith, dateTime, EventType, EventTypeExtension, fromJson, id, isCompleted, location (+8 more)

### Community 3 - "main.dart"
Cohesion: 0.09
Nodes (13): _appState, build, createState, dispose, initState, main, _navigatorKey, _onNotificationTap (+5 more)

### Community 4 - "onboarding_screen.dart"
Cohesion: 0.10
Nodes (16): build, _buttonFade, _buttonSlide, _controller, createState, dispose, initState, _logoFade (+8 more)

### Community 5 - "AppDelegate"
Cohesion: 0.11
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, UIKit, XCTest

### Community 6 - "add_event_dialog.dart"
Cohesion: 0.10
Nodes (20): AddEventDialog, _AddEventDialogState, build, createState, dispose, eventToEdit, initState, _locationController (+12 more)

### Community 7 - "pubspec.yaml"
Cohesion: 0.08
Nodes (24): dependencies, cupertino_icons, file_picker, flutter, flutter_local_notifications, flutter_timezone, open_filex, path_provider (+16 more)

### Community 8 - "library_storage_io.dart"
Cohesion: 0.07
Nodes (16): absolutePath, delete, _directory, exists, _folder, LibraryStorage, openExternally, pick (+8 more)

### Community 9 - "library_storage_types.dart"
Cohesion: 0.20
Nodes (9): formatFileSize, kb, mb, name, _oneDecimal, path, PickedLibraryFile, size (+1 more)

### Community 10 - "phase1_test.dart"
Cohesion: 0.12
Nodes (6): main, main, main, event, main, main

### Community 11 - "library_resource.dart"
Cohesion: 0.12
Nodes (14): category, copyWith, dateAdded, description, fileSize, fileType, fromJson, hasFile (+6 more)

### Community 12 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 13 - "calendar_utils.dart"
Cohesion: 0.22
Nodes (8): CalendarUtils, getDaysOfWeek, getStartOfWeek, isSameDay, nextMonth, nextWeek, previousMonth, previousWeek

### Community 14 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): include, linter, rules

### Community 15 - "notification_service.dart"
Cohesion: 0.08
Nodes (15): cancel, cancelAll, init, _initialEventId, instance, _notificationId, NotificationService, _plugin (+7 more)

### Community 20 - "Nexora"
Cohesion: 0.10
Nodes (18): MainActivity, Compilación y Ejecución, Dependencias de la Fase 2, Dependencias de la Fase 3, Ejecución en modo desarrollo, Ejecución en Web (revisión de interfaz), Estado de validación (Fases 1, 2, 3 y 4), Estructura del Proyecto (+10 more)

### Community 21 - "Observaciones que hay que resolver"
Cohesion: 0.17
Nodes (11): 1. No perder silenciosamente datos con JSON dañado, 2. Permitir editar eventos antiguos, 3. No presentar el interruptor de notificaciones como funcional antes de la Fase 2, 4. Revisar la configuración de copias de seguridad de Android, 5. Revisar el identificador Android de plantilla, 6. Mejorar las pruebas para que comprueben el código real, 7. No declarar la fase terminada sin validarla, Alcance (+3 more)

### Community 22 - "Prompt de arquitectura y desarrollo para Nexora"
Cohesion: 0.17
Nodes (11): Calidad común a todas las fases, Cómo trabajar: una fase por ejecución, Distribución, Fase 1 — Estabilizar la app actual, Fase 2 — Recordatorios locales de Android, Fase 3 — Biblioteca con archivos reales, Fase 4 — Herramientas de estudio (después de las fases anteriores), Fases del producto (+3 more)

### Community 23 - "main_layout.dart"
Cohesion: 0.07
Nodes (22): MiColegioApp, _MiColegioAppState, AgendaTab, _AgendaTabState, build, createState, _currentIndex, MainLayout (+14 more)

### Community 25 - "add_resource_dialog.dart"
Cohesion: 0.09
Nodes (18): LibraryResource, build, _buildFilePicker, _busy, _categoryController, createState, _descriptionController, dispose (+10 more)

### Community 26 - "library_tab.dart"
Cohesion: 0.15
Nodes (10): build, _buildResourceCard, createState, dispose, LibraryTab, _LibraryTabState, _onlyFavorites, _openAddResourceDialog (+2 more)

### Community 27 - "event_task.dart"
Cohesion: 0.25
Nodes (7): copyWith, EventTask, fromJson, id, isDone, title, toJson

## Knowledge Gaps
- **239 isolated node(s):** `XCTest`, `_appState`, `_navigatorKey`, `_tapSubscription`, `_pendingEventId` (+234 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 367 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PickedLibraryFile` connect `library_storage_types.dart` to `add_resource_dialog.dart`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **What connects `XCTest`, `_appState`, `_navigatorKey` to the rest of the system?**
  _239 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_state.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0425531914893617 - nodes in this community are weakly interconnected._
- **Why does `AppState` connect `main.dart` to `app_state.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Should `package:flutter/material.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04902867715078631 - nodes in this community are weakly interconnected._
- **Why does `EventType` connect `agenda_tab.dart` to `package:flutter/material.dart`, `add_event_dialog.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Should `agenda_tab.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._