import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/convocatoria_service.dart';

class ManageUsers extends ConsumerStatefulWidget {
  const ManageUsers({super.key});

  @override
  ConsumerState<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends ConsumerState<ManageUsers> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _roleFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ConvocatoriaService.getAllUsers(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      if (mounted) {
        setState(() {
          if (_roleFilter == 'admin') {
            _users = users.where((u) => u['role'] == 'admin').toList();
          } else if (_roleFilter == 'user') {
            _users = users.where((u) => u['role'] != 'admin').toList();
          } else {
            _users = users;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _changeRole(Map<String, dynamic> user, String newRole) async {
    final lang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newRole == 'admin'
              ? (lang == 'es' ? 'Hacer administrador' : 'Make admin')
              : (lang == 'es' ? 'Quitar administrador' : 'Remove admin'),
        ),
        content: Text(
          newRole == 'admin'
              ? (lang == 'es'
                  ? '¿Convertir a "${user['full_name']}" en administrador? Tendrá acceso completo al panel de administración.'
                  : 'Make "${user['full_name']}" an admin? They will have full access to the admin panel.')
              : (lang == 'es'
                  ? '¿Quitar permisos de administrador a "${user['full_name']}"?'
                  : 'Remove admin permissions from "${user['full_name']}"?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang == 'es' ? 'Confirmar' : 'Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConvocatoriaService.updateUserRole(user['id'], newRole);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'es'
                    ? 'Rol actualizado correctamente'
                    : 'Role updated successfully',
              ),
              backgroundColor: const Color(0xFF10b981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final lang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'es' ? 'Eliminar usuario' : 'Delete user'),
        content: Text(
          lang == 'es'
              ? '¿Eliminar a "${user['full_name']}"? Esta acción no se puede deshacer.'
              : 'Delete "${user['full_name']}"? This action cannot be undone.',
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
        await ConvocatoriaService.deleteUser(user['id']);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'es' ? 'Usuario eliminado' : 'User deleted',
              ),
              backgroundColor: const Color(0xFF10b981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final lang = ref.read(localeProvider).languageCode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['full_name'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: lang == 'es' ? 'Organización' : 'Organization',
              value: user['organization'] ?? '-',
            ),
            _DetailRow(
              label: lang == 'es' ? 'País' : 'Country',
              value: user['country'] ?? '-',
            ),
            _DetailRow(
              label: lang == 'es' ? 'Teléfono' : 'Phone',
              value: user['phone'] ?? '-',
            ),
            _DetailRow(
              label: 'Rol',
              value: user['role'] == 'admin'
                  ? (lang == 'es' ? 'Administrador' : 'Admin')
                  : (lang == 'es' ? 'Usuario' : 'User'),
            ),
            _DetailRow(
              label: lang == 'es' ? 'Intereses' : 'Interests',
              value: (user['interests'] as List?)?.isEmpty ?? true
                  ? '-'
                  : (user['interests'] as List).join(', '),
            ),
            _DetailRow(
              label: lang == 'es' ? 'WhatsApp' : 'WhatsApp',
              value: user['whatsapp_enabled'] == true
                  ? (lang == 'es' ? 'Activo' : 'Enabled')
                  : (lang == 'es' ? 'Inactivo' : 'Disabled'),
            ),
            _DetailRow(
              label: lang == 'es' ? 'Registrado' : 'Registered',
              value: user['created_at'] != null
                  ? _formatDate(user['created_at'])
                  : '-',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang == 'es' ? 'Cerrar' : 'Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: lang == 'es'
                          ? 'Buscar por nombre, organización...'
                          : 'Search by name, organization...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadUsers();
                              },
                            )
                          : null,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() => _searchQuery = value);
                      _loadUsers();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'all',
                      label: Text(lang == 'es' ? 'Todos' : 'All'),
                    ),
                    ButtonSegment(
                      value: 'user',
                      label: Text(lang == 'es' ? 'Usuarios' : 'Users'),
                    ),
                    const ButtonSegment(
                      value: 'admin',
                      label: Text('Admins'),
                    ),
                  ],
                  selected: {_roleFilter},
                  onSelectionChanged: (values) {
                    setState(() => _roleFilter = values.first);
                    _loadUsers();
                  },
                ),
              ],
            ),
          ),

          // User count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  lang == 'es'
                      ? '${_users.length} usuario(s)'
                      : '${_users.length} user(s)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Users table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              lang == 'es'
                                  ? 'No se encontraron usuarios'
                                  : 'No users found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                    lang == 'es' ? 'Nombre' : 'Name'),
                              ),
                              DataColumn(
                                label: Text(lang == 'es'
                                    ? 'Organización'
                                    : 'Organization'),
                              ),
                              DataColumn(
                                label: Text(
                                    lang == 'es' ? 'País' : 'Country'),
                              ),
                              DataColumn(
                                label: Text(lang == 'es' ? 'Rol' : 'Role'),
                              ),
                              DataColumn(
                                label: Text(lang == 'es'
                                    ? 'Registrado'
                                    : 'Registered'),
                              ),
                              DataColumn(
                                label: Text(
                                    lang == 'es' ? 'Acciones' : 'Actions'),
                              ),
                            ],
                            rows: _users.map((user) {
                              final isCurrentUser = user['id'] == currentUserId;
                              final isAdmin = user['role'] == 'admin';
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: isAdmin
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme
                                                  .surfaceContainerHighest,
                                          child: Icon(
                                            Icons.person,
                                            size: 18,
                                            color: isAdmin
                                                ? Colors.white
                                                : theme.colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          user['full_name'] ?? '',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(user['organization'] ?? '-'),
                                  ),
                                  DataCell(
                                    Text(user['country'] ?? '-'),
                                  ),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        isAdmin
                                            ? (lang == 'es'
                                                ? 'Admin'
                                                : 'Admin')
                                            : (lang == 'es'
                                                ? 'Usuario'
                                                : 'User'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isAdmin
                                              ? Colors.white
                                              : theme.colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                      ),
                                      backgroundColor: isAdmin
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme
                                              .surfaceContainerHighest,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      user['created_at'] != null
                                          ? _formatDate(user['created_at'])
                                          : '-',
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.visibility_outlined),
                                          tooltip: lang == 'es'
                                              ? 'Ver detalles'
                                              : 'View details',
                                          onPressed: () =>
                                              _showUserDetails(user),
                                        ),
                                        if (!isCurrentUser) ...[
                                          IconButton(
                                            icon: Icon(
                                              isAdmin
                                                  ? Icons
                                                      .admin_panel_settings_outlined
                                                  : Icons.shield_outlined,
                                            ),
                                            tooltip: isAdmin
                                                ? (lang == 'es'
                                                    ? 'Quitar admin'
                                                    : 'Remove admin')
                                                : (lang == 'es'
                                                    ? 'Hacer admin'
                                                    : 'Make admin'),
                                            onPressed: () => _changeRole(
                                              user,
                                              isAdmin ? 'user' : 'admin',
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: theme.colorScheme.error,
                                            ),
                                            tooltip: lang == 'es'
                                                ? 'Eliminar'
                                                : 'Delete',
                                            onPressed: () =>
                                                _deleteUser(user),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
