import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final String hintText;
  final bool readOnly;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onTap,
    this.hintText = 'Search products...',
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onTap: onTap,
      readOnly: readOnly,
    );
  }
}
