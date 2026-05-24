import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/convocatoria_card.dart';
import '../../models/convocatoria.dart';
import '../../services/convocatoria_service.dart';

class ConvocatoriasSection extends ConsumerStatefulWidget {
  const ConvocatoriasSection({super.key});

  @override
  ConsumerState<ConvocatoriasSection> createState() =>
      _ConvocatoriasSectionState();
}

class _ConvocatoriasSectionState extends ConsumerState<ConvocatoriasSection> {
  String _selectedFilter = 'todas';
  List<Convocatoria> _convocatorias = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConvocatorias();
  }

  Future<void> _loadConvocatorias({String? categorySlug}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ConvocatoriaService.getConvocatorias(
        categorySlug: categorySlug,
      );
      data.shuffle(Random());
      final limited = data.take(6).toList();
      if (mounted) {
        setState(() {
          _convocatorias = limited;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading convocatorias';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filters = [
      ('todas', lang == 'es' ? 'Todas' : 'All'),
      ('educacion', lang == 'es' ? 'Educación' : 'Education'),
      ('salud', lang == 'es' ? 'Salud' : 'Health'),
      ('tecnologia', lang == 'es' ? 'Tecnología' : 'Technology'),
      ('cultura', lang == 'es' ? 'Cultura' : 'Culture'),
      ('social', lang == 'es' ? 'Desarrollo Social' : 'Social Development'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                      theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  lang == 'es' ? 'CONVOCATORIAS ABIERTAS' : 'OPEN CALLS',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es'
                    ? 'Oportunidades Disponibles'
                    : 'Available Opportunities',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es'
                    ? 'Explora las convocatorias vigentes y accede directamente con quien las emite.'
                    : 'Explore current calls and access them directly from the issuing organization.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Filters
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: filters.map((f) {
                  final isSelected = _selectedFilter == f.$1;
                  return FilterChip(
                    label: Text(f.$2),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = f.$1);
                      _loadConvocatorias(
                        categorySlug: f.$1 == 'todas' ? null : f.$1,
                      );
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Convocatorias grid
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                )
              else if (_convocatorias.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text(
                    lang == 'es'
                        ? 'No hay convocatorias disponibles'
                        : 'No calls available',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: _convocatorias
                      .map((c) => SizedBox(
                            width: 370,
                            height: 320,
                            child: ConvocatoriaCard(convocatoria: c),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
