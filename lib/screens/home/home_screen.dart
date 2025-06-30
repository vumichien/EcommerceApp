import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../utils/app_localizations.dart';

import '../../models/Product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../details/details_screen.dart';
import '../cart/cart_screen.dart';
import 'components/categorries.dart';
import 'components/item_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _cursorTimer;

  List<Product> get filteredProducts {
    List<Product> allProducts = ref.watch(productsProvider);
    List<Product> filtered = allProducts;

    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.category == selectedCategory)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              product.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              product.category
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              product.ingredients.any((ingredient) =>
                  ingredient.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();
    }

    return filtered;
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  void initState() {
    super.initState();
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            focusNode: _searchFocusNode,
            onChanged: (value) {
              _startCursorTimer();
              setState(() {
                searchQuery = value;
              });
            },
            onTap: () {
              _startCursorTimer();
            },
            onSubmitted: (value) {
              _cancelCursorTimer();
              _searchFocusNode.unfocus();
            },
            decoration: InputDecoration(
              hintText: ref.tr('search_products'),
              prefixIcon: const Icon(
                Icons.search,
                color: kTextLightColor,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              hintStyle: const TextStyle(
                color: kTextLightColor,
                fontSize: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: kTextColor,
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/cart.svg",
                  colorFilter:
                      const ColorFilter.mode(kTextColor, BlendMode.srcIn),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final itemCount = ref.watch(cartItemCountProvider);
                  if (itemCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: kDefaultPaddin / 2)
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: Text(
              "Health Supplements",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Categories(
            onCategorySelected: onCategorySelected,
            selectedCategory: selectedCategory,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: kDefaultPaddin,
                  crossAxisSpacing: kDefaultPaddin,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) => ItemCard(
                  product: filteredProducts[index],
                  heroTag: "product_${filteredProducts[index].id}",
                  press: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        product: filteredProducts[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  String get searchFieldLabel => 'Search supplements...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    final filteredProducts = products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()) ||
            product.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(query.toLowerCase())))
        .toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No supplements found',
          style: TextStyle(fontSize: 16, color: kTextLightColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(kDefaultPaddin),
      child: GridView.builder(
        itemCount: filteredProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: kDefaultPaddin,
          crossAxisSpacing: kDefaultPaddin,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) => ItemCard(
          product: filteredProducts[index],
          heroTag: "search_product_${filteredProducts[index].id}",
          press: () {
            close(context, filteredProducts[index]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  product: filteredProducts[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
