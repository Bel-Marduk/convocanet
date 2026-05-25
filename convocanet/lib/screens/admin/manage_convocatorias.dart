import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../models/convocatoria.dart';
import '../../services/convocatoria_service.dart';

class ManageConvocatorias extends ConsumerStatefulWidget {
  const ManageConvocatorias({super.key});

  @override
  ConsumerState<ManageConvocatorias> createState() =>
      _ManageConvocatoriasState();
}

class _ManageConvocatoriasState extends ConsumerState<ManageConvocatorias> {
  List<Convocatoria> _convocatorias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConvocatorias();
  }

  Future<void> _loadConvocatorias() async {
    try {
      final convocatorias = await ConvocatoriaService.getConvocatorias(
        status: null, // Get all statuses for admin
      );
      setState(() {
        _convocatorias = convocatorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteConvocatoria(String id) async {
    final lang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'es' ? 'Eliminar' : 'Delete'),
        content: Text(
          lang == 'es'
              ? '¿Estás seguro de eliminar esta convocatoria?'
              : 'Are you sure you want to delete this call?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(lang == 'es' ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ConvocatoriaService.deleteConvocatoria(id);
      _loadConvocatorias();
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lang == 'es' ? 'Gestionar Convocatorias' : 'Manage Calls',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(lang == 'es' ? 'Nueva' : 'New'),
                          onPressed: () => context.go('/admin/convocatorias/new'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              lang == 'es' ? 'Título' : 'Title',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              lang == 'es' ? 'Categoría' : 'Category',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              lang == 'es' ? 'Monto' : 'Amount',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              lang == 'es' ? 'Estado' : 'Status',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              lang == 'es' ? 'Acciones' : 'Actions',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                        rows: _convocatorias.map((conv) {
                          return DataRow(
                            cells: [
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 250),
                                  child: Text(
                                    conv.title(lang),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text(conv.categoryName(lang) ?? '')),
                              DataCell(Text(conv.formattedAmount)),
                              DataCell(
                                Chip(
                                  label: Text(
                                    conv.statusLabel(lang),
                                    style: TextStyle(
                                      color: _getStatusColor(conv.status),
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor:
                                      _getStatusColor(conv.status).withOpacity(0.1),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => context.go(
                                        '/admin/convocatorias/${conv.id}/edit',
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: theme.colorScheme.error,
                                      ),
                                      onPressed: () =>
                                          _deleteConvocatoria(conv.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF10b981);
      case 'permanent':
        return const Color(0xFFF59e0b);
      case 'expired':
        return const Color(0xFFEf4444);
      default:
        return const Color(0xFF4f46e5);
    }
  }
}
