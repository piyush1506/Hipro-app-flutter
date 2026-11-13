class EcommerceProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final double mrp;
  final String unit;
  final double rating;
  final int reviewsCount;
  final bool inStock;
  final String tag;
  final String imageUrl;
  final String description;

  const EcommerceProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.mrp = 0,
    required this.unit,
    this.rating = 4.8,
    this.reviewsCount = 100,
    this.inStock = true,
    this.tag = '',
    this.imageUrl = '',
    this.description = '',
  });

  double get discountPercent {
    if (mrp > price && mrp > 0) {
      return (((mrp - price) / mrp) * 100).roundToDouble();
    }
    return 0;
  }

  factory EcommerceProduct.fromJson(Map<String, dynamic> json) {
    return EcommerceProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '1 unit',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 120,
      inStock: json['inStock'] != false,
      tag: json['tag']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

