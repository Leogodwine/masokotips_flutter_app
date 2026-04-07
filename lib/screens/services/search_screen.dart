import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/product_provider.dart';
import '../../utils/logger.dart';
import '../products/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  static const String _recentKey = 'recent_searches';
  static const int _maxRecent = 6;

  List<String> _recent = [];
  String _query = '';
  Timer? _debounce;

  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto focus for fast UX
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _recent = prefs.getStringList(_recentKey) ?? []);
  }

  Future<void> _saveRecent(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;

    setState(() {
      _recent.remove(query);
      _recent.insert(0, query);
      if (_recent.length > _maxRecent) _recent = _recent.sublist(0, _maxRecent);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recent);
  }

  Future<void> _clearRecent() async {
    setState(() => _recent = []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  void _onChanged(String value) {
    final q = value.trim();

    setState(() {
      _query = q;
      _error = null;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(q);
    });
  }

  Future<void> _runSearch(String q) async {
    final query = q.trim();
    if (!mounted) return;

    // Clear results when empty
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _error = null;
      });

      // Optional: clear service_provider results if you store them
      // context.read<ProductProvider>().clearSearchResults();
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final provider = context.read<ProductProvider>();

      // ✅ CHANGE THIS LINE ONLY if your service_provider uses a different method name:
      // e.g. service_provider.search(query) or service_provider.searchProducts(query)
      await provider.searchProducts(query);

      await _saveRecent(query);

      if (!mounted) return;
      setState(() => _isSearching = false);
    } catch (e) {
      Log.e('Search error: $e');
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _error = 'Failed to search. Please try again.';
      });
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          height: 44,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: (v) => _runSearch(v),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ),
      actions: [
        if (_recent.isNotEmpty)
          TextButton(
            onPressed: _clearRecent,
            child: const Text('Clear'),
          ),
      ],
    );
  }

  Widget _buildRecentChips() {
    if (_recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recent.map((r) {
              return ActionChip(
                label: Text(r),
                avatar: const Icon(Icons.history, size: 16),
                onPressed: () {
                  _controller.text = r;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: r.length),
                  );
                  _onChanged(r);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final productProvider = context.watch<ProductProvider>();

    // ✅ Adjust these getters to match your service_provider structure.
    // Common patterns:
    // - productProvider.searchResults
    // - productProvider.products (filtered)
    // - productProvider.searchedProducts
    final results = productProvider.searchResults;

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _runSearch(_query),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_query.isEmpty) {
      return ListView(
        children: [
          _buildRecentChips(),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Start typing to search products',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  size: 72,
                  color: Theme.of(context).primaryColor.withAlpha(140)),
              const SizedBox(height: 12),
              Text(
                'No products found for "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Try different keywords.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = results[index];

        return Card(
          elevation: 1.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            title: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'TZS ${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}
