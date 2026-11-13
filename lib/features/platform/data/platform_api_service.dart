import '../../../core/network/api_client.dart';
import '../models/ecommerce_product_model.dart';
import '../models/platform_category_model.dart';
import '../models/universal_search_result_model.dart';

class PlatformFeedResponse {
  final String source;
  final String moduleType;
  final Map<String, dynamic>? banner;
  final List<String> tags;
  final List<EcommerceProduct> products;
  final List<dynamic> services;

  const PlatformFeedResponse({
    required this.source,
    required this.moduleType,
    this.banner,
    this.tags = const [],
    this.products = const [],
    this.services = const [],
  });
}

class PlatformApiService {
  final ApiClient _client;

  PlatformApiService([ApiClient? client]) : _client = client ?? ApiClient();

  /// Fetches platform categories dynamically configured via Admin & Gateway
  Future<List<PlatformCategory>> fetchCategories() async {
    try {
      final res = await _client.dio.get('/api/v1/platform/categories');
      if (res.data is Map && res.data['categories'] is List) {
        final list = res.data['categories'] as List;
        return list.map((c) => PlatformCategory.fromJson(Map<String, dynamic>.from(c))).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetches a dynamic category feed (proxied by the gateway from the appropriate microservice)
  Future<PlatformFeedResponse?> fetchCategoryFeed(String categorySlug) async {
    try {
      final res = await _client.dio.get('/api/v1/platform/categories/$categorySlug/feed');
      if (res.data is Map) {
        final data = res.data as Map;
        final source = data['source']?.toString() ?? 'Gateway';
        final moduleType = data['moduleType']?.toString() ?? 'ecommerce';

        final banner = data['banner'] is Map ? Map<String, dynamic>.from(data['banner']) : null;
        final tags = (data['tags'] as List?)?.map((t) => t.toString()).toList() ?? ['All'];

        List<EcommerceProduct> products = [];
        if (data['products'] is List) {
          products = (data['products'] as List)
              .map((p) => EcommerceProduct.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }

        List<dynamic> services = [];
        if (data['services'] is List) {
          services = data['services'] as List;
        }

        return PlatformFeedResponse(
          source: source,
          moduleType: moduleType,
          banner: banner,
          tags: tags,
          products: products,
          services: services,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Universal Federated Search across All Modules (Services, Fresh Produce, Fashion)
  Future<List<UniversalSearchResult>> searchAll(String query, {String? city}) async {
    if (query.trim().isEmpty) return [];
    try {
      final res = await _client.dio.get(
        '/api/v1/platform/search',
        queryParameters: {
          'q': query.trim(),
          if (city != null && city.isNotEmpty) 'city': city.trim(),
        },
      );
      if (res.data is Map && res.data['results'] is List) {
        final list = res.data['results'] as List;
        return list
            .map((item) => UniversalSearchResult.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}

