import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/convocatoria_card.dart';
import '../../models/convocatoria.dart';

class ConvocatoriasSection extends ConsumerStatefulWidget {
  const ConvocatoriasSection({super.key});

  @override
  ConsumerState<ConvocatoriasSection> createState() =>
      _ConvocatoriasSectionState();
}

class _ConvocatoriasSectionState extends ConsumerState<ConvocatoriasSection> {
  String _selectedFilter = 'todas';

  // Sample data - in production, this comes from Supabase
  final List<Convocatoria> _convocatorias = [
    Convocatoria(
      id: '1',
      titleEs: 'Fondo de Innovación Educativa 2026',
      titleEn: 'Educational Innovation Fund 2026',
      descriptionEs:
          'Programa de financiamiento para proyectos educativos que busquen mejorar la calidad de la educación en comunidades rurales y urbanas marginadas.',
      descriptionEn:
          'Funding program for educational projects seeking to improve education quality in rural and marginalized urban communities.',
      categoryNameEs: 'Educación',
      categoryNameEn: 'Education',
      categorySlug: 'educacion',
      categoryIcon: 'school',
      amountUsd: 50000,
      deadline: DateTime(2026, 7, 15),
      regionEs: 'Nacional',
      regionEn: 'National',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Convocatoria(
      id: '2',
      titleEs: 'Programa de Salud Comunitaria Integral',
      titleEn: 'Comprehensive Community Health Program',
      descriptionEs:
          'Convocatoria dirigida a asociaciones que implementen programas de prevención, atención primaria y promoción de la salud.',
      descriptionEn:
          'Call for associations implementing prevention, primary care, and health promotion programs.',
      categoryNameEs: 'Salud',
      categoryNameEn: 'Health',
      categorySlug: 'salud',
      categoryIcon: 'health',
      amountUsd: 70600,
      deadline: DateTime(2026, 8, 1),
      regionEs: 'Centro y Sur',
      regionEn: 'Central & Southern',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Convocatoria(
      id: '3',
      titleEs: 'Beca Verde: Restauración Ecológica',
      titleEn: 'Green Grant: Ecological Restoration',
      descriptionEs:
          'Financiamiento para proyectos de reforestación, restauración de ecosistemas y conservación de biodiversidad.',
      descriptionEn:
          'Funding for reforestation, ecosystem restoration, and biodiversity conservation projects.',
      categoryNameEs: 'Medio Ambiente',
      categoryNameEn: 'Environment',
      categorySlug: 'medioambiente',
      categoryIcon: 'eco',
      amountUsd: 38200,
      deadline: DateTime(2026, 6, 30),
      regionEs: 'Sureste',
      regionEn: 'Southeast',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Convocatoria(
      id: '4',
      titleEs: 'Impulso Cultural: Arte y Comunidad',
      titleEn: 'Cultural Boost: Art & Community',
      descriptionEs:
          'Apoyo económico para proyectos artísticos y culturales que promuevan la identidad local y la inclusión social.',
      descriptionEn:
          'Financial support for artistic and cultural projects that promote local identity and social inclusion.',
      categoryNameEs: 'Cultura',
      categoryNameEn: 'Culture',
      categorySlug: 'cultura',
      categoryIcon: 'palette',
      amountUsd: 26500,
      deadline: DateTime(2026, 9, 15),
      regionEs: 'Nacional',
      regionEn: 'National',
      status: 'permanent',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Convocatoria(
      id: '5',
      titleEs: 'Fondo de Desarrollo Social Local',
      titleEn: 'Local Social Development Fund',
      descriptionEs:
          'Programa de fortalecimiento comunitario que financia proyectos de infraestructura social y generación de empleo.',
      descriptionEn:
          'Community strengthening program financing social infrastructure projects and job creation.',
      categoryNameEs: 'Desarrollo Social',
      categoryNameEn: 'Social Development',
      categorySlug: 'social',
      categoryIcon: 'people',
      amountUsd: 57600,
      deadline: DateTime(2026, 7, 31),
      regionEs: 'Norte y Centro',
      regionEn: 'Northern & Central',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Convocatoria(
      id: '6',
      titleEs: 'Programa Mujeres Líderes 2026',
      titleEn: 'Women Leaders Program 2026',
      descriptionEs:
          'Convocatoria especial para asociaciones lideradas por mujeres que promuevan la equidad de género.',
      descriptionEn:
          'Special call for women-led associations promoting gender equity.',
      categoryNameEs: 'Desarrollo Social',
      categoryNameEn: 'Social Development',
      categorySlug: 'social',
      categoryIcon: 'people',
      amountUsd: 32950,
      deadline: DateTime(2026, 6, 15),
      regionEs: 'Nacional',
      regionEn: 'National',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    final filters = [
      ('todas', lang == 'es' ? 'Todas' : 'All'),
      ('educacion', lang == 'es' ? 'Educación' : 'Education'),
      ('salud', lang == 'es' ? 'Salud' : 'Health'),
      ('medioambiente', lang == 'es' ? 'Medio Ambiente' : 'Environment'),
      ('cultura', lang == 'es' ? 'Cultura' : 'Culture'),
      ('social', lang == 'es' ? 'Desarrollo Social' : 'Social Development'),
    ];

    final filtered = _selectedFilter == 'todas'
        ? _convocatorias
        : _convocatorias
            .where((c) => c.categorySlug == _selectedFilter)
            .toList();

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
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.1),
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
                    ? 'Explora las convocatorias vigentes y encuentra el apoyo que tu asociación necesita.'
                    : 'Explore current calls and find the support your association needs.',
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
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: filtered
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
