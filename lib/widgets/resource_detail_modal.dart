import 'package:flutter/material.dart';
import '../models/library_resource.dart';
import '../state/app_state.dart';

class ResourceDetailModal extends StatelessWidget {
  final LibraryResource resource;

  const ResourceDetailModal({super.key, required this.resource});

  void _openDocument(BuildContext context, AppState appState) {
    appState.incrementReadCount(resource.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(resource.categoryIcon, color: resource.categoryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                resource.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 48,
                      color: resource.categoryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Visualizador PDF (${resource.fileSize})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Documento: ${resource.title}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              resource.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

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
                color: resource.categoryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                resource.categoryIcon,
                size: 36,
                color: resource.categoryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              resource.title,
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
                    resource.categoryIcon,
                    size: 14,
                    color: resource.categoryColor,
                  ),
                  label: Text(
                    resource.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: resource.categoryColor,
                    ),
                  ),
                  backgroundColor: resource.categoryColor.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  '${resource.fileType} • ${resource.fileSize}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action: Abrir documento
            ElevatedButton.icon(
              onPressed: () => _openDocument(context, appState),
              icon: const Icon(Icons.menu_book),
              label: const Text(
                'Abrir documento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 12),

            // Action: Favorito toggle
            OutlinedButton.icon(
              onPressed: () => appState.toggleFavoriteResource(resource.id),
              icon: Icon(
                resource.isFavorite ? Icons.star : Icons.star_border,
                color: resource.isFavorite ? Colors.amber : null,
              ),
              label: Text(
                resource.isFavorite
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                style: TextStyle(
                  color: resource.isFavorite ? Colors.amber.shade900 : null,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
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
                resource.description,
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
