import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../utils/app_localizations.dart';
import '../../providers/favorites_provider.dart';
import '../details/details_screen.dart';
import '../home/components/item_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(
          ref.tr('favorites'),
          style: TextStyle(
            color: kTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: kTextColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Consumer(
                      builder: (context, dialogRef, child) => AlertDialog(
                        title: Text(dialogRef.tr('clear_favorites')),
                        content:
                            Text(dialogRef.tr('clear_favorites_confirmation')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(dialogRef.tr('cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .clearFavorites();
                              Navigator.of(context).pop();
                            },
                            child: Text(dialogRef.tr('clear_all'),
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: kTextLightColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ref.tr('no_favorites_yet'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: kTextLightColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr('start_adding_favorites'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: kTextLightColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(kDefaultPaddin),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: kPrimaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${favorites.length} ${favorites.length == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                    child: GridView.builder(
                      itemCount: favorites.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: kDefaultPaddin,
                        crossAxisSpacing: kDefaultPaddin,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) => ItemCard(
                        product: favorites[index],
                        heroTag: "favorites_product_${favorites[index].id}",
                        press: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              product: favorites[index],
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
