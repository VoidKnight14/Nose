import 'package:flutter/material.dart';
import '../models/agenda_event.dart';
import '../state/app_state.dart';
import 'add_event_dialog.dart';

class EventDetailModal extends StatelessWidget {
  final AgendaEvent event;

  const EventDetailModal({super.key, required this.event});

  void _confirmDelete(BuildContext context, AppState appState, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              appState.deleteEvent(eventId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(
    BuildContext context,
    AppState appState,
    String eventId,
  ) async {
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) {
        var value = '';
        return AlertDialog(
          title: const Text('Nuevo paso'),
          content: TextField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Paso de estudio',
              hintText: 'Ej. Repasar la unidad 3',
            ),
            onChanged: (text) => value = text,
            onSubmitted: (text) => Navigator.pop(ctx, text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, value),
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
    if (title != null) appState.addEventTask(eventId, title);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

    // Look up latest event from AppState
    final currentEvent = appState.events.firstWhere(
      (e) => e.id == event.id,
      orElse: () => event,
    );

    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final dayName = _getDayName(currentEvent.dateTime.weekday);
    final formattedDate =
        '$dayName ${currentEvent.dateTime.day} de ${months[currentEvent.dateTime.month - 1]}';
    final formattedTime =
        '${currentEvent.dateTime.hour.toString().padLeft(2, '0')}:${currentEvent.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header category chip & Actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: currentEvent.type.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentEvent.type.icon,
                          size: 16,
                          color: currentEvent.type.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentEvent.type.label,
                          style: TextStyle(
                            color: currentEvent.type.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar evento',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            AddEventDialog(eventToEdit: currentEvent),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      currentEvent.isCompleted
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: currentEvent.isCompleted
                          ? Colors.green
                          : Colors.grey,
                    ),
                    onPressed: () {
                      appState.toggleEventCompleted(currentEvent.id);
                    },
                    tooltip: currentEvent.isCompleted
                        ? 'Marcar incompleto'
                        : 'Marcar completado',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                currentEvent.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: currentEvent.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Details List
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                title: 'Fecha',
                value: formattedDate,
              ),
              const SizedBox(height: 12),

              _buildDetailRow(
                context,
                icon: Icons.access_time,
                title: 'Hora',
                value: '$formattedTime hs',
              ),
              const SizedBox(height: 12),

              if (currentEvent.location.isNotEmpty) ...[
                _buildDetailRow(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Lugar',
                  value: currentEvent.location,
                ),
                const SizedBox(height: 12),
              ],

              _buildDetailRow(
                context,
                icon: Icons.book_outlined,
                title: 'Materia',
                value: currentEvent.subject,
              ),
              const SizedBox(height: 16),

              if (currentEvent.notes.isNotEmpty) ...[
                Text(
                  'Notas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentEvent.notes,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Checklist
              _buildChecklist(context, appState, currentEvent),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _confirmDelete(context, appState, currentEvent.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appState.toggleEventCompleted(currentEvent.id);
                      },
                      icon: Icon(
                        currentEvent.isCompleted ? Icons.undo : Icons.check,
                      ),
                      label: Text(
                        currentEvent.isCompleted ? 'Reabrir' : 'Completar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentEvent.isCompleted
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklist(
    BuildContext context,
    AppState appState,
    AgendaEvent event,
  ) {
    final theme = Theme.of(context);
    final done = event.tasks.where((task) => task.isDone).length;
    final total = event.tasks.length;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Checklist',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (total > 0)
                Text(
                  '$done/$total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Añadir paso',
                onPressed: () => _addTask(context, appState, event.id),
              ),
            ],
          ),
          if (total == 0)
            Text(
              'Divide el evento en pasos de estudio, por ejemplo: repasar '
              'apuntes, resolver ejercicios o ensayar la presentación.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: done / total,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            for (final task in event.tasks)
              CheckboxListTile(
                value: task.isDone,
                onChanged: (_) => appState.toggleEventTask(event.id, task.id),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                secondary: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Eliminar paso',
                  onPressed: () => appState.deleteEventTask(event.id, task.id),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$title: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return '';
    }
  }
}
