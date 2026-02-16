import 'package:flutter/material.dart';
import '../services/shopify_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ShopifyProvider with ChangeNotifier {
  final ShopifyService _shopifyService = ShopifyService();

  List<ProductModel> _products = [];
  List<ProductModel> _searchResults = [];
  List<CategoryModel> _collections = [];
  ProductModel? _selectedProduct;
  Map<String, dynamic>? _checkout;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get searchResults => _searchResults;
  List<CategoryModel> get collections => _collections;
  ProductModel? get selectedProduct => _selectedProduct;
  Map<String, dynamic>? get checkout => _checkout;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get checkoutUrl => _checkout?['webUrl'];

  /// Fetch all products
  Future<void> fetchProducts({int first = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _shopifyService.fetchProducts(first: first);
    } catch (e) {
      _error = 'Failed to fetch products: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch products by collection
  Future<void> fetchProductsByCollection(String handle, {int first = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _shopifyService.fetchProductsByCollection(handle, first: first);
    } catch (e) {
      _error = 'Failed to fetch collection: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch single product
  Future<void> fetchProduct(String handle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await _shopifyService.fetchProductByHandle(handle);
    } catch (e) {
      _error = 'Failed to fetch product: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch all collections
  Future<void> fetchCollections({int first = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collections = await _shopifyService.fetchCollections(first: first);
    } catch (e) {
      _error = 'Failed to fetch collections: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _shopifyService.searchProducts(query);
    } catch (e) {
      _error = 'Search failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create checkout with line items
  Future<bool> createCheckout(List<Map<String, dynamic>> items) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _checkout = await _shopifyService.createCheckout(items);
      if (_checkout == null) {
        _error = 'Failed to create checkout';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Checkout error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Add items to existing checkout
  Future<bool> addToCheckout(List<Map<String, dynamic>> items) async {
    if (_checkout == null) {
      return createCheckout(items);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final checkoutId = _checkout!['id'];
      _checkout = await _shopifyService.addToCheckout(checkoutId, items);
    } catch (e) {
      _error = 'Failed to add items: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update checkout line items
  Future<bool> updateCheckoutItems(List<Map<String, dynamic>> items) async {
    if (_checkout == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final checkoutId = _checkout!['id'];
      _checkout = await _shopifyService.updateCheckoutLineItems(checkoutId, items);
    } catch (e) {
      _error = 'Failed to update items: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Remove items from checkout
  Future<bool> removeFromCheckout(List<String> lineItemIds) async {
    if (_checkout == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final checkoutId = _checkout!['id'];
      _checkout = await _shopifyService.removeFromCheckout(checkoutId, lineItemIds);
    } catch (e) {
      _error = 'Failed to remove items: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Clear checkout
  void clearCheckout() {
    _checkout = null;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
