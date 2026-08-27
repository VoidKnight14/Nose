import 'package:flutter/material.dart';

enum EventType {
  examen,
  entrega,
  presentacion,
  importante,
  otro,
}

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
  bool isCompleted;

  AgendaEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.subject,
    this.location = '',
    this.notes = '',
    this.isCompleted = false,
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
    );
  }
}
