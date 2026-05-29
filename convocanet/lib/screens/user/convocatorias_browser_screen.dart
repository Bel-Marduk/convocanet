import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/convocatoria.dart';
import '../../models/category.dart';
import '../../models/country.dart';
import '../../services/convocatoria_service.dart';
import '../../widgets/convocatoria_card.dart';
import '../../widgets/user_bottom_nav.dart';
import '../../utils/category_colors.dart';

class ConvocatoriasBrowserScreen extends ConsumerStatefulWidget {
  const ConvocatoriasBrowserScreen({super.key});

  @override
  ConsumerState<ConvocatoriasBrowserScreen> createState() =>
      _ConvocatoriasBrowserScreenState();
}

class _ConvocatoriasBrowserScreenState
    extends ConsumerState<ConvocatoriasBrowserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Convocatoria> _convocatorias = [];
  List<Category> _categories = [];
  List<Country> _countries = [];
  Set<String> _favoriteIds = {};
  Set<String> _viewedIds = {};
  bool _isLoading = true;
  String? _selectedCategorySlug;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadConvocatorias();
    }
  }

  Future<void> _loadData() async {
    try {
      final categories = await ConvocatoriaService.getCategories();
      final countries = await ConvocatoriaService.getCountries();
      setState(() {
        _categories = categories;
        _countries = countries;
      });

      final user = ref.read(currentUserProvider);
      if (user != null) {
        final favs = await ConvocatoriaService.getFavoriteIds(user.id);
        final viewed = await ConvocatoriaService.getViewedIds(user.id);
        setState(() {
          _favoriteIds = favs;
          _viewedIds = viewed;
        });
      }
    } catch (e) {
      // Silently handle — convocatorias still load below
    }
    // Always load convocatorias, even if auxiliary data failed
    _loadConvocatorias();
  }

  Future<void> _loadConvocatorias() async {
    setState(() => _isLoading = true);
    try {
      List<Convocatoria> convocatorias;
      final user = ref.read(currentUserProvider);

      switch (_tabController.index) {
        case 0: // Nuevas
          convocatorias = await ConvocatoriaService.getConvocatorias(
            status: 'active',
            categorySlug: _selectedCategorySlug,
          );
          // Exclude viewed
          if (user != null) {
            convocatorias = convocatorias
                .where((c) => !_viewedIds.contains(c.id))
                .toList();
          }
          break;
        case 1: // Vistas
          if (user != null) {
            convocatorias = await ConvocatoriaService.getViewed(user.id);
          } else {
            convocatorias = [];
          }
          break;
        case 2: // Permanentes
          convocatorias = await ConvocatoriaService.getConvocatorias(
            status: 'permanent',
            categorySlug: _selectedCategorySlug,
          );
          break;
        case 3: // Cerradas
          convocatorias = await ConvocatoriaService.getConvocatorias(
            status: 'expired',
            categorySlug: _selectedCategorySlug,
          );
          break;
        default:
          convocatorias = [];
      }

      // Apply country filter
      if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
        convocatorias = convocatorias.where((c) {
          final regionEs = c.regionEs?.toLowerCase() ?? '';
          final regionEn = c.regionEn?.toLowerCase() ?? '';
          final countryLower = _selectedCountry!.toLowerCase();
          return regionEs.contains(countryLower) ||
              regionEn.contains(countryLower);
        }).toList();
      }

      setState(() {
        _convocatorias = convocatorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _convocatorias = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Convocatoria convocatoria) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Optimistic update — mark/unmark star immediately
    final wasFav = _favoriteIds.contains(convocatoria.id);
    setState(() {
      if (wasFav) {
        _favoriteIds.remove(convocatoria.id);
      } else {
        _favoriteIds.add(convocatoria.id);
      }
    });

    try {
      await ConvocatoriaService.toggleFavorite(user.id, convocatoria.id);
    } catch (e) {
      // Revert on failure
      setState(() {
        if (wasFav) {
          _favoriteIds.add(convocatoria.id);
        } else {
          _favoriteIds.remove(convocatoria.id);
        }
      });
    }
  }

  Future<void> _toggleViewed(Convocatoria convocatoria) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Optimistic update
    final wasViewed = _viewedIds.contains(convocatoria.id);
    setState(() {
      if (wasViewed) {
        _viewedIds.remove(convocatoria.id);
      } else {
        _viewedIds.add(convocatoria.id);
      }
    });

    try {
      if (wasViewed) {
        await ConvocatoriaService.removeFromViewed(user.id, convocatoria.id);
      } else {
        await ConvocatoriaService.markAsViewed(user.id, convocatoria.id);
      }
    } catch (e) {
      // Revert on failure
      setState(() {
        if (wasViewed) {
          _viewedIds.add(convocatoria.id);
        } else {
          _viewedIds.remove(convocatoria.id);
        }
      });
      return;
    }

    // Refresh current tab if it depends on viewed status
    if (_tabController.index == 0 || _tabController.index == 1) {
      _loadConvocatorias();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    // Auth guard
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
          tooltip: lang == 'es' ? 'Volver al Dashboard' : 'Back to Dashboard',
        ),
        title: Text(lang == 'es' ? 'Convocatorias' : 'Browse Calls'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: lang == 'es' ? 'Nuevas' : 'New'),
            Tab(text: lang == 'es' ? 'Vistas' : 'Viewed'),
            Tab(text: lang == 'es' ? 'Permanentes' : 'Permanent'),
            Tab(text: lang == 'es' ? 'Cerradas' : 'Closed'),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(currentIndex: 1),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(lang == 'es' ? 'Todas' : 'All'),
                      selected: _selectedCategorySlug == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategorySlug = null);
                          _loadConvocatorias();
                        }
                      },
                    ),
                    ..._categories.map((cat) {
                      final color = getCategoryColor(cat.slug);
                      final isSelected = _selectedCategorySlug == cat.slug;
                      return FilterChip(
                        label: Text(
                          cat.name(lang),
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: color,
                        onSelected: (selected) {
                          setState(() => _selectedCategorySlug =
                              selected ? cat.slug : null);
                          _loadConvocatorias();
                        },
                      );
                    }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Country dropdown
                Row(
                  children: [
                    Icon(Icons.public,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        isExpanded: true,
                        hint: Text(
                          lang == 'es'
                              ? 'Filtrar por país'
                              : 'Filter by country',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              lang == 'es' ? 'Todos los países' : 'All countries',
                            ),
                          ),
                          ..._countries.map((c) => DropdownMenuItem(
                                value: c.nameEs,
                                child: Text(lang == 'es' ? c.nameEs : c.nameEn),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCountry = value);
                          _loadConvocatorias();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Convocatorias grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _convocatorias.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _tabController.index == 1
                                  ? Icons.visibility_outlined
                                  : Icons.inbox_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getEmptyMessage(lang),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth > 900
                                  ? 3
                                  : constraints.maxWidth > 600
                                      ? 2
                                      : 1;
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 1.3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _convocatorias.length,
                            itemBuilder: (context, index) {
                              final conv = _convocatorias[index];
                              return ConvocatoriaCard(
                                convocatoria: conv,
                                isFavorite: _favoriteIds.contains(conv.id),
                                onFavoriteToggle: () =>
                                    _toggleFavorite(conv),
                                isViewed: _viewedIds.contains(conv.id),
                                onViewedToggle: () => _toggleViewed(conv),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage(String lang) {
    switch (_tabController.index) {
      case 0:
        return lang == 'es'
            ? 'No hay convocatorias nuevas'
            : 'No new calls';
      case 1:
        return lang == 'es'
            ? 'No has marcado ninguna como vista'
            : 'No viewed calls yet';
      case 2:
        return lang == 'es'
            ? 'No hay convocatorias permanentes'
            : 'No permanent calls';
      case 3:
        return lang == 'es'
            ? 'No hay convocatorias cerradas'
            : 'No closed calls';
      default:
        return '';
    }
  }
}
