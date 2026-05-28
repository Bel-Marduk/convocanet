import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/convocatoria_card.dart';
import '../../services/convocatoria_service.dart';
import '../../models/convocatoria.dart';
import '../../widgets/user_bottom_nav.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Convocatoria> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final favorites = await ConvocatoriaService.getFavorites(user.id);
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
          tooltip: lang == 'es' ? 'Volver' : 'Back',
        ),
        title: Text(lang == 'es' ? 'Mis Favoritos' : 'My Favorites'),
      ),
      bottomNavigationBar: UserBottomNav(currentIndex: 2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang == 'es'
                            ? 'No tienes convocatorias favoritas aún'
                            : "You don't have any favorite calls yet",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: _favorites
                            .map((c) => SizedBox(
                                  width: 370,
                                  height: 320,
                                  child: ConvocatoriaCard(
                                    convocatoria: c,
                                    isFavorite: true,
                                    onFavoriteToggle: () async {
                                      final user = ref.read(currentUserProvider);
                                      if (user != null) {
                                        await ConvocatoriaService.toggleFavorite(
                                          user.id,
                                          c.id,
                                        );
                                        _loadFavorites();
                                      }
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}
