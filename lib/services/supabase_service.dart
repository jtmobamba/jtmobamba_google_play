import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/category_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth methods
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Profile methods
  Future<UserModel?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _client.from('profiles').upsert(user.toJson());
  }

  // Product methods
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
    bool? featuredOnly,
    double? minPrice,
    double? maxPrice,
  }) async {
    var query = _client.from('products').select();

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    if (featuredOnly == true) {
      query = query.eq('is_featured', true);
    }

    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    final response = await query;

    List<ProductModel> products = (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();

    // Sort in Dart since Supabase sorting might be limited
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_low':
          products.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
          break;
        case 'price_high':
          products.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
          break;
        case 'rating':
          products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    return products;
  }

  Future<ProductModel?> getProductById(String productId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .single();

    return ProductModel.fromJson(response);
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await _client
        .from('products')
        .select()
        .eq('is_featured', true)
        .limit(10);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Category methods
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select();

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  // Cart methods
  Future<List<CartItemModel>> getCartItems(String userId) async {
    final response = await _client
        .from('cart_items')
        .select('*, product:products(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => CartItemModel.fromJson(json))
        .toList();
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    // Check if item already exists in cart
    final existing = await _client
        .from('cart_items')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Update quantity
      await _client
          .from('cart_items')
          .update({'quantity': existing['quantity'] + quantity})
          .eq('id', existing['id']);
    } else {
      // Insert new item
      await _client.from('cart_items').insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _client
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart(String userId) async {
    await _client.from('cart_items').delete().eq('user_id', userId);
  }

  // Orders
  Future<void> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double totalAmount,
    required String shippingAddress,
  }) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    await _client.from('orders').insert({
      'id': orderId,
      'user_id': userId,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Add order items
    for (var item in items) {
      await _client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.product?.finalPrice ?? 0,
      });
    }

    // Clear cart after order
    await clearCart(userId);
  }
}
