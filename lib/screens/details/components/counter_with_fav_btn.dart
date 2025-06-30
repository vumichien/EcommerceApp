import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/Product.dart';
import 'cart_counter.dart';

// Create a family provider for per-product quantity selection
final selectedQuantityProvider = StateProvider.family<int, int>((ref, productId) => 1);

class CounterWithFavBtn extends ConsumerWidget {
  const CounterWithFavBtn({super.key, required this.product});
  
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CartCounter(product: product),
      ],
    );
  }
}
