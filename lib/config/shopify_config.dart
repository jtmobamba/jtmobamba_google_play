class ShopifyConfig {
  // Replace with your Shopify store credentials
  static const String storeDomain = 'your-store.myshopify.com';
  static const String storefrontAccessToken = 'YOUR_STOREFRONT_ACCESS_TOKEN';

  // API version
  static const String apiVersion = '2024-01';

  // GraphQL endpoint
  static String get graphQLEndpoint =>
      'https://$storeDomain/api/$apiVersion/graphql.json';
}
