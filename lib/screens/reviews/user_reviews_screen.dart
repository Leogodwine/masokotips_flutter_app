import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class UserReviewsScreen extends StatelessWidget {
  const UserReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myReviews),
      ),
      body: Consumer<ReviewsProvider>(
        builder: (context, reviewsProvider, child) {
          final reviews = reviewsProvider
              .getUserReviews('user123'); // Replace with actual user ID

          if (reviews.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noReviewsYet),
            );
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 20,
                              color: index < review.rating
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(review.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              review.status.toString().split('.').last,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.comment,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      if (review.adminComment != null) ...[
                        const Divider(),
                        Text(
                          'Admin Response:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.adminComment!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Posted on ${_formatDate(review.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(ReviewStatus status) => switch (status) {
        ReviewStatus.pending => Colors.orange,
        ReviewStatus.approved => Colors.green,
        ReviewStatus.rejected => Colors.red,
      };

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
