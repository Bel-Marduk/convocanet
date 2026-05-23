import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/convocatoria.dart';
import '../../services/convocatoria_service.dart';
import '../../services/whatsapp_service.dart';

class ConvocatoriaDetailScreen extends ConsumerStatefulWidget {
  final String convocatoriaId;

  const ConvocatoriaDetailScreen({
    super.key,
    required this.convocatoriaId,
  });

  @override
  ConsumerState<ConvocatoriaDetailScreen> createState() =>
      _ConvocatoriaDetailScreenState();
}

class _ConvocatoriaDetailScreenState
    extends ConsumerState<ConvocatoriaDetailScreen> {
  Convocatoria? _convocatoria;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadConvocatoria();
  }

  Future<void> _loadConvocatoria() async {
    try {
      final convocatoria =
          await ConvocatoriaService.getConvocatoriaById(widget.convocatoriaId);
      if (convocatoria != null) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          final isFav =
              await ConvocatoriaService.isFavorite(user.id, convocatoria.id);
          setState(() => _isFavorite = isFav);
        }
      }
      setState(() {
        _convocatoria = convocatoria;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _convocatoria == null) return;

    final isFav = await ConvocatoriaService.toggleFavorite(
      user.id,
      _convocatoria!.id,
    );
    setState(() => _isFavorite = isFav);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFav
                ? (ref.read(localeProvider).languageCode == 'es'
                    ? 'Agregado a favoritos'
                    : 'Added to favorites')
                : (ref.read(localeProvider).languageCode == 'es'
                    ? 'Eliminado de favoritos'
                    : 'Removed from favorites'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_convocatoria == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            lang == 'es' ? 'Convocatoria no encontrada' : 'Call not found',
          ),
        ),
      );
    }

    final conv = _convocatoria!;

    return Scaffold(
      appBar: AppBar(
        title: Text(conv.title(lang)),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => WhatsappService.shareConvocatoria(conv, lang),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and status
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(conv.categoryName(lang) ?? ''),
                      backgroundColor: _getCategoryColor(conv.categorySlug)
                          .withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getCategoryColor(conv.categorySlug),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Chip(
                      label: Text(conv.statusLabel(lang)),
                      backgroundColor: _getStatusColor(conv.status)
                          .withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getStatusColor(conv.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!conv.isPublic)
                      Chip(
                        label: Text(lang == 'es' ? 'Privado' : 'Private'),
                        backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  conv.title(lang),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  conv.description(lang),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Details grid
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _DetailCard(
                      label: lang == 'es' ? 'Monto' : 'Amount',
                      value: conv.formattedAmount,
                      icon: Icons.attach_money,
                    ),
                    if (conv.deadline != null)
                      _DetailCard(
                        label: lang == 'es' ? 'Fecha límite' : 'Deadline',
                        value:
                            '${conv.deadline!.day}/${conv.deadline!.month}/${conv.deadline!.year}',
                        icon: Icons.calendar_today,
                      ),
                    if (conv.region(lang) != null)
                      _DetailCard(
                        label: lang == 'es' ? 'Región' : 'Region',
                        value: conv.region(lang)!,
                        icon: Icons.location_on,
                      ),
                    _DetailCard(
                      label: lang == 'es' ? 'Tipo' : 'Type',
                      value: conv.isPublic
                          ? (lang == 'es' ? 'Público' : 'Public')
                          : (lang == 'es' ? 'Privado' : 'Private'),
                      icon: Icons.public,
                    ),
                  ],
                ),

                // Requirements
                if (conv.requirements(lang) != null) ...[
                  const SizedBox(height: 32),
                  Text(
                    lang == 'es' ? 'Requisitos' : 'Requirements',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    conv.requirements(lang)!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],

                // Source
                if (conv.sourceUrl != null) ...[
                  const SizedBox(height: 32),
                  Text(
                    lang == 'es' ? 'Fuente' : 'Source',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse(conv.sourceUrl!)),
                    child: Text(
                      conv.sourceName ?? conv.sourceUrl!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Action buttons
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        lang == 'es'
                            ? 'Ver convocatoria'
                            : 'View call',
                      ),
                      onPressed: conv.sourceUrl != null
                          ? () => launchUrl(Uri.parse(conv.sourceUrl!))
                          : null,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.share),
                      label: Text(
                        lang == 'es'
                            ? 'Compartir por WhatsApp'
                            : 'Share via WhatsApp',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                      ),
                      onPressed: () =>
                          WhatsappService.shareConvocatoria(conv, lang),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? slug) {
    switch (slug) {
      case 'educacion':
        return const Color(0xFF6366f1);
      case 'salud':
        return const Color(0xFFEc4899);
      case 'medioambiente':
        return const Color(0xFF10b981);
      case 'cultura':
        return const Color(0xFFF59e0b);
      case 'social':
        return const Color(0xFF06b6d4);
      default:
        return const Color(0xFF4f46e5);
    }
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

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
