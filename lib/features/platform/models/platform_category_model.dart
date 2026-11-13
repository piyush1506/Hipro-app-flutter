class PlatformCategory {
  final String slug;
  final String name;
  final String subtitle;
  final String moduleType;
  final String tagline;
  final String themeColor;
  final String iconUrl;
  final String badge;
  final String feedEndpoint;
  final String searchEndpoint;

  const PlatformCategory({
    required this.slug,
    required this.name,
    required this.subtitle,
    required this.moduleType,
    this.tagline = '',
    this.themeColor = '#1864E8',
    this.iconUrl = '',
    this.badge = '',
    this.feedEndpoint = '',
    this.searchEndpoint = '',
  });

  factory PlatformCategory.fromJson(Map<String, dynamic> json) {
    return PlatformCategory(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      moduleType: json['moduleType']?.toString() ?? 'service_booking',
      tagline: json['tagline']?.toString() ?? '',
      themeColor: json['themeColor']?.toString() ?? '#1864E8',
      iconUrl: json['iconUrl']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      feedEndpoint: json['feedEndpoint']?.toString() ?? '',
      searchEndpoint: json['searchEndpoint']?.toString() ?? '',
    );
  }
}

