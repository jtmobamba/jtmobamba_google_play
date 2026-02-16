class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final String? description;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.description,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      description: json['description'],
      productCount: json['product_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'description': description,
      'product_count': productCount,
    };
  }
}
