import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

class CartProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shipping => subtotal > 100 ? 0 : 9.99;

  double get tax => subtotal * 0.08; // 8% tax

  double get total => subtotal + shipping + tax;

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart(String? userId) async {
    if (userId == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items = await _supabaseService.getCartItems(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Keep local cart items if API fails
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1, String? userId}) async {
    // Check if product already in cart
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Update quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        userId: userId ?? 'local',
        quantity: quantity,
        product: product,
        createdAt: DateTime.now(),
      ));
    }

    notifyListeners();

    // Sync with Supabase if logged in
    if (userId != null) {
      try {
        await _supabaseService.addToCart(
          userId: userId,
          productId: product.id,
          quantity: quantity,
        );
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity, {String? userId}) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    if (quantity <= 0) {
      await removeFromCart(cartItemId, userId: userId);
      return;
    }

    _items[index] = _items[index].copyWith(quantity: quantity);
    notifyListeners();

    if (userId != null) {
      try {
        await _supabaseService.updateCartItemQuantity(
          cartItemId: cartItemId,
          quantity: quantity,
        );
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  Future<void> removeFromCart(String cartItemId, {String? userId}) async {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();

    if (userId != null) {
      try {
        await _supabaseService.removeFromCart(cartItemId);
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  Future<void> clearCart({String? userId}) async {
    _items = [];
    notifyListeners();

    if (userId != null) {
      try {
        await _supabaseService.clearCart(userId);
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        id: '',
        productId: '',
        userId: '',
        quantity: 0,
        createdAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }
}
