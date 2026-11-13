class UniversalSearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String categorySlug;
  final String categoryName;
  final String moduleType;
  final String badge;
  final String imageUrl;
  final double? price;
  final String actionLabel;
  final Map<String, dynamic> payload;

  const UniversalSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categorySlug,
    required this.categoryName,
    required this.moduleType,
    this.badge = '',
    this.imageUrl = '',
    this.price,
    this.actionLabel = 'View',
    this.payload = const {},
  });

  factory UniversalSearchResult.fromJson(Map<String, dynamic> json) {
    return UniversalSearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      categorySlug: json['categorySlug']?.toString() ?? 'hipro',
      categoryName: json['categoryName']?.toString() ?? '',
      moduleType: json['moduleType']?.toString() ?? 'service_booking',
      badge: json['badge']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble(),
      actionLabel: json['actionLabel']?.toString() ?? 'View',
      payload: json['payload'] is Map ? Map<String, dynamic>.from(json['payload']) : {},
    );
  }
}

