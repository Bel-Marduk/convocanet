import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/convocatoria.dart';
import '../models/category.dart';

class ConvocatoriaService {
  static SupabaseClient get _client => SupabaseService.client;

  // Get all active convocatorias with optional filters
  static Future<List<Convocatoria>> getConvocatorias({
    String? categorySlug,
    String? status,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from('convocatorias').select('''
      *,
      categories:category_id (
        name_es, name_en, slug, icon, color
      )
    ''');

    if (status != null) {
      query = query.eq('status', status);
    } else {
      // By default, show active and permanent
      query = query.in_('status', ['active', 'permanent']);
    }

    if (categorySlug != null && categorySlug != 'todas') {
      // First get category ID
      final catResponse = await _client
          .from('categories')
          .select('id')
          .eq('slug', categorySlug)
          .single();
      query = query.eq('category_id', catResponse['id']);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'title_es.ilike.%$searchQuery%,title_en.ilike.%$searchQuery%,description_es.ilike.%$searchQuery%,description_en.ilike.%$searchQuery%',
      );
    }

    final response = await query
        .order('deadline', ascending: true)
        .limit(limit ?? 50)
        .range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);

    return (response as List)
        .map((json) => Convocatoria.fromJson(json))
        .toList();
  }

  // Get single convocatoria by ID
  static Future<Convocatoria?> getConvocatoriaById(String id) async {
    final response = await _client
        .from('convocatorias')
        .select('''
          *,
          categories:category_id (
            name_es, name_en, slug, icon, color
          )
        ''')
        .eq('id', id)
        .single();

    return Convocatoria.fromJson(response);
  }

  // Get categories
  static Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name_es');

    return (response as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  // Get stats
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final activeRes = await _client
          .from('convocatorias')
          .select('id', const FetchOptions(count: CountOption.exact))
          .in_('status', ['active', 'permanent']);
      final activeCount = activeRes.count ?? 0;

      final totalAmountRes = await _client
          .from('convocatorias')
          .select('amount_usd')
          .in_('status', ['active', 'permanent']);
      
      double sum = 0;
      if (totalAmountRes is List) {
        for (final item in totalAmountRes) {
          final amount = item['amount_usd'];
          if (amount != null) {
            sum += (amount as num).toDouble();
          }
        }
      }

      final profilesRes = await _client
          .from('profiles')
          .select('id', const FetchOptions(count: CountOption.exact));
      final userCount = profilesRes.count ?? 0;

      final publishedRes = await _client
          .from('convocatorias')
          .select('id', const FetchOptions(count: CountOption.exact));
      final publishedCount = publishedRes.count ?? 0;

      return {
        'activeCount': activeCount,
        'totalAmount': sum,
        'userCount': userCount,
        'publishedCount': publishedCount,
      };
    } catch (e) {
      return {
        'activeCount': 0,
        'totalAmount': 0.0,
        'userCount': 0,
        'publishedCount': 0,
      };
    }
  }

  // Admin: Create convocatoria
  static Future<void> createConvocatoria(Convocatoria convocatoria) async {
    await _client.from('convocatorias').insert(convocatoria.toJson());
  }

  // Admin: Update convocatoria
  static Future<void> updateConvocatoria(Convocatoria convocatoria) async {
    await _client
        .from('convocatorias')
        .update(convocatoria.toJson())
        .eq('id', convocatoria.id);
  }

  // Admin: Delete convocatoria
  static Future<void> deleteConvocatoria(String id) async {
    await _client.from('convocatorias').delete().eq('id', id);
  }

  // User: Toggle favorite
  static Future<bool> toggleFavorite(String userId, String convocatoriaId) async {
    final existing = await _client
        .from('user_favorites')
        .select()
        .eq('user_id', userId)
        .eq('convocatoria_id', convocatoriaId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('convocatoria_id', convocatoriaId);
      return false;
    } else {
      await _client.from('user_favorites').insert({
        'user_id': userId,
        'convocatoria_id': convocatoriaId,
      });
      return true;
    }
  }

  // User: Get favorites
  static Future<List<Convocatoria>> getFavorites(String userId) async {
    final response = await _client
        .from('user_favorites')
        .select('''
          convocatoria_id,
          convocatorias:convocatoria_id (
            *,
            categories:category_id (
              name_es, name_en, slug, icon, color
            )
          )
        ''')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => Convocatoria.fromJson(json['convocatorias']))
        .toList();
  }

  // User: Check if favorite
  static Future<bool> isFavorite(String userId, String convocatoriaId) async {
    final response = await _client
        .from('user_favorites')
        .select()
        .eq('user_id', userId)
        .eq('convocatoria_id', convocatoriaId)
        .maybeSingle();

    return response != null;
  }

  // Contact form submission
  static Future<void> submitContactMessage({
    required String name,
    required String email,
    String? organization,
    required String message,
  }) async {
    await _client.from('contact_messages').insert({
      'name': name,
      'email': email,
      'organization': organization,
      'message': message,
    });
  }
}
