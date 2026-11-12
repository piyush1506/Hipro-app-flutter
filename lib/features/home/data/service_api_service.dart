import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../services/models/service_model.dart';
import '../../offers/models/offer_model.dart';
import '../models/city_model.dart';
import '../models/slide_model.dart';

class ServiceApiService {
  final ApiClient apiClient;

  ServiceApiService(this.apiClient);

  Future<List<ServiceItem>> fetchServices({String? city, String? section}) async {
    try {
      final response = await apiClient.dio.get(
        '/services',
        queryParameters: {
          if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
          if (section != null && section.trim().isNotEmpty) 'section': section.trim(),
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawlist =
            response.data['services'] ?? response.data['data'] ?? response.data;
        if (rawlist is List) {
          return rawlist
              .map((json) => ServiceItem.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch service $e');
    }
  }

  static List<CityItem>? _cachedCities;
  static List<SlideItem>? _cachedSlides;
  static List<OfferItem>? _cachedOffers;

  /// Returns true if there are 2 or more operational cities.
  /// If false, only a single city exists and city selection should be bypassed.
  static bool get hasMultipleCities {
    if (_cachedCities == null) return true; // Default to true until fetched
    final active = _cachedCities!.where((c) => c.isActive).toList();
    return active.length > 1;
  }

  /// Returns the single operational city if exactly one city exists, else null.
  static CityItem? get singleOperationalCity {
    if (_cachedCities == null) return null;
    final active = _cachedCities!.where((c) => c.isActive).toList();
    return active.length == 1 ? active.first : null;
  }

  /// Fetches supported operational cities dynamically from backend DB
  Future<List<CityItem>> fetchSupportedCities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCities != null && _cachedCities!.isNotEmpty) {
      return _cachedCities!;
    }
    try {
      final response = await apiClient.dio.get('/services/cities');
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data['cities'];
        if (raw is List) {
          final list = raw.map((e) => CityItem.fromJson(e as Map<String, dynamic>)).toList();
          _cachedCities = list;
          return list;
        }
      }
      return _cachedCities ?? [];
    } catch (e) {
      return _cachedCities ?? [];
    }
  }

  /// Fetches verified partner technicians for the given city dynamically from backend DB
  Future<List<PartnerItem>> fetchPartners({String? city}) async {
    try {
      final response = await apiClient.dio.get(
        '/services/partners',
        queryParameters: {
          if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data['partners'];
        if (raw is List) {
          return raw.map((e) => PartnerItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    try {
      final response = await apiClient.dio.get('/services');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawList =
            response.data['services'] ?? response.data['data'] ?? response.data;
        if (rawList is List) {
          return rawList
              .map((json) =>
                  ServiceCategory.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceItem?> fetchServiceById(String id) async {
    try {
      final response = await apiClient.dio.get('/services/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return ServiceItem.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }

  static List<SlideItem>? get cachedSlides => _cachedSlides;
  static List<OfferItem>? get cachedOffers => _cachedOffers;

  Future<List<SlideItem>> fetchSlides({String? section, bool forceRefresh = false}) async {
    if (!forceRefresh && section == null && _cachedSlides != null && _cachedSlides!.isNotEmpty) {
      return _cachedSlides!;
    }
    try {
      final response = await apiClient.dio.get(
        '/slides',
        queryParameters: section != null ? {'section': section} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawList =
            response.data['slides'] ?? response.data['data'] ?? response.data;
        if (rawList is List) {
          final list = rawList
              .map((json) => SlideItem.fromJson(json as Map<String, dynamic>))
              .toList();
          if (section == null) _cachedSlides = list;
          return list;
        }
      }
    } catch (_) {
      // If network fails or no slides configured, return empty list
    }

    return [];
  }

  Future<List<OfferItem>> fetchOffers({String? section, bool forceRefresh = false}) async {
    if (!forceRefresh && section == null && _cachedOffers != null && _cachedOffers!.isNotEmpty) {
      return _cachedOffers!;
    }
    try {
      final response = await apiClient.dio.get(
        '/offers',
        queryParameters: section != null ? {'section': section} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawList =
            response.data['offers'] ?? response.data['data'] ?? response.data;
        if (rawList is List) {
          final list = rawList
              .map((json) => OfferItem.fromJson(json as Map<String, dynamic>))
              .toList();
          if (section == null) _cachedOffers = list;
          return list;
        }
      }
    } catch (_) {
      // If network fails or no offers configured, return empty list
    }

    return [];
  }

  Future<AppliedCoupon?> validateCoupon({
    required String code,
    required double amount,
    String? section,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/offers/validate',
        data: {
          'code': code.trim().toUpperCase(),
          'amount': amount,
          if (section != null) ...{'section': section},
        },
      );
      if (response.data != null &&
          response.data['success'] == true &&
          response.data['coupon'] != null) {
        return AppliedCoupon.fromJson(
            response.data['coupon'] as Map<String, dynamic>);
      }
    } on DioException catch (dioErr) {
      final msg = dioErr.response?.data?['message']?.toString() ??
          'Invalid or expired coupon code';
      throw Exception(msg);
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }
}

