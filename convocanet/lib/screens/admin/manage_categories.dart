import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../models/category.dart';
import '../../services/convocatoria_service.dart';

class ManageCategories extends ConsumerStatefulWidget {
  const ManageCategories({super.key});

  @override
  ConsumerState<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends ConsumerState<ManageCategories> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await ConvocatoriaService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final lang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'es' ? 'Eliminar categoría' : 'Delete category'),
        content: Text(
          lang == 'es'
              ? '¿Eliminar "${category.nameEs}"? Las convocatorias asociadas perderán esta categoría.'
              : 'Delete "${category.nameEs}"? Associated calls will lose this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(lang == 'es' ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ConvocatoriaService.deleteCategory(category.id);
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang == 'es' ? 'Categoría eliminada' : 'Category deleted'),
            ),
          );
        }
      } catch (e) {
        _showError('Error: $e');
      }
    }
  }

  Future<void> _showCategoryDialog({Category? category}) async {
    final lang = ref.read(localeProvider).languageCode;
    final isEditing = category != null;
    final nameEsCtrl = TextEditingController(text: category?.nameEs ?? '');
    final nameEnCtrl = TextEditingController(text: category?.nameEn ?? '');
    final slugCtrl = TextEditingController(text: category?.slug ?? '');
    final iconCtrl = TextEditingController(text: category?.icon ?? '');
    final colorCtrl = TextEditingController(text: category?.color ?? '#4f46e5');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing
            ? (lang == 'es' ? 'Editar categoría' : 'Edit category')
            : (lang == 'es' ? 'Nueva categoría' : 'New category')),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameEsCtrl,
                decoration: InputDecoration(
                  labelText: lang == 'es' ? 'Nombre (ES)' : 'Name (ES)',
                  hintText: 'Educación',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameEnCtrl,
                decoration: InputDecoration(
                  labelText: lang == 'es' ? 'Nombre (EN)' : 'Name (EN)',
                  hintText: 'Education',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: slugCtrl,
                decoration: InputDecoration(
                  labelText: 'Slug',
                  hintText: 'educacion',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: iconCtrl,
                      decoration: InputDecoration(
                        labelText: lang == 'es' ? 'Ícono (Material)' : 'Icon (Material)',
                        hintText: 'school',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: colorCtrl,
                      decoration: InputDecoration(
                        labelText: lang == 'es' ? 'Color (hex)' : 'Color (hex)',
                        hintText: '#4f46e5',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang == 'es' ? 'Guardar' : 'Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final data = {
        'name_es': nameEsCtrl.text.trim(),
        'name_en': nameEnCtrl.text.trim(),
        'slug': slugCtrl.text.trim(),
        'icon': iconCtrl.text.trim().isNotEmpty ? iconCtrl.text.trim() : null,
        'color': colorCtrl.text.trim().isNotEmpty ? colorCtrl.text.trim() : null,
      };

      try {
        if (isEditing) {
          await ConvocatoriaService.updateCategory(category.id, data);
        } else {
          await ConvocatoriaService.createCategory(data);
        }
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? (lang == 'es' ? 'Categoría actualizada' : 'Category updated')
                  : (lang == 'es' ? 'Categoría creada' : 'Category created')),
            ),
          );
        }
      } catch (e) {
        _showError('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      lang == 'es' ? 'Gestionar Categorías' : 'Manage Categories',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _showCategoryDialog(),
                      icon: const Icon(Icons.add),
                      label: Text(lang == 'es' ? 'Nueva Categoría' : 'New Category'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Table
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(lang == 'es' ? 'Ícono' : 'Icon'),
                        ),
                        DataColumn(
                          label: Text(lang == 'es' ? 'Nombre (ES)' : 'Name (ES)'),
                        ),
                        DataColumn(
                          label: Text(lang == 'es' ? 'Nombre (EN)' : 'Name (EN)'),
                        ),
                        DataColumn(
                          label: const Text('Slug'),
                        ),
                        DataColumn(
                          label: Text(lang == 'es' ? 'Color' : 'Color'),
                        ),
                        DataColumn(
                          label: Text(lang == 'es' ? 'Acciones' : 'Actions'),
                        ),
                      ],
                      rows: _categories.map((cat) {
                        return DataRow(cells: [
                          DataCell(
                            cat.icon != null
                                ? Icon(_getIconData(cat.icon!), size: 20)
                                : const Icon(Icons.category, size: 20),
                          ),
                          DataCell(Text(cat.nameEs)),
                          DataCell(Text(cat.nameEn)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cat.slug,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _parseColor(cat.color),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat.color ?? '#4f46e5',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: lang == 'es' ? 'Editar' : 'Edit',
                                  onPressed: () => _showCategoryDialog(category: cat),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: lang == 'es' ? 'Eliminar' : 'Delete',
                                  onPressed: () => _deleteCategory(cat),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF4f46e5);
    String h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
      'school': Icons.school,
      'science': Icons.science,
      'health_and_safety': Icons.health_and_safety,
      'favorite': Icons.favorite,
      'eco': Icons.eco,
      'palette': Icons.palette,
      'groups': Icons.groups,
      'business': Icons.business,
      'computer': Icons.computer,
      'public': Icons.public,
      'volunteer_activism': Icons.volunteer_activism,
      'architecture': Icons.architecture,
      'auto_stories': Icons.auto_stories,
      'biotech': Icons.biotech,
      'diversity_3': Icons.diversity_3,
      'emoji_objects': Icons.emoji_objects,
      'engineering': Icons.engineering,
      'fitness_center': Icons.fitness_center,
      'gavel': Icons.gavel,
      'handshake': Icons.handshake,
      'local_library': Icons.local_library,
      'medical_services': Icons.medical_services,
      'psychology': Icons.psychology,
      'restaurant': Icons.restaurant,
      'sports_esports': Icons.sports_esports,
      'theater_comedy': Icons.theater_comedy,
      'translate': Icons.translate,
      'work': Icons.work,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
