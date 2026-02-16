import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/shopify_config.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ShopifyService {
  static final ShopifyService _instance = ShopifyService._internal();
  factory ShopifyService() => _instance;
  ShopifyService._internal();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Shopify-Storefront-Access-Token': ShopifyConfig.storefrontAccessToken,
  };

  /// Execute a GraphQL query
  Future<Map<String, dynamic>?> _executeQuery(String query, {Map<String, dynamic>? variables}) async {
    try {
      final response = await http.post(
        Uri.parse(ShopifyConfig.graphQLEndpoint),
        headers: _headers,
        body: jsonEncode({
          'query': query,
          ...?variables != null ? {'variables': variables} : null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errors'] != null) {
          debugPrint('GraphQL Errors: ${data['errors']}');
          return null;
        }
        return data['data'];
      } else {
        debugPrint('Shopify API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error executing Shopify query: $e');
      return null;
    }
  }

  /// Fetch all products
  Future<List<ProductModel>> fetchProducts({int first = 20, String? after}) async {
    const query = '''
      query GetProducts(\$first: Int!, \$after: String) {
        products(first: \$first, after: \$after) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            cursor
            node {
              id
              title
              description
              handle
              vendor
              productType
              tags
              featuredImage {
                url
                altText
              }
              images(first: 5) {
                edges {
                  node {
                    url
                    altText
                  }
                }
              }
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
                maxVariantPrice {
                  amount
                  currencyCode
                }
              }
              compareAtPriceRange {
                minVariantPrice {
                  amount
                }
              }
              variants(first: 10) {
                edges {
                  node {
                    id
                    title
                    availableForSale
                    quantityAvailable
                    price {
                      amount
                    }
                    compareAtPrice {
                      amount
                    }
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {'first': first, 'after': after},
    );

    if (data == null) return [];

    final products = <ProductModel>[];
    final edges = data['products']['edges'] as List;

    for (final edge in edges) {
      final node = edge['node'];
      products.add(_parseProduct(node));
    }

    return products;
  }

  /// Fetch products by collection/category
  Future<List<ProductModel>> fetchProductsByCollection(String collectionHandle, {int first = 20}) async {
    const query = '''
      query GetCollection(\$handle: String!, \$first: Int!) {
        collection(handle: \$handle) {
          id
          title
          products(first: \$first) {
            edges {
              node {
                id
                title
                description
                handle
                vendor
                productType
                featuredImage {
                  url
                }
                priceRange {
                  minVariantPrice {
                    amount
                  }
                }
                compareAtPriceRange {
                  minVariantPrice {
                    amount
                  }
                }
                variants(first: 1) {
                  edges {
                    node {
                      id
                      availableForSale
                      quantityAvailable
                    }
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {'handle': collectionHandle, 'first': first},
    );

    if (data == null || data['collection'] == null) return [];

    final products = <ProductModel>[];
    final edges = data['collection']['products']['edges'] as List;

    for (final edge in edges) {
      products.add(_parseProduct(edge['node']));
    }

    return products;
  }

  /// Fetch single product by handle
  Future<ProductModel?> fetchProductByHandle(String handle) async {
    const query = '''
      query GetProduct(\$handle: String!) {
        product(handle: \$handle) {
          id
          title
          description
          descriptionHtml
          handle
          vendor
          productType
          tags
          featuredImage {
            url
            altText
          }
          images(first: 10) {
            edges {
              node {
                url
                altText
              }
            }
          }
          priceRange {
            minVariantPrice {
              amount
              currencyCode
            }
          }
          compareAtPriceRange {
            minVariantPrice {
              amount
            }
          }
          variants(first: 20) {
            edges {
              node {
                id
                title
                availableForSale
                quantityAvailable
                price {
                  amount
                }
                compareAtPrice {
                  amount
                }
                selectedOptions {
                  name
                  value
                }
              }
            }
          }
          options {
            name
            values
          }
        }
      }
    ''';

    final data = await _executeQuery(query, variables: {'handle': handle});

    if (data == null || data['product'] == null) return null;

    return _parseProduct(data['product']);
  }

  /// Fetch all collections (categories)
  Future<List<CategoryModel>> fetchCollections({int first = 20}) async {
    const query = '''
      query GetCollections(\$first: Int!) {
        collections(first: \$first) {
          edges {
            node {
              id
              title
              handle
              description
              image {
                url
              }
              productsCount: products(first: 1) {
                edges {
                  cursor
                }
              }
            }
          }
        }
      }
    ''';

    final data = await _executeQuery(query, variables: {'first': first});

    if (data == null) return [];

    final categories = <CategoryModel>[];
    final edges = data['collections']['edges'] as List;

    for (final edge in edges) {
      final node = edge['node'];
      categories.add(CategoryModel(
        id: _extractId(node['id']),
        name: node['title'],
        iconUrl: _getCategoryIcon(node['handle']),
        productCount: 0, // Shopify doesn't provide direct count in Storefront API
      ));
    }

    return categories;
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query, {int first = 20}) async {
    const gqlQuery = '''
      query SearchProducts(\$query: String!, \$first: Int!) {
        products(first: \$first, query: \$query) {
          edges {
            node {
              id
              title
              description
              handle
              vendor
              productType
              featuredImage {
                url
              }
              priceRange {
                minVariantPrice {
                  amount
                }
              }
              compareAtPriceRange {
                minVariantPrice {
                  amount
                }
              }
              variants(first: 1) {
                edges {
                  node {
                    id
                    availableForSale
                    quantityAvailable
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final data = await _executeQuery(
      gqlQuery,
      variables: {'query': query, 'first': first},
    );

    if (data == null) return [];

    final products = <ProductModel>[];
    final edges = data['products']['edges'] as List;

    for (final edge in edges) {
      products.add(_parseProduct(edge['node']));
    }

    return products;
  }

  /// Create a checkout
  Future<Map<String, dynamic>?> createCheckout(List<Map<String, dynamic>> lineItems) async {
    const query = '''
      mutation CreateCheckout(\$input: CheckoutCreateInput!) {
        checkoutCreate(input: \$input) {
          checkout {
            id
            webUrl
            totalPrice {
              amount
              currencyCode
            }
            subtotalPrice {
              amount
            }
            totalTax {
              amount
            }
            lineItems(first: 50) {
              edges {
                node {
                  id
                  title
                  quantity
                  variant {
                    id
                    title
                    price {
                      amount
                    }
                    image {
                      url
                    }
                  }
                }
              }
            }
          }
          checkoutUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {
        'input': {
          'lineItems': lineItems.map((item) => {
            'variantId': item['variantId'],
            'quantity': item['quantity'],
          }).toList(),
        },
      },
    );

    if (data == null) return null;

    final errors = data['checkoutCreate']['checkoutUserErrors'] as List;
    if (errors.isNotEmpty) {
      debugPrint('Checkout errors: $errors');
      return null;
    }

    return data['checkoutCreate']['checkout'];
  }

  /// Add items to checkout
  Future<Map<String, dynamic>?> addToCheckout(
    String checkoutId,
    List<Map<String, dynamic>> lineItems,
  ) async {
    const query = '''
      mutation CheckoutLineItemsAdd(\$checkoutId: ID!, \$lineItems: [CheckoutLineItemInput!]!) {
        checkoutLineItemsAdd(checkoutId: \$checkoutId, lineItems: \$lineItems) {
          checkout {
            id
            webUrl
            totalPrice {
              amount
            }
            lineItems(first: 50) {
              edges {
                node {
                  id
                  title
                  quantity
                }
              }
            }
          }
          checkoutUserErrors {
            message
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {
        'checkoutId': checkoutId,
        'lineItems': lineItems,
      },
    );

    if (data == null) return null;
    return data['checkoutLineItemsAdd']['checkout'];
  }

  /// Update checkout line items
  Future<Map<String, dynamic>?> updateCheckoutLineItems(
    String checkoutId,
    List<Map<String, dynamic>> lineItems,
  ) async {
    const query = '''
      mutation CheckoutLineItemsUpdate(\$checkoutId: ID!, \$lineItems: [CheckoutLineItemUpdateInput!]!) {
        checkoutLineItemsUpdate(checkoutId: \$checkoutId, lineItems: \$lineItems) {
          checkout {
            id
            totalPrice {
              amount
            }
          }
          checkoutUserErrors {
            message
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {
        'checkoutId': checkoutId,
        'lineItems': lineItems,
      },
    );

    if (data == null) return null;
    return data['checkoutLineItemsUpdate']['checkout'];
  }

  /// Remove items from checkout
  Future<Map<String, dynamic>?> removeFromCheckout(
    String checkoutId,
    List<String> lineItemIds,
  ) async {
    const query = '''
      mutation CheckoutLineItemsRemove(\$checkoutId: ID!, \$lineItemIds: [ID!]!) {
        checkoutLineItemsRemove(checkoutId: \$checkoutId, lineItemIds: \$lineItemIds) {
          checkout {
            id
            totalPrice {
              amount
            }
          }
          checkoutUserErrors {
            message
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {
        'checkoutId': checkoutId,
        'lineItemIds': lineItemIds,
      },
    );

    if (data == null) return null;
    return data['checkoutLineItemsRemove']['checkout'];
  }

  /// Associate customer with checkout
  Future<Map<String, dynamic>?> associateCustomerWithCheckout(
    String checkoutId,
    String customerAccessToken,
  ) async {
    const query = '''
      mutation CheckoutCustomerAssociateV2(\$checkoutId: ID!, \$customerAccessToken: String!) {
        checkoutCustomerAssociateV2(checkoutId: \$checkoutId, customerAccessToken: \$customerAccessToken) {
          checkout {
            id
          }
          checkoutUserErrors {
            message
          }
        }
      }
    ''';

    final data = await _executeQuery(
      query,
      variables: {
        'checkoutId': checkoutId,
        'customerAccessToken': customerAccessToken,
      },
    );

    if (data == null) return null;
    return data['checkoutCustomerAssociateV2']['checkout'];
  }

  // Helper methods

  ProductModel _parseProduct(Map<String, dynamic> node) {
    final variants = node['variants']?['edges'] as List? ?? [];
    final firstVariant = variants.isNotEmpty ? variants[0]['node'] : null;

    final priceAmount = double.tryParse(
      node['priceRange']?['minVariantPrice']?['amount']?.toString() ?? '0',
    ) ?? 0;

    final compareAtPrice = double.tryParse(
      node['compareAtPriceRange']?['minVariantPrice']?['amount']?.toString() ?? '0',
    ) ?? 0;

    final stock = firstVariant?['quantityAvailable'] ?? 0;
    // Note: availableForSale can be used to check product availability
    // final isAvailable = firstVariant?['availableForSale'] ?? true;

    // Get all images
    final images = <String>[];
    if (node['featuredImage']?['url'] != null) {
      images.add(node['featuredImage']['url']);
    }
    final imageEdges = node['images']?['edges'] as List? ?? [];
    for (final edge in imageEdges) {
      final url = edge['node']?['url'];
      if (url != null && !images.contains(url)) {
        images.add(url);
      }
    }

    return ProductModel(
      id: _extractId(node['id']),
      name: node['title'] ?? '',
      description: node['description'] ?? '',
      price: compareAtPrice > 0 ? compareAtPrice : priceAmount,
      discountPrice: compareAtPrice > 0 ? priceAmount : null,
      imageUrl: images.isNotEmpty ? images[0] : '',
      category: node['productType'] ?? 'Uncategorized',
      brand: node['vendor'] ?? '',
      rating: 4.5, // Shopify Storefront API doesn't provide ratings
      reviewCount: 0,
      stock: stock,
      isFeatured: (node['tags'] as List?)?.contains('featured') ?? false,
      createdAt: DateTime.now(),
    );
  }

  String _extractId(String shopifyId) {
    // Extract numeric ID from Shopify GID format
    // e.g., "gid://shopify/Product/123456789" -> "123456789"
    final parts = shopifyId.split('/');
    return parts.isNotEmpty ? parts.last : shopifyId;
  }

  String _getCategoryIcon(String handle) {
    // Map collection handles to icon names
    final iconMap = {
      'smartphones': 'smartphone',
      'phones': 'smartphone',
      'laptops': 'laptop',
      'computers': 'laptop',
      'tablets': 'tablet',
      'headphones': 'headphones',
      'audio': 'headphones',
      'watches': 'watch',
      'smartwatches': 'watch',
      'gaming': 'gamepad',
      'accessories': 'cable',
      'cameras': 'camera',
    };

    return iconMap[handle.toLowerCase()] ?? 'devices';
  }
}
