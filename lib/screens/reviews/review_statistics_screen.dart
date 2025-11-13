import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';

class ReviewStatisticsScreen extends StatelessWidget {
  final String serviceId;

  const ReviewStatisticsScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Statistics'),
      ),
      body: Consumer<ReviewsProvider>(
        builder: (context, reviewsProvider, child) {
          final reviews = reviewsProvider
              .getUserReviews('all')
              .where((r) => r.productId.toString() == serviceId)
              .toList();
          final averageRating = reviews.isEmpty
              ? 0.0
              : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  reviews.length;

          if (reviews.isEmpty) {
            return const Center(
              child: Text('No reviews yet'),
            );
          }

          // Calculate rating distribution
          final ratingCounts = List.filled(5, 0);
          for (final review in reviews) {
            ratingCounts[review.rating.floor() - 1]++;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            const Text('Average Rating'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              reviews.length.toString(),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const Text('Total Reviews'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Rating Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...List.generate(5, (index) {
                  final starCount = 5 - index;
                  final count = ratingCounts[4 - index];
                  final percentage =
                      reviews.isEmpty ? 0 : (count / reviews.length * 100);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text('$starCount stars'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$count (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
