import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when the screen is initialized
    Future.microtask(() => Provider.of<CategoryProvider>(context, listen: false)
        .loadMainCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('maSOKOtips'),
        centerTitle: true,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    categoryProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.loadMainCategories();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (categoryProvider.mainCategories.isEmpty) {
            return const Center(
              child: Text('No categories found'),
            );
          }

          return CategoryGrid(categories: categoryProvider.mainCategories);
        },
      ),
    );
  }
}
