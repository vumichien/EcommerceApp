import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../models/Product.dart';
import '../../../utils/app_localizations.dart';

class Description extends ConsumerWidget {
  const Description({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Description
        Padding(
          padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
          child: Text(
            product.description,
            style: const TextStyle(height: 1.5),
          ),
        ),

        // Ingredients Section
        Text(
          ref.tr('key_ingredients'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kTextLightColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: product.ingredients
                .map((ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                color: kTextColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
