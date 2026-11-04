import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _addSubject(AppState appState) {
    appState.addSubject(_subjectController.text);
    _subjectController.clear();
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    AppState appState,
    bool value,
  ) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!context.mounted) return;
      if (!granted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Notificaciones bloqueadas'),
            content: const Text(
              'Activa las notificaciones de Nexora en Ajustes de Android > '
              'Apps > Nexora > Notificaciones para recibir recordatorios.',
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
    }
    await appState.toggleNotifications(value);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nexora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Agenda y Biblioteca Digital',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'PREFERENCIAS',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Cambiar entre tema claro y oscuro'),
                  value: appState.isDarkMode,
                  onChanged: (val) => appState.toggleDarkMode(val),
                  activeThumbColor: const Color(0xFF4F46E5),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notificaciones'),
                  subtitle: const Text(
                    'Recordatorios locales de tus eventos (Android)',
                  ),
                  value: appState.notificationsEnabled,
                  onChanged: (val) =>
                      _toggleNotifications(context, appState, val),
                  activeThumbColor: const Color(0xFF4F46E5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'MATERIAS',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subjectController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addSubject(appState),
                          decoration: InputDecoration(
                            labelText: 'Nueva materia',
                            hintText: 'Ej. Física',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: () => _addSubject(appState),
                        icon: const Icon(Icons.add),
                        tooltip: 'Añadir materia',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (appState.subjects.isEmpty)
                    Text(
                      'Aún no tienes materias. Añade las que uses para organizar '
                      'eventos y recursos; también se crean al escribir una '
                      'materia nueva en un evento o recurso.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final subject in appState.subjects)
                          InputChip(
                            label: Text(subject),
                            onDeleted: () => appState.removeSubject(subject),
                            deleteIcon: const Icon(Icons.close, size: 16),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'INFORMACIÓN',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 22,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Almacenamiento Local y Privacidad',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nexora guarda tus datos solo en este dispositivo. Al desinstalar la app, se borrarán y no podrán recuperarse.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Acerca de la app'),
                  subtitle: const Text('Nexora v1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Nexora',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.school,
                        size: 40,
                        color: Color(0xFF4F46E5),
                      ),
                      children: const [
                        Text(
                          'Aplicación estudiantil con Agenda y Biblioteca Digital.',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nexora guarda tus datos solo en este dispositivo. Al desinstalar la app, se borrarán y no podrán recuperarse.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
