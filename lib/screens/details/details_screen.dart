import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';
import '../../models/Product.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/app_localizations.dart';
import 'components/add_to_cart.dart';
import 'components/color_and_size.dart';
import 'components/counter_with_fav_btn.dart';
import 'components/description.dart';

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;

    // Always reset quantity to 1 when entering details screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedQuantityProvider(product.id).notifier).state = 1;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: product.color,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const <Widget>[SizedBox(width: kDefaultPaddin / 2)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with product info and image
            Container(
              width: double.infinity,
              color: product.color,
              padding: const EdgeInsets.all(kDefaultPaddin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title and Favorite button row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width < 350 ? 18 : 22,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final favorites = ref.watch(favoritesProvider);
                          final isFavorite =
                              favorites.any((fav) => fav.id == product.id);

                          return IconButton(
                            onPressed: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(product);
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isFavorite
                                    ? kAccentColor
                                    : Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isFavorite ? kAccentColor : Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: isFavorite ? Colors.white : Colors.white,
                                size: 18,
                              ),
                            ),
                            iconSize: 44,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: kDefaultPaddin),

                  // Price and Image row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Price\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: product.priceString,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width < 350 ? 18 : 20,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: kDefaultPaddin / 2),
                      Expanded(
                        flex: 3,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: size.height * 0.15,
                            maxWidth: size.width * 0.35,
                          ),
                          child: Hero(
                            tag: "product_${product.id}",
                            child: product.image.startsWith('http')
                                ? Image.network(
                                    product.image,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.medical_services,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    product.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.medical_services,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kDefaultPaddin / 4),
                ],
              ),
            ),

            // Details section with white background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kDefaultPaddin),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ColorAndSize(product: product),
                  const SizedBox(height: kDefaultPaddin / 2),
                  Description(product: product),
                  const SizedBox(height: kDefaultPaddin / 2),
                  CounterWithFavBtn(product: product),
                  const SizedBox(height: kDefaultPaddin / 2),
                  Consumer(
                    builder: (context, ref, child) {
                      final selectedQuantity =
                          ref.watch(selectedQuantityProvider(product.id));
                      return AddToCart(
                          product: product, quantity: selectedQuantity);
                    },
                  ),
                  const SizedBox(height: kDefaultPaddin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
