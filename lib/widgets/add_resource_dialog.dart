import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/library_resource.dart';
import '../services/library_storage.dart';
import '../state/app_state.dart';

class AddResourceDialog extends StatefulWidget {
  const AddResourceDialog({super.key});

  @override
  State<AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<AddResourceDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  PickedLibraryFile? _pickedFile;
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (kIsWeb) {
      await _showMessage(
        'La importación de archivos solo está disponible en la app Android.',
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final picked = await LibraryStorage.pick();
      if (picked == null || !mounted) return;

      setState(() {
        _pickedFile = picked;
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = _nameWithoutExtension(picked.name);
        }
      });
    } catch (_) {
      if (mounted) {
        await _showMessage('No se pudo leer el archivo seleccionado.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(AppState appState) async {
    final picked = _pickedFile;
    if (picked == null) {
      await _showMessage('Selecciona un archivo antes de guardarlo.');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      await _showMessage('Por favor, ingresa el título del documento.');
      return;
    }

    setState(() => _busy = true);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final String relativePath;
    try {
      relativePath = await LibraryStorage.save(picked, id);
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        await _showMessage(
          'No se pudo copiar el archivo al almacenamiento de Nexora. '
          'Verifica el espacio disponible e inténtalo de nuevo.',
        );
      }
      return;
    }

    final extension = picked.extension.toUpperCase();
    final newResource = LibraryResource(
      id: id,
      title: _titleController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      fileType: extension.isEmpty ? 'ARCHIVO' : extension,
      fileSize: formatFileSize(picked.size),
      description: _descriptionController.text.trim().isEmpty
          ? 'Sin descripción'
          : _descriptionController.text.trim(),
      dateAdded: DateTime.now(),
      localPath: relativePath,
    );

    appState.addResource(newResource);
    if (mounted) Navigator.of(context).pop();
  }

  String _nameWithoutExtension(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  Future<void> _showMessage(String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

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
                  'Importar archivo',
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

            if (kIsWeb)
              const Text(
                'La importación de archivos solo está disponible en la app '
                'Android. En web puedes revisar la interfaz y los recursos '
                'que ya tengas guardados.',
              )
            else ...[
              _buildFilePicker(theme),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título del documento',
                  hintText: 'Ej. Apuntes de Cálculo I',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Materia / Categoría',
                  hintText: 'Ej. Historia',
                  helperText: 'Se guarda automáticamente en tus materias',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Resumen o notas sobre el material...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _busy ? null : () => _save(appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Importar a la Biblioteca',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker(ThemeData theme) {
    final picked = _pickedFile;

    if (picked == null) {
      return OutlinedButton.icon(
        onPressed: _busy ? null : _pickFile,
        icon: const Icon(Icons.upload_file),
        label: const Text('Seleccionar archivo'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  picked.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  formatFileSize(picked.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _pickFile,
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}
