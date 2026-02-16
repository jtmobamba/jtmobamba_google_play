import 'product_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String userId;
  final int quantity;
  final ProductModel? product;
  final DateTime createdAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    this.product,
    required this.createdAt,
  });

  double get totalPrice {
    if (product != null) {
      return product!.finalPrice * quantity;
    }
    return 0;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      userId: json['user_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? userId,
    int? quantity,
    ProductModel? product,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
