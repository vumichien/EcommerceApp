import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../models/Product.dart';
import '../../providers/product_provider.dart';
import '../details/details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  Timer? _cursorTimer;

  final List<String> _categories = [
    'All',
    'Anti-Aging',
    'Sports Nutrition',
    'Detox & Cleanse',
    'Skin Health',
    'Brain Health',
    'General Health',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allProducts = ref.read(productsProvider);
      setState(() {
        _filteredProducts = allProducts;
      });
    });
    _setupFocusListener();
  }

  void _setupFocusListener() {
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _startCursorTimer();
      } else {
        _cancelCursorTimer();
      }
    });
  }

  void _startCursorTimer() {
    _cancelCursorTimer();
    _cursorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _searchFocusNode.unfocus();
      }
    });
  }

  void _cancelCursorTimer() {
    _cursorTimer?.cancel();
    _cursorTimer = null;
  }

  @override
  void dispose() {
    _cancelCursorTimer();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    final allProducts = ref.read(productsProvider);
    setState(() {
      _filteredProducts = allProducts.where((product) {
        bool matchesSearch = product.title.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query) ||
            product.ingredients
                .any((ingredient) => ingredient.toLowerCase().contains(query));

        bool matchesCategory =
            _selectedCategory == 'All' || product.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
    _cancelCursorTimer();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search Products',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                _startCursorTimer();
                _filterProducts();
              },
              onTap: () {
                _startCursorTimer();
              },
              onSubmitted: (value) {
                _cancelCursorTimer();
                _searchFocusNode.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Search supplements, ingredients...',
                prefixIcon: const Icon(Icons.search, color: kTextLightColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: kTextLightColor),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts();
                          _cancelCursorTimer();
                          _searchFocusNode.unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: kBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kTextColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _filterProducts();
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: kPrimaryColor,
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: kTextLightColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: kTextLightColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: kTextLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: product.color.withValues(alpha: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.image.startsWith('http')
                      ? Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: product.color,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.medical_services,
                              color: product.color,
                              size: 40,
                            );
                          },
                        )
                      : Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.medical_services,
                              color: product.color,
                              size: 40,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: product.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: product.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextLightColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.priceString,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
