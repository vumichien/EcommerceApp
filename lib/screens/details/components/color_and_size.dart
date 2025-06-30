import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../models/Product.dart';
import '../../../utils/app_localizations.dart';

class ColorAndSize extends ConsumerWidget {
  const ColorAndSize({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category and Dosage Row
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ref.tr('category'),
                    style: const TextStyle(color: kTextLightColor),
                  ),
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ref.tr('dosage'),
                    style: const TextStyle(color: kTextLightColor),
                  ),
                  Text(
                    product.dosage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: kDefaultPaddin),
        // Servings Information
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ref.tr('servingSize'),
                    style: const TextStyle(
                      color: kTextLightColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    product.servingSize,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ref.tr('servingsPerContainer'),
                    style: const TextStyle(
                      color: kTextLightColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "${product.servingsPerContainer}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: kDefaultPaddin),
        // Quality Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.isOrganic)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kSuccessColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ref.tr('organic'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (product.isGlutenFree)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ref.tr('glutenFree'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPrimaryColor),
              ),
              child: Text(
                product.manufacturer,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
