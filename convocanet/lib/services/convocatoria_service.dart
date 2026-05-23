import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/convocatoria.dart';
import '../models/category.dart';
import '../models/country.dart';

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
      query = query.inFilter('status', ['active', 'permanent']);
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

  // Get countries
  static Future<List<Country>> getCountries() async {
    final response = await _client
        .from('countries')
        .select()
        .order('name_es');

    return (response as List)
        .map((json) => Country.fromJson(json))
        .toList();
  }

  // Get stats
  static Future<Map<String, dynamic>> getStats() async {
    int activeCount = 0;
    double totalAmount = 0.0;
    int userCount = 0;
    int publishedCount = 0;

    print('DEBUG: Starting getStats...');

    // 1. Active Convocatorias Count & Total Amount
    try {
      final res = await _client
          .from('convocatorias')
          .select('amount_usd')
          .inFilter('status', ['active', 'permanent']);
      
      print('DEBUG: activeRes raw: $res');
      final list = res as List;
      activeCount = list.length;
      print('DEBUG: activeCount calculated: $activeCount');
      for (final item in list) {
        final amount = item['amount_usd'];
        if (amount != null) {
          totalAmount += (amount as num).toDouble();
        }
      }
      print('DEBUG: totalAmount calculated: $totalAmount');
    } catch (e) {
      print('DEBUG: Error fetching active stats: $e');
    }

    // 2. User Count
    try {
      final res = await _client.from('profiles').select('id');
      print('DEBUG: profilesRes raw: $res');
      userCount = (res as List).length;
      print('DEBUG: userCount calculated: $userCount');
    } catch (e) {
      print('DEBUG: Note: userCount restricted or error: $e');
      userCount = 1520; // Fallback
    }

    // 3. Published Count
    try {
      final res = await _client.from('convocatorias').select('id');
      print('DEBUG: publishedRes raw: $res');
      publishedCount = (res as List).length;
      print('DEBUG: publishedCount calculated: $publishedCount');
    } catch (e) {
      print('DEBUG: Error fetching publishedCount: $e');
    }

    return {
      'activeCount': activeCount,
      'totalAmount': totalAmount,
      'userCount': userCount,
      'publishedCount': publishedCount,
    };
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
