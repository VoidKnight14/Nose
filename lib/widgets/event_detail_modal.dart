import 'package:flutter/material.dart';
import '../models/agenda_event.dart';
import '../state/app_state.dart';

class EventDetailModal extends StatelessWidget {
  final AgendaEvent event;

  const EventDetailModal({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

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
      'diciembre'
    ];
    final dayName = _getDayName(event.dateTime.weekday);
    final formattedDate =
        '$dayName ${event.dateTime.day} de ${months[event.dateTime.month - 1]}';
    final formattedTime =
        '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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

            // Header category chip & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.type.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(event.type.icon, size: 16, color: event.type.color),
                      const SizedBox(width: 6),
                      Text(
                        event.type.label,
                        style: TextStyle(
                          color: event.type.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    event.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: event.isCompleted ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    appState.toggleEventCompleted(event.id);
                    Navigator.pop(context);
                  },
                  tooltip: event.isCompleted ? 'Marcar incompleto' : 'Marcar completado',
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: event.isCompleted ? TextDecoration.lineThrough : null,
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

            if (event.location.isNotEmpty) ...[
              _buildDetailRow(
                context,
                icon: Icons.location_on_outlined,
                title: 'Lugar',
                value: event.location,
              ),
              const SizedBox(height: 12),
            ],

            _buildDetailRow(
              context,
              icon: Icons.book_outlined,
              title: 'Materia',
              value: event.subject,
            ),
            const SizedBox(height: 16),

            if (event.notes.isNotEmpty) ...[
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
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.notes,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      appState.deleteEvent(event.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
                      appState.toggleEventCompleted(event.id);
                      Navigator.pop(context);
                    },
                    icon: Icon(event.isCompleted ? Icons.undo : Icons.check),
                    label: Text(event.isCompleted ? 'Reabrir' : 'Completar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.isCompleted ? Colors.orange : Colors.green,
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
