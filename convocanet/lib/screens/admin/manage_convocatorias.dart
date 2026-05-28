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
  String? _statusFilter; // null = all

  @override
  void initState() {
    super.initState();
    _loadConvocatorias();
  }

  Future<void> _loadConvocatorias() async {
    setState(() => _isLoading = true);
    try {
      final convocatorias = await ConvocatoriaService.getConvocatoriasAdmin(
        statusFilter: _statusFilter,
      );
      setState(() {
        _convocatorias = convocatorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveConvocatoria(Convocatoria conv) async {
    final lang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'es' ? 'Aprobar convocatoria' : 'Approve call'),
        content: Text(
          lang == 'es'
              ? '¿Aprobar "${conv.titleEs}"? Verifica que el link funcione antes de aprobar.'
              : 'Approve "${conv.titleEs}"? Verify the link works before approving.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang == 'es' ? 'Aprobar' : 'Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ConvocatoriaService.approveConvocatoria(conv.id);
      _loadConvocatorias();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'es' ? 'Convocatoria aprobada' : 'Call approved',
            ),
            backgroundColor: const Color(0xFF10b981),
          ),
        );
      }
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
                    const SizedBox(height: 16),
                    // Status filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: lang == 'es' ? 'Todas' : 'All',
                            selected: _statusFilter == null,
                            onSelected: () {
                              setState(() => _statusFilter = null);
                              _loadConvocatorias();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: lang == 'es' ? 'Pendientes' : 'Pending',
                            selected: _statusFilter == 'pending',
                            count: _convocatorias.where((c) => c.isPending).length,
                            onSelected: () {
                              setState(() => _statusFilter = 'pending');
                              _loadConvocatorias();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: lang == 'es' ? 'Activas' : 'Active',
                            selected: _statusFilter == 'active',
                            onSelected: () {
                              setState(() => _statusFilter = 'active');
                              _loadConvocatorias();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: lang == 'es' ? 'Permanentes' : 'Permanent',
                            selected: _statusFilter == 'permanent',
                            onSelected: () {
                              setState(() => _statusFilter = 'permanent');
                              _loadConvocatorias();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: lang == 'es' ? 'Vencidas' : 'Expired',
                            selected: _statusFilter == 'expired',
                            onSelected: () {
                              setState(() => _statusFilter = 'expired');
                              _loadConvocatorias();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: lang == 'es' ? 'Borradores' : 'Drafts',
                            selected: _statusFilter == 'draft',
                            onSelected: () {
                              setState(() => _statusFilter = 'draft');
                              _loadConvocatorias();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                    if (conv.isPending)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          size: 20,
                                          color: Color(0xFF10b981),
                                        ),
                                        tooltip: lang == 'es' ? 'Aprobar' : 'Approve',
                                        onPressed: () => _approveConvocatoria(conv),
                                      ),
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
      case 'pending':
        return const Color(0xFF6366f1);
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final int? count;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
