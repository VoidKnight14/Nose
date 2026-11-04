import 'package:flutter/material.dart';
import '../models/library_resource.dart';
import '../services/library_storage.dart';
import '../state/app_state.dart';
import '../screens/pdf_viewer_screen.dart';

class ResourceDetailModal extends StatelessWidget {
  final LibraryResource resource;

  const ResourceDetailModal({super.key, required this.resource});

  void _confirmDelete(BuildContext context, AppState appState, String resourceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar recurso'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este recurso de la biblioteca? Esta acción no se puede deshacer.',
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
              appState.deleteResource(resourceId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openResource(
    BuildContext context,
    AppState appState,
    LibraryResource resource,
  ) async {
    if (!resource.hasFile) {
      await _showMessage(
        context,
        'Este recurso se creó antes de la Fase 3 y no tiene un archivo guardado. '
        'Elimínalo y vuelve a importarlo para poder abrirlo.',
      );
      return;
    }

    if (!await LibraryStorage.exists(resource.localPath)) {
      if (context.mounted) {
        await _showMessage(context, 'El archivo ya no está en el dispositivo.');
      }
      return;
    }

    if (resource.fileType.toUpperCase() != 'PDF') {
      final error = await LibraryStorage.openExternally(resource.localPath);
      if (error != null) {
        if (context.mounted) await _showMessage(context, error);
        return;
      }
      appState.incrementReadCount(resource.id);
      return;
    }

    final path = await LibraryStorage.absolutePath(resource.localPath);
    if (path == null) {
      if (context.mounted) {
        await _showMessage(context, 'El archivo ya no está en el dispositivo.');
      }
      return;
    }

    appState.incrementReadCount(resource.id);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfViewerScreen(path: path, title: resource.title),
      ),
    );
  }

  Future<void> _showMessage(BuildContext context, String message) {
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

    // Look up latest resource from AppState
    final currentResource = appState.resources.firstWhere(
      (r) => r.id == resource.id,
      orElse: () => resource,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Big Icon Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: currentResource.categoryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentResource.categoryIcon,
                size: 36,
                color: currentResource.categoryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              currentResource.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Meta Info (Category + FileSize + Type)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  avatar: Icon(
                    currentResource.categoryIcon,
                    size: 14,
                    color: currentResource.categoryColor,
                  ),
                  label: Text(
                    currentResource.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: currentResource.categoryColor,
                    ),
                  ),
                  backgroundColor: currentResource.categoryColor.withValues(alpha: 0.12),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  '${currentResource.fileType} • ${currentResource.fileSize}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Abrir archivo real o avisar que no existe
            if (currentResource.hasFile) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _openResource(context, appState, currentResource),
                  icon: Icon(
                    currentResource.fileType.toUpperCase() == 'PDF'
                        ? Icons.picture_as_pdf_outlined
                        : Icons.open_in_new,
                  ),
                  label: Text(
                    currentResource.fileType.toUpperCase() == 'PDF'
                        ? 'Abrir PDF'
                        : 'Abrir con otra app',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Este recurso no tiene un archivo guardado. '
                        'Elimínalo y vuelve a importarlo para abrirlo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Secondary Actions Row: Favorito & Eliminar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => appState.toggleFavoriteResource(currentResource.id),
                    icon: Icon(
                      currentResource.isFavorite ? Icons.star : Icons.star_border,
                      color: currentResource.isFavorite ? Colors.amber : null,
                    ),
                    label: Text(
                      currentResource.isFavorite ? 'Favorito' : 'Marcar fav',
                      style: TextStyle(
                        color: currentResource.isFavorite ? Colors.amber : null,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, appState, currentResource.id),
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
              ],
            ),
            const SizedBox(height: 24),

            // Description Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Descripción',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                currentResource.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
