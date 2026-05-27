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
          .maybeSingle();
      if (catResponse == null) return [];
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
        .maybeSingle();

    if (response == null) return null;
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

  // Get landing stats via SECURITY DEFINER RPC (bypasses RLS for anonymous visitors)
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _client.rpc('get_landing_stats');
      final data = res as Map<String, dynamic>;
      return {
        'activeCount': (data['active_count'] as num?)?.toInt() ?? 0,
        'totalAmount': (data['total_amount_usd'] as num?)?.toDouble() ?? 0.0,
        'userCount': (data['user_count'] as num?)?.toInt() ?? 0,
        'orgCount': (data['org_count'] as num?)?.toInt() ?? 0,
        'publishedCount': (data['published_count'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      print('Error fetching landing stats: $e');
      return {};
    }
  }

  // Admin: Create convocatoria
  static Future<void> createConvocatoria(Convocatoria convocatoria) async {
    final data = convocatoria.toJson()
      ..remove('id')
      ..remove('created_by');
    await _client.from('convocatorias').insert(data).select();
  }

  // Admin: Update convocatoria
  static Future<void> updateConvocatoria(Convocatoria convocatoria) async {
    final data = convocatoria.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('created_by');
    await _client
        .from('convocatorias')
        .update(data)
        .eq('id', convocatoria.id)
        .select();
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

  // User: Get favorite IDs (for efficient filtering)
  static Future<Set<String>> getFavoriteIds(String userId) async {
    final response = await _client
        .from('user_favorites')
        .select('convocatoria_id')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => json['convocatoria_id'] as String)
        .toSet();
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

  // User: Mark convocatoria as viewed
  static Future<void> markAsViewed(String userId, String convocatoriaId) async {
    await _client.from('user_viewed_convocatorias').upsert({
      'user_id': userId,
      'convocatoria_id': convocatoriaId,
    });
  }

  // User: Remove from viewed
  static Future<void> removeFromViewed(String userId, String convocatoriaId) async {
    await _client
        .from('user_viewed_convocatorias')
        .delete()
        .eq('user_id', userId)
        .eq('convocatoria_id', convocatoriaId);
  }

  // User: Get viewed convocatorias
  static Future<List<Convocatoria>> getViewed(String userId) async {
    final response = await _client
        .from('user_viewed_convocatorias')
        .select('''
          convocatoria_id,
          viewed_at,
          convocatorias:convocatoria_id (
            *,
            categories:category_id (
              name_es, name_en, slug, icon, color
            )
          )
        ''')
        .eq('user_id', userId)
        .order('viewed_at', ascending: false);

    return (response as List)
        .where((json) => json['convocatorias'] != null)
        .map((json) => Convocatoria.fromJson(json['convocatorias']))
        .toList();
  }

  // User: Check if convocatoria has been viewed
  static Future<bool> isViewed(String userId, String convocatoriaId) async {
    final response = await _client
        .from('user_viewed_convocatorias')
        .select()
        .eq('user_id', userId)
        .eq('convocatoria_id', convocatoriaId)
        .maybeSingle();

    return response != null;
  }

  // User: Get all viewed convocatoria IDs (for efficient filtering)
  static Future<Set<String>> getViewedIds(String userId) async {
    final response = await _client
        .from('user_viewed_convocatorias')
        .select('convocatoria_id')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => json['convocatoria_id'] as String)
        .toSet();
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

  // Newsletter subscription
  static Future<bool> subscribeNewsletter(String email) async {
    // Check if email already exists
    final existing = await _client
        .from('contact_messages')
        .select('id')
        .eq('email', email)
        .eq('organization', 'newsletter')
        .maybeSingle();

    if (existing != null) {
      return false; // Already subscribed
    }

    await _client.from('contact_messages').insert({
      'name': 'Newsletter Subscriber',
      'email': email,
      'organization': 'newsletter',
      'message': 'Suscripción al newsletter desde landing page',
    });
    return true;
  }

  // ==========================================
  // ADMIN: User Management
  // ==========================================

  // Admin: Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers({
    String? searchQuery,
  }) async {
    List<dynamic> response;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      response = await _client.rpc('search_users', params: {
        'search_term': searchQuery,
      });
    } else {
      response = await _client.rpc('get_all_users');
    }
    return (response as List).cast<Map<String, dynamic>>();
  }

  // Admin: Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // Admin: Update user role
  static Future<void> updateUserRole(String userId, String role) async {
    await _client
        .from('profiles')
        .update({'role': role, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }

  // Admin: Delete user
  static Future<void> deleteUser(String userId) async {
    await _client.from('profiles').delete().eq('id', userId);
  }

  // ==========================================
  // ADMIN: Message Management
  // ==========================================

  // Admin: Get all contact messages
  static Future<List<Map<String, dynamic>>> getMessages({
    bool? onlyUnread,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from('contact_messages').select();

    if (onlyUnread == true) {
      query = query.eq('read', false);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit ?? 50)
        .range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);

    return (response as List).cast<Map<String, dynamic>>();
  }

  // Admin: Mark message as read/unread
  static Future<void> markMessageRead(String messageId, bool read) async {
    await _client
        .from('contact_messages')
        .update({'read': read})
        .eq('id', messageId);
  }

  // Admin: Delete message
  static Future<void> deleteMessage(String messageId) async {
    await _client.from('contact_messages').delete().eq('id', messageId);
  }

  // Admin: Get admin stats via RPC
  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await _client.rpc('get_admin_stats');
    return (response as Map<String, dynamic>);
  }

  // ==========================================
  // ADMIN: Category Management
  // ==========================================

  // Admin: Create category
  static Future<void> createCategory(Map<String, dynamic> data) async {
    await _client.from('categories').insert(data);
  }

  // Admin: Update category
  static Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _client.from('categories').update(data).eq('id', id);
  }

  // Admin: Delete category
  static Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }
}
