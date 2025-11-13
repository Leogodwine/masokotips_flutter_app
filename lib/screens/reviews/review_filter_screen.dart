import 'package:flutter/material.dart';

enum ReviewSort {
  newest,
  oldest,
  highestRating,
  lowestRating,
}

class ReviewFilterScreen extends StatefulWidget {
  final Function(double, ReviewSort) onApplyFilters;
  final double currentMinRating;
  final ReviewSort currentSort;

  const ReviewFilterScreen({
    super.key,
    required this.onApplyFilters,
    this.currentMinRating = 0,
    this.currentSort = ReviewSort.newest,
  });

  @override
  State<ReviewFilterScreen> createState() => _ReviewFilterScreenState();
}

class _ReviewFilterScreenState extends State<ReviewFilterScreen> {
  late double _minRating;
  late ReviewSort _sortBy;

  @override
  void initState() {
    super.initState();
    _minRating = widget.currentMinRating;
    _sortBy = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum Rating',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _minRating.toString(),
              onChanged: (value) {
                setState(() {
                  _minRating = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...ReviewSort.values.map(
              (sort) => RadioListTile<ReviewSort>(
                title: Text(_getSortLabel(sort)),
                value: sort,
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_minRating, _sortBy);
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(ReviewSort sort) {
    switch (sort) {
      case ReviewSort.newest:
        return 'Newest First';
      case ReviewSort.oldest:
        return 'Oldest First';
      case ReviewSort.highestRating:
        return 'Highest Rating';
      case ReviewSort.lowestRating:
        return 'Lowest Rating';
    }
  }
}
