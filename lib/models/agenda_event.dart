import 'package:flutter/material.dart';

import 'event_task.dart';

enum EventType { examen, entrega, presentacion, importante, otro }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.examen:
        return 'Examen';
      case EventType.entrega:
        return 'Entrega';
      case EventType.presentacion:
        return 'Presentación';
      case EventType.importante:
        return 'Importante';
      case EventType.otro:
        return 'Otro';
    }
  }

  Color get color {
    switch (this) {
      case EventType.examen:
        return const Color(0xFF2563EB); // Blue
      case EventType.entrega:
        return const Color(0xFF10B981); // Emerald Green
      case EventType.presentacion:
        return const Color(0xFFF59E0B); // Amber Yellow
      case EventType.importante:
        return const Color(0xFFEF4444); // Red
      case EventType.otro:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.examen:
        return Icons.assignment_outlined;
      case EventType.entrega:
        return Icons.upload_file_outlined;
      case EventType.presentacion:
        return Icons.co_present_outlined;
      case EventType.importante:
        return Icons.error_outline;
      case EventType.otro:
        return Icons.event_note_outlined;
    }
  }
}

class AgendaEvent {
  final String id;
  final String title;
  final EventType type;
  final DateTime dateTime;
  final String subject;
  final String location;
  final String notes;
  final bool isCompleted;

  /// Minutos antes del evento. -1 significa sin recordatorio; 0 es a la hora.
  final int reminderMinutes;

  /// Pasos de estudio asociados al evento.
  final List<EventTask> tasks;

  const AgendaEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.subject,
    this.location = '',
    this.notes = '',
    this.isCompleted = false,
    this.reminderMinutes = -1,
    this.tasks = const [],
  });

  AgendaEvent copyWith({
    String? id,
    String? title,
    EventType? type,
    DateTime? dateTime,
    String? subject,
    String? location,
    String? notes,
    bool? isCompleted,
    int? reminderMinutes,
    List<EventTask>? tasks,
  }) {
    return AgendaEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      subject: subject ?? this.subject,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'dateTime': dateTime.toIso8601String(),
      'subject': subject,
      'location': location,
      'notes': notes,
      'isCompleted': isCompleted,
      'reminderMinutes': reminderMinutes,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory AgendaEvent.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dateTime']?.toString();
    if (rawDate == null || rawDate.isEmpty) {
      throw const FormatException('Fecha de evento ausente');
    }
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) {
      throw const FormatException('Fecha de evento inválida');
    }

    final id = json['id']?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Identificador de evento ausente');
    }

    final title = json['title']?.toString();
    if (title == null || title.trim().isEmpty) {
      throw const FormatException('Título de evento ausente');
    }

    return AgendaEvent(
      id: id,
      title: title,
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.otro,
      ),
      dateTime: parsedDate,
      subject: json['subject']?.toString() ?? 'General',
      location: json['location']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
      reminderMinutes: (json['reminderMinutes'] as num?)?.toInt() ?? -1,
      tasks: _tasksFromJson(json['tasks']),
    );
  }

  static List<EventTask> _tasksFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final tasks = <EventTask>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        try {
          tasks.add(EventTask.fromJson(item));
        } catch (_) {
          // Una tarea dañada no invalida el evento completo.
        }
      }
    }
    return tasks;
  }
}
