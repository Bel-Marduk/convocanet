import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/convocatoria.dart';
import '../providers/locale_provider.dart';
import '../services/whatsapp_service.dart';

class ConvocatoriaCard extends ConsumerWidget {
  final Convocatoria convocatoria;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const ConvocatoriaCard({
    super.key,
    required this.convocatoria,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.push('/convocatoria/${convocatoria.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and status
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  _CategoryChip(
                    label: convocatoria.categoryName(lang) ?? '',
                    icon: convocatoria.categoryIcon,
                    color: _getCategoryColor(convocatoria.categorySlug),
                  ),
                  const Spacer(),
                  _StatusBadge(status: convocatoria.status, lang: lang),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    convocatoria.title(lang),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    convocatoria.description(lang),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Meta info
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (convocatoria.deadline != null)
                        _MetaItem(
                          icon: Icons.calendar_today,
                          text:
                              '${convocatoria.deadline!.day}/${convocatoria.deadline!.month}/${convocatoria.deadline!.year}',
                        ),
                      if (convocatoria.countries(lang).isNotEmpty)
                        _MetaItem(
                          icon: Icons.public,
                          text: convocatoria.countries(lang).join(', '),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    convocatoria.formattedAmount,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (onFavoriteToggle != null)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : null,
                      ),
                      onPressed: onFavoriteToggle,
                      tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => WhatsappService.shareConvocatoria(
                      convocatoria,
                      lang,
                    ),
                    tooltip: 'Compartir por WhatsApp',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4f46e5), Color(0xFF3730a3)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: onTap ??
                          () => context
                              .push('/convocatoria/${convocatoria.id}'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        lang == 'es' ? 'Ver más' : 'View more',
                        style: const TextStyle(
                          fontSize: 13.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final Color color;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(_getIconData(icon), size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12.48,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      case 'eco':
        return Icons.eco;
      case 'palette':
        return Icons.palette;
      case 'people':
        return Icons.people;
      default:
        return Icons.category;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String lang;

  const _StatusBadge({required this.status, required this.lang});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => (lang == 'es' ? 'Activa' : 'Active', const Color(0xFF10b981)),
      'permanent' => (lang == 'es' ? 'Permanente' : 'Permanent', const Color(0xFFF59e0b)),
      'expired' => (lang == 'es' ? 'Vencida' : 'Expired', const Color(0xFFEf4444)),
      _ => (status, Colors.grey),
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.03,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
