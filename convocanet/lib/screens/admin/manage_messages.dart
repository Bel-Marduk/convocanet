import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../services/convocatoria_service.dart';

class ManageMessages extends ConsumerStatefulWidget {
  const ManageMessages({super.key});

  @override
  ConsumerState<ManageMessages> createState() => _ManageMessagesState();
}

class _ManageMessagesState extends ConsumerState<ManageMessages> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String _readFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      bool? onlyUnread;
      if (_readFilter == 'unread') onlyUnread = true;

      final messages = await ConvocatoriaService.getMessages(
        onlyUnread: onlyUnread,
      );
      if (mounted) {
        setState(() {
          if (_readFilter == 'read') {
            _messages = messages.where((m) => m['read'] == true).toList();
          } else {
            _messages = messages;
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

  Future<void> _toggleRead(Map<String, dynamic> message) async {
    try {
      final isRead = message['read'] == true;
      await ConvocatoriaService.markMessageRead(message['id'], !isRead);
      _loadMessages();
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

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final lang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'es' ? 'Eliminar mensaje' : 'Delete message'),
        content: Text(
          lang == 'es'
              ? '¿Eliminar el mensaje de "${message['name']}"?'
              : 'Delete message from "${message['name']}"?',
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
        await ConvocatoriaService.deleteMessage(message['id']);
        _loadMessages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'es' ? 'Mensaje eliminado' : 'Message deleted',
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

  void _showMessageDetails(Map<String, dynamic> message) {
    final lang = ref.read(localeProvider).languageCode;
    // Mark as read when viewing
    if (message['read'] != true) {
      ConvocatoriaService.markMessageRead(message['id'], true);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message['name'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Email', value: message['email'] ?? '-'),
              if (message['organization'] != null &&
                  (message['organization'] as String).isNotEmpty)
                _DetailRow(
                  label: lang == 'es' ? 'Organización' : 'Organization',
                  value: message['organization'],
                ),
              _DetailRow(
                label: lang == 'es' ? 'Fecha' : 'Date',
                value: message['created_at'] != null
                    ? _formatDateTime(message['created_at'])
                    : '-',
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es' ? 'Mensaje:' : 'Message:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                message['message'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadMessages();
            },
            child: Text(lang == 'es' ? 'Cerrar' : 'Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'all',
                      label: Text(lang == 'es' ? 'Todos' : 'All'),
                    ),
                    ButtonSegment(
                      value: 'unread',
                      label: Text(lang == 'es' ? 'No leídos' : 'Unread'),
                      icon: const Icon(Icons.mark_email_unread_outlined),
                    ),
                    ButtonSegment(
                      value: 'read',
                      label: Text(lang == 'es' ? 'Leídos' : 'Read'),
                      icon: const Icon(Icons.mark_email_read_outlined),
                    ),
                  ],
                  selected: {_readFilter},
                  onSelectionChanged: (values) {
                    setState(() => _readFilter = values.first);
                    _loadMessages();
                  },
                ),
                const Spacer(),
                Text(
                  lang == 'es'
                      ? '${_messages.length} mensaje(s)'
                      : '${_messages.length} message(s)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              lang == 'es'
                                  ? 'No hay mensajes'
                                  : 'No messages',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isRead = message['read'] == true;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isRead
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : theme.colorScheme.primary,
                                child: Icon(
                                  isRead
                                      ? Icons.mail_outlined
                                      : Icons.mail_outline,
                                  color: isRead
                                      ? theme.colorScheme.onSurfaceVariant
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                message['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['email'] ?? '',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message['message'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (message['created_at'] != null)
                                    Text(
                                      _formatShortDate(
                                          message['created_at']),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      isRead
                                          ? Icons
                                              .mark_email_unread_outlined
                                          : Icons.mark_email_read_outlined,
                                    ),
                                    tooltip: isRead
                                        ? (lang == 'es'
                                            ? 'Marcar no leído'
                                            : 'Mark unread')
                                        : (lang == 'es'
                                            ? 'Marcar leído'
                                            : 'Mark read'),
                                    onPressed: () => _toggleRead(message),
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
                                        _deleteMessage(message),
                                  ),
                                ],
                              ),
                              onTap: () => _showMessageDetails(message),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
  }

  String _formatShortDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
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
            width: 100,
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
