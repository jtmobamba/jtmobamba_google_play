import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/filter_bottom_sheet.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;
  final String title;

  const ProductListScreen({
    super.key,
    this.category,
    required this.title,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category != null) {
        Provider.of<ProductProvider>(context, listen: false)
            .setCategory(widget.category);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Clear filters when leaving the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).clearFilters();
      }
    });
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      Provider.of<ProductProvider>(context, listen: false)
                          .setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final hasFilters = productProvider.selectedCategory != null ||
                  productProvider.searchQuery != null ||
                  productProvider.sortBy != 'newest';

              if (!hasFilters) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    if (productProvider.selectedCategory != null)
                      _ActiveFilterChip(
                        label: productProvider.selectedCategory!,
                        onRemove: () => productProvider.setCategory(null),
                      ),
                    if (productProvider.sortBy != 'newest')
                      _ActiveFilterChip(
                        label: _getSortLabel(productProvider.sortBy),
                        onRemove: () => productProvider.setSortBy('newest'),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        productProvider.clearFilters();
                        _searchController.clear();
                      },
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.poppins(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Product Count
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '${productProvider.products.length} products found',
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Products Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final products = productProvider.products;

                if (productProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: GoogleFonts.poppins(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () {
                            productProvider.clearFilters();
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return 'Price: Low';
      case 'price_high':
        return 'Price: High';
      case 'rating':
        return 'Top Rated';
      default:
        return 'Newest';
    }
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
