import 'package:flutter/material.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.filterReviews),
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
            SegmentedButton<ReviewSort>(
              segments: ReviewSort.values
                  .map(
                    (sort) => ButtonSegment<ReviewSort>(
                      value: sort,
                      label: Text(_getSortLabel(sort)),
                    ),
                  )
                  .toList(),
              selected: {_sortBy},
              onSelectionChanged: (Set<ReviewSort> selected) {
                setState(() {
                  _sortBy = selected.first;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_minRating, _sortBy);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.applyFilters),
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
