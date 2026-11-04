import 'package:flutter/material.dart';
import '../models/agenda_event.dart';
import '../state/app_state.dart';
import '../utils/calendar_utils.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/event_detail_modal.dart';

class AgendaTab extends StatefulWidget {
  const AgendaTab({super.key});

  @override
  State<AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  EventType? _selectedFilter;
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  final List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  void _previousMonth() {
    setState(() {
      _focusedDate = CalendarUtils.previousMonth(_focusedDate);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = CalendarUtils.nextMonth(_focusedDate);
      _selectedDate = null;
    });
  }

  void _previousWeek() {
    setState(() {
      _focusedDate = CalendarUtils.previousWeek(_focusedDate);
      _selectedDate = null;
    });
  }

  void _nextWeek() {
    setState(() {
      _focusedDate = CalendarUtils.nextWeek(_focusedDate);
      _selectedDate = null;
    });
  }

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _focusedDate = now;
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Filter events
    final filteredEvents = appState.events.where((e) {
      final matchesFilter =
          _selectedFilter == null || e.type == _selectedFilter;
      final matchesDate =
          _selectedDate == null ||
          CalendarUtils.isSameDay(e.dateTime, _selectedDate);
      return matchesFilter && matchesDate;
    }).toList();

    // Sort chronologically
    final sortedEvents = List<AgendaEvent>.from(filteredEvents)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final currentMonthYear =
        '${_months[_focusedDate.month - 1]} ${_focusedDate.year}';
    final isViewingCurrentMonth =
        _focusedDate.year == now.year && _focusedDate.month == now.month;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Month Header & Navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Month title
                      Expanded(
                        child: Text(
                          currentMonthYear,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Today quick-jump button
                      if (!isViewingCurrentMonth ||
                          (_selectedDate != null &&
                              !CalendarUtils.isSameDay(_selectedDate, now)))
                        TextButton(
                          onPressed: _goToToday,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Hoy'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                        tooltip: 'Mes anterior',
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                        tooltip: 'Mes siguiente',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF4F46E5),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const AddEventDialog(),
                          );
                        },
                        tooltip: 'Agregar evento',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Calendar Week Strip with real dates
                  _buildDayStrip(theme, appState, now),
                ],
              ),
            ),

            // Warning Banner for Damaged Data (if any)
            if (appState.eventsErrorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade700.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        appState.eventsErrorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Date Selection Indicator (if a date is selected)
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Día: ${_selectedDate!.day} de ${_months[_selectedDate!.month - 1]} ${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() => _selectedDate = null);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Ver todos',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.close,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedFilter == null,
                    onSelected: (val) {
                      setState(() => _selectedFilter = null);
                    },
                    selectedColor: const Color(
                      0xFF4F46E5,
                    ).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF4F46E5),
                  ),
                  const SizedBox(width: 8),
                  ...EventType.values.map((type) {
                    final isSelected = _selectedFilter == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        avatar: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        label: Text(type.label),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedFilter = val ? type : null;
                          });
                        },
                        selectedColor: type.color.withValues(alpha: 0.2),
                        checkmarkColor: type.color,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Events List
            Expanded(
              child: sortedEvents.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_outlined,
                              size: 56,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedDate != null
                                  ? 'No hay eventos para esta fecha'
                                  : 'No hay fechas programadas',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedDate != null
                                  ? 'Toca "Ver todos" o selecciona otro día en el calendario.'
                                  : 'Toca el botón "+" para agregar un nuevo evento.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            if (_selectedDate != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() => _selectedDate = null);
                                },
                                child: const Text('Ver todos los eventos'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: sortedEvents.length,
                      itemBuilder: (context, index) {
                        final event = sortedEvents[index];
                        return _buildEventListItem(context, event, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const AddEventDialog(),
          );
        },
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva fecha'),
      ),
    );
  }

  Widget _buildDayStrip(ThemeData theme, AppState appState, DateTime now) {
    final daysOfWeek = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final weekDays = CalendarUtils.getDaysOfWeek(_focusedDate);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: _previousWeek,
          tooltip: 'Semana anterior',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Expanded(
          child: Row(
            children: List.generate(7, (i) {
              final dayDate = weekDays[i];
              final isToday = CalendarUtils.isSameDay(dayDate, now);
              final isSelected =
                  _selectedDate != null &&
                  CalendarUtils.isSameDay(dayDate, _selectedDate);
              final hasEvents = appState.events.any(
                (e) => CalendarUtils.isSameDay(e.dateTime, dayDate),
              );
              final isCurrentFocusedMonth = dayDate.month == _focusedDate.month;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDate = null; // Toggle off to see all
                      } else {
                        _selectedDate = dayDate;
                        _focusedDate = dayDate;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          daysOfWeek[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : isToday
                                ? const Color(0xFF4F46E5)
                                : isCurrentFocusedMonth
                                ? Colors.grey
                                : Colors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : isToday
                                ? const Color(
                                    0xFF4F46E5,
                                  ).withValues(alpha: 0.15)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: const Color(0xFF4F46E5),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${dayDate.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? const Color(0xFF4F46E5)
                                  : isCurrentFocusedMonth
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Dot indicator for days with events
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: hasEvents
                                ? (isSelected
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFFF59E0B))
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: _nextWeek,
          tooltip: 'Semana siguiente',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildEventListItem(
    BuildContext context,
    AgendaEvent event,
    ThemeData theme,
  ) {
    final formattedTime =
        '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) => EventDetailModal(event: event),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: event.type.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Event Type Indicator Badge
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: event.type.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: event.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: event.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.subject} • $dateStr a las $formattedTime hs',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
