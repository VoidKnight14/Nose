import 'package:flutter/material.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _gradeController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _gradeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = AppStateScope.of(context);
    if (!_isEditing) {
      _nameController.text = appState.userProfile.name;
      _gradeController.text = appState.userProfile.grade;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _saveProfile(AppState appState) {
    appState.updateUserProfile(
      _nameController.text,
      _gradeController.text,
    );
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);
    final profile = appState.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Estudiantil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile(appState);
              } else {
                setState(() => _isEditing = true);
              }
            },
            tooltip: _isEditing ? 'Guardar' : 'Editar perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // User Avatar Box
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    child: const Text(
                      '👤',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F46E5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile info or edit form
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Curso',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveProfile(appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Guardar cambios'),
              ),
            ] else ...[
              Text(
                profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(profile.grade),
                backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                side: BorderSide.none,
              ),
            ],

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Settings list
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '⚙️ Configuración',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Notificaciones'),
              subtitle: const Text('Recordatorios de exámenes y entregas'),
              value: appState.notificationsEnabled,
              onChanged: (val) => appState.toggleNotifications(val),
              activeThumbColor: const Color(0xFF4F46E5),
            ),
            const Divider(height: 1),

            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Apariencia / Modo Oscuro'),
              subtitle: const Text('Cambiar tema de la aplicación'),
              value: appState.isDarkMode,
              onChanged: (val) => appState.toggleDarkMode(val),
              activeThumbColor: const Color(0xFF4F46E5),
            ),
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Privacidad'),
              subtitle: const Text('Control de datos y cuenta local'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tus datos se guardan localmente en el dispositivo.')),
                );
              },
            ),
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de la app'),
              subtitle: const Text('Mi Colegio v1.0.0 • Hecho en Flutter'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Mi Colegio',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.school, size: 40, color: Color(0xFF4F46E5)),
                  children: [
                    const Text('Aplicación estudiantil completa con Agenda, Biblioteca y Logros.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
