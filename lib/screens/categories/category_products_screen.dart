import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../products/product_list_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final Category category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductListScreen(
      title: category.name,
      categoryId: category.id,
      subcategory: category.name,
    );
  }
}
