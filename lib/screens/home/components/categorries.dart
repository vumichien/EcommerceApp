import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../utils/app_localizations.dart';

// We need satefull widget for our categories

class Categories extends ConsumerStatefulWidget {
  const Categories({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  final Function(String) onCategorySelected;
  final String selectedCategory;

  @override
  ConsumerState<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<Categories> {
  final List<Map<String, String>> categoryData = [
    {"key": "All", "translationKey": "all"},
    {"key": "Anti-Aging", "translationKey": "anti_aging"},
    {"key": "Sports Nutrition", "translationKey": "sports_nutrition"},
    {"key": "Brain Health", "translationKey": "brain_health"},
    {"key": "Skin Health", "translationKey": "skin_health"},
    {"key": "General Health", "translationKey": "general_health"},
    {"key": "Detox & Cleanse", "translationKey": "detox_cleanse"}
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: SizedBox(
        height: 25,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categoryData.length,
          itemBuilder: (context, index) => buildCategory(index),
        ),
      ),
    );
  }

  Widget buildCategory(int index) {
    final categoryItem = categoryData[index];
    final isSelected = widget.selectedCategory == categoryItem["key"];
    return GestureDetector(
      onTap: () {
        widget.onCategorySelected(categoryItem["key"]!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              ref.tr(categoryItem["translationKey"]!),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? kTextColor : kTextLightColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: kDefaultPaddin / 8,
              ), //top padding 5
              height: 2,
              width: 30,
              color: isSelected ? kPrimaryColor : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }
}
