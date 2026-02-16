import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductProvider with ChangeNotifier {
  // TODO: Integrate SupabaseService for real data when needed
  // final SupabaseService _supabaseService = SupabaseService();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<CategoryModel> _categories = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  String? _error;

  // Filter state
  String? _selectedCategory;
  String? _searchQuery;
  String _sortBy = 'newest';
  double? _minPrice;
  double? _maxPrice;

  // Getters
  List<ProductModel> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  // Sample data for demo
  List<ProductModel> get sampleProducts => [
    ProductModel(
      id: '1',
      name: 'iPhone 15 Pro Max',
      description: 'The most advanced iPhone ever with A17 Pro chip, titanium design, and 48MP camera system.',
      price: 1199.99,
      discountPrice: 1099.99,
      imageUrl: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400',
      category: 'Smartphones',
      brand: 'Apple',
      rating: 4.9,
      reviewCount: 2543,
      stock: 50,
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '2',
      name: 'MacBook Pro 16"',
      description: 'Supercharged by M3 Pro or M3 Max chip for exceptional performance.',
      price: 2499.99,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
      category: 'Laptops',
      brand: 'Apple',
      rating: 4.8,
      reviewCount: 1876,
      stock: 30,
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '3',
      name: 'Sony WH-1000XM5',
      description: 'Industry-leading noise cancellation with exceptional sound quality.',
      price: 399.99,
      discountPrice: 349.99,
      imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400',
      category: 'Audio',
      brand: 'Sony',
      rating: 4.7,
      reviewCount: 3421,
      stock: 100,
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '4',
      name: 'Samsung Galaxy S24 Ultra',
      description: 'Experience Galaxy AI with the most powerful Galaxy smartphone.',
      price: 1299.99,
      imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
      category: 'Smartphones',
      brand: 'Samsung',
      rating: 4.8,
      reviewCount: 1923,
      stock: 45,
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '5',
      name: 'iPad Pro 12.9"',
      description: 'The ultimate iPad experience with M2 chip and stunning Liquid Retina XDR display.',
      price: 1099.99,
      discountPrice: 999.99,
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
      category: 'Tablets',
      brand: 'Apple',
      rating: 4.9,
      reviewCount: 2156,
      stock: 35,
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '6',
      name: 'PlayStation 5',
      description: 'Experience lightning-fast loading with an ultra-high speed SSD.',
      price: 499.99,
      imageUrl: 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=400',
      category: 'Gaming',
      brand: 'Sony',
      rating: 4.9,
      reviewCount: 5432,
      stock: 20,
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '7',
      name: 'Apple Watch Ultra 2',
      description: 'The most rugged and capable Apple Watch for exploration and adventure.',
      price: 799.99,
      imageUrl: 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400',
      category: 'Wearables',
      brand: 'Apple',
      rating: 4.8,
      reviewCount: 876,
      stock: 60,
      isFeatured: false,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: '8',
      name: 'Dell XPS 15',
      description: 'Premium ultrabook with InfinityEdge display and powerful performance.',
      price: 1799.99,
      discountPrice: 1599.99,
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400',
      category: 'Laptops',
      brand: 'Dell',
      rating: 4.6,
      reviewCount: 1234,
      stock: 25,
      isFeatured: false,
      createdAt: DateTime.now(),
    ),
  ];

  List<CategoryModel> get sampleCategories => [
    CategoryModel(id: '1', name: 'Smartphones', iconUrl: 'smartphone', productCount: 45),
    CategoryModel(id: '2', name: 'Laptops', iconUrl: 'laptop', productCount: 32),
    CategoryModel(id: '3', name: 'Tablets', iconUrl: 'tablet', productCount: 18),
    CategoryModel(id: '4', name: 'Audio', iconUrl: 'headphones', productCount: 67),
    CategoryModel(id: '5', name: 'Wearables', iconUrl: 'watch', productCount: 24),
    CategoryModel(id: '6', name: 'Gaming', iconUrl: 'gamepad', productCount: 38),
    CategoryModel(id: '7', name: 'Accessories', iconUrl: 'cable', productCount: 156),
    CategoryModel(id: '8', name: 'Cameras', iconUrl: 'camera', productCount: 21),
  ];

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use sample data for demo, replace with Supabase call in production
      _products = sampleProducts;
      _featuredProducts = sampleProducts.where((p) => p.isFeatured).toList();
      _filteredProducts = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = sampleCategories;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectProduct(ProductModel product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = null;
    _sortBy = 'newest';
    _minPrice = null;
    _maxPrice = null;
    _filteredProducts = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((p) => p.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              p.brand.toLowerCase().contains(_searchQuery!.toLowerCase()))
          .toList();
    }

    // Apply price filter
    if (_minPrice != null) {
      _filteredProducts = _filteredProducts
          .where((p) => p.finalPrice >= _minPrice!)
          .toList();
    }

    if (_maxPrice != null) {
      _filteredProducts = _filteredProducts
          .where((p) => p.finalPrice <= _maxPrice!)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        _filteredProducts.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    notifyListeners();
  }
}
