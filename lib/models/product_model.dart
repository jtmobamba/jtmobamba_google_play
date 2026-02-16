class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final List<String> images;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final int stock;
  final Map<String, dynamic>? specifications;
  final bool isFeatured;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    this.images = const [],
    required this.category,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.specifications,
    this.isFeatured = false,
    required this.createdAt,
  });

  double get finalPrice => discountPrice ?? price;

  double get discountPercentage {
    if (discountPrice != null && discountPrice! < price) {
      return ((price - discountPrice!) / price * 100);
    }
    return 0;
  }

  bool get isOnSale => discountPrice != null && discountPrice! < price;

  bool get isInStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      imageUrl: json['image_url'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      stock: json['stock'] ?? 0,
      specifications: json['specifications'],
      isFeatured: json['is_featured'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'image_url': imageUrl,
      'images': images,
      'category': category,
      'brand': brand,
      'rating': rating,
      'review_count': reviewCount,
      'stock': stock,
      'specifications': specifications,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
