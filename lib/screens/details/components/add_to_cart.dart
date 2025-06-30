import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../models/Product.dart';
import '../../../providers/cart_provider.dart';
import '../../../utils/app_localizations.dart';
import '../../cart/cart_screen.dart';

class AddToCart extends ConsumerWidget {
  const AddToCart({super.key, required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 700;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? kDefaultPaddin / 2 : kDefaultPaddin,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Always add the specified quantity to cart (accumulate)
            ref
                .read(cartProvider.notifier)
                .addToCart(product, quantity: quantity);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
              (route) =>
                  route.isFirst, // This keeps only the home screen in the stack
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, isSmallScreen ? 44 : 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
            ),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(
            ref.tr('add_to_cart').toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ),
    );
  }
}
