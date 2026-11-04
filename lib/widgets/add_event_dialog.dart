import 'package:flutter/material.dart';
import '../models/agenda_event.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';

class AddEventDialog extends StatefulWidget {
  final AgendaEvent? eventToEdit;

  const AddEventDialog({super.key, this.eventToEdit});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  late EventType _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedReminder;
  late final TextEditingController _subjectController;

  static const _reminderOptions = <int, String>{
    -1: 'Sin recordatorio',
    0: 'A la hora del evento',
    10: '10 minutos antes',
    60: '1 hora antes',
    1440: '1 día antes',
  };

  @override
  void initState() {
    super.initState();
    final edit = widget.eventToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _locationController = TextEditingController(text: edit?.location ?? '');
    _notesController = TextEditingController(text: edit?.notes ?? '');
    _subjectController = TextEditingController(text: edit?.subject ?? '');

    _selectedType = edit?.type ?? EventType.examen;
    _selectedDate =
        edit?.dateTime ?? DateTime.now().add(const Duration(days: 1));
    _selectedTime = edit != null
        ? TimeOfDay.fromDateTime(edit.dateTime)
        : const TimeOfDay(hour: 10, minute: 0);
    _selectedReminder = edit?.reminderMinutes ?? -1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final oneYearFromNow = now.add(const Duration(days: 365));

    // Expand the range to include _selectedDate so editing old events doesn't
    // trigger an assertion failure when initialDate falls outside the range.
    final firstDate = _selectedDate.isBefore(thirtyDaysAgo)
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : thirtyDaysAgo;
    final lastDate = _selectedDate.isAfter(oneYearFromNow)
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : oneYearFromNow;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _save(AppState appState) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el título del evento'),
        ),
      );
      return;
    }

    if (_selectedReminder >= 0 && appState.notificationsEnabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!mounted) return;
      if (!granted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Notificaciones bloqueadas'),
            content: const Text(
              'Para recibir recordatorios, activa las notificaciones de Nexora en '
              'Ajustes de Android > Apps > Nexora > Notificaciones. '
              'También puedes guardar el evento sin recordatorio.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        return;
      }

      final exactAlarmsGranted = await NotificationService.instance
          .requestExactAlarmPermission();
      if (!mounted) return;
      if (!exactAlarmsGranted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hora exacta no permitida'),
            content: const Text(
              'El evento se guardará y el recordatorio podrá llegar con retraso. '
              'Para intentar recibirlo a la hora exacta, permite las alarmas '
              'exactas de Nexora en los ajustes de Android.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        if (!mounted) return;
      }
    }

    final eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final subject = _subjectController.text.trim().isEmpty
        ? 'General'
        : _subjectController.text.trim();

    if (widget.eventToEdit != null) {
      final updatedEvent = widget.eventToEdit!.copyWith(
        title: _titleController.text.trim(),
        type: _selectedType,
        dateTime: eventDateTime,
        subject: subject,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        reminderMinutes: _selectedReminder,
      );
      appState.updateEvent(updatedEvent);
    } else {
      final newEvent = AgendaEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        type: _selectedType,
        dateTime: eventDateTime,
        subject: subject,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        reminderMinutes: _selectedReminder,
      );
      appState.addEvent(newEvent);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Map<int, String> _reminderItems() {
    if (_reminderOptions.containsKey(_selectedReminder)) {
      return _reminderOptions;
    }
    return {
      ..._reminderOptions,
      _selectedReminder: '$_selectedReminder minutos antes',
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);
    final isEditing = widget.eventToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar evento' : 'Nueva fecha',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ej. Examen de Álgebra',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Event Type Dropdown
            DropdownButtonFormField<EventType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: type.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),

            // Subject Input
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Materia',
                hintText: 'Ej. Física',
                helperText: 'Se guarda automáticamente en tus materias',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_selectedTime.format(context)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reminder
            DropdownButtonFormField<int>(
              initialValue: _selectedReminder,
              decoration: InputDecoration(
                labelText: 'Recordatorio',
                helperText: appState.notificationsEnabled
                    ? null
                    : 'Notificaciones desactivadas en Configuración',
                prefixIcon: const Icon(Icons.notifications_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _reminderItems().entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedReminder = val);
              },
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Lugar / Aula (opcional)',
                hintText: 'Ej. Aula 204',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description / Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas / Descripción',
                hintText: 'Detalles sobre qué estudiar o entregar...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () => _save(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEditing ? 'Guardar cambios' : 'Guardar Evento',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
