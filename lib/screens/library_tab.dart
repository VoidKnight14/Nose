import 'package:flutter/material.dart';
import '../models/library_resource.dart';
import '../state/app_state.dart';
import '../widgets/resource_detail_modal.dart';
import '../widgets/add_resource_dialog.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  bool _onlyFavorites = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddResourceDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const AddResourceDialog());
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final theme = Theme.of(context);

    final searchQuery = _searchController.text.trim().toLowerCase();

    final categories = <String>{
      'Todas',
      ...appState.subjects,
      ...appState.resources.map((r) => r.category),
    }.toList();
    final selectedCategory = categories.contains(_selectedCategory)
        ? _selectedCategory
        : 'Todas';

    // Filter resources
    final filteredResources = appState.resources.where((res) {
      final matchesCategory =
          selectedCategory == 'Todas' ||
          res.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesFav = !_onlyFavorites || res.isFavorite;
      final matchesSearch =
          searchQuery.isEmpty ||
          res.title.toLowerCase().contains(searchQuery) ||
          res.category.toLowerCase().contains(searchQuery) ||
          res.description.toLowerCase().contains(searchQuery);

      return matchesCategory && matchesFav && matchesSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar & Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biblioteca Digital',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _onlyFavorites ? Icons.star : Icons.star_border,
                          color: _onlyFavorites ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _onlyFavorites = !_onlyFavorites;
                          });
                        },
                        tooltip: _onlyFavorites
                            ? 'Mostrar todos'
                            : 'Mostrar solo favoritos',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar documentos, guías...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Warning Banner for Damaged Data (if any)
            if (appState.resourcesErrorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                        appState.resourcesErrorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: const Color(0xFF4F46E5),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Resource List
            Expanded(
              child: filteredResources.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              appState.resources.isEmpty
                                  ? Icons.menu_book_outlined
                                  : Icons.folder_off_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appState.resources.isEmpty
                                  ? 'Tu biblioteca está vacía'
                                  : 'No se encontraron documentos',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              appState.resources.isEmpty
                                  ? 'No tienes documentos por defecto. Toca "+ Nuevo recurso" para agregar tus primeros apuntes o libros.'
                                  : 'Intenta cambiando la búsqueda o los filtros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: filteredResources.length,
                      itemBuilder: (context, index) {
                        final resource = filteredResources[index];
                        return _buildResourceCard(
                          context,
                          resource,
                          appState,
                          theme,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddResourceDialog(context),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo recurso'),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    LibraryResource resource,
    AppState appState,
    ThemeData theme,
  ) {
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
            builder: (ctx) => ResourceDetailModal(resource: resource),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Format & Category Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: resource.categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  resource.categoryIcon,
                  color: resource.categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resource.category} • ${resource.fileType} (${resource.fileSize})',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Star Button
              IconButton(
                icon: Icon(
                  resource.isFavorite ? Icons.star : Icons.star_border,
                  color: resource.isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  appState.toggleFavoriteResource(resource.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
