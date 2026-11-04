class EventTask {
  final String id;
  final String title;
  final bool isDone;

  const EventTask({required this.id, required this.title, this.isDone = false});

  EventTask copyWith({String? title, bool? isDone}) {
    return EventTask(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  factory EventTask.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Identificador de tarea ausente');
    }

    final title = json['title']?.toString();
    if (title == null || title.trim().isEmpty) {
      throw const FormatException('Título de tarea ausente');
    }

    return EventTask(
      id: id,
      title: title.trim(),
      isDone: json['isDone'] == true,
    );
  }
}
