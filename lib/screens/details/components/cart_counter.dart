import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../models/Product.dart';
import 'counter_with_fav_btn.dart';

class CartCounter extends ConsumerStatefulWidget {
  const CartCounter({super.key, required this.product});
  
  final Product product;

  @override
  ConsumerState<CartCounter> createState() => _CartCounterState();
}

class _CartCounterState extends ConsumerState<CartCounter> {
  @override
  Widget build(BuildContext context) {
    final selectedQuantity = ref.watch(selectedQuantityProvider(widget.product.id));
    
    // Use selected quantity for display
    final displayQuantity = selectedQuantity;
    
    return Row(
      children: <Widget>[
        SizedBox(
          width: 40,
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () {
              if (displayQuantity > 1) {
                final newQuantity = displayQuantity - 1;
                ref.read(selectedQuantityProvider(widget.product.id).notifier).state = newQuantity;
              }
            },
            child: const Icon(Icons.remove),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin / 2),
          child: Text(
            // if our item is less  then 10 then  it shows 01 02 like that
            displayQuantity.toString().padLeft(2, "0"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          width: 40,
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () {
              final newQuantity = displayQuantity + 1;
              ref.read(selectedQuantityProvider(widget.product.id).notifier).state = newQuantity;
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
