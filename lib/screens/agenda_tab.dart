import 'package:flutter/material.dart';
import '../models/agenda_event.dart';
import '../state/app_state.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/event_detail_modal.dart';

class AgendaTab extends StatefulWidget {
  const AgendaTab({super.key});

  @override
  State<AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  EventType? _selectedFilter;

  final months = [
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
    'Diciembre'
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

    final filteredEvents = _selectedFilter == null
        ? appState.events
        : appState.events.where((e) => e.type == _selectedFilter).toList();

    // Sort chronologically
    final sortedEvents = List<AgendaEvent>.from(filteredEvents)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final now = DateTime.now();
    final currentMonthYear = '${months[now.month - 1]} ${now.year}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Month Header & Mini Calendar Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentMonthYear,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5)),
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
                  const SizedBox(height: 12),

                  // Days of week strip simulation
                  _buildDayStrip(theme, now),
                ],
              ),
            ),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedFilter == null,
                    onSelected: (val) {
                      setState(() => _selectedFilter = null);
                    },
                    selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.2),
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
            const SizedBox(height: 12),

            // Events List
            Expanded(
              child: sortedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay fechas programadas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toca el botón "+" para agregar un nuevo evento.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
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

  Widget _buildDayStrip(ThemeData theme, DateTime now) {
    final daysOfWeek = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final dayNum = now.day - (now.weekday - 1) + i;
        final isToday = i == (now.weekday - 1);

        return Column(
          children: [
            Text(
              daysOfWeek[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isToday ? const Color(0xFF4F46E5) : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF4F46E5) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$dayNum',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEventListItem(
      BuildContext context, AgendaEvent event, ThemeData theme) {
    final formattedTime =
        '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';
    final dateStr = '${event.dateTime.day}/${event.dateTime.month}';

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
                        decoration:
                            event.isCompleted ? TextDecoration.lineThrough : null,
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
