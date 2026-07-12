import 'package:flutter/foundation.dart';
import 'package:masoko_tips/services/api_service.dart';

enum ReviewStatus { pending, approved, rejected }

class Review {
  final int id;
  final int reviewableId;
  final String reviewableType;
  final int userId;
  final String userName;
  final int rating;
  final String comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final DateTime createdAt;
  final ReviewStatus status;
  final String? adminComment;

  Review({
    required this.id,
    required this.reviewableId,
    required this.reviewableType,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.images,
    required this.isVerifiedPurchase,
    required this.createdAt,
    this.status = ReviewStatus.pending,
    this.adminComment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      reviewableId: json['reviewable_id'] ?? json['product_id'] ?? 0,
      reviewableType: json['reviewable_type'] ?? 'App\\Models\\Product',
      userId: json['user_id'],
      userName: json['user']['name'] ?? json['user_name'] ?? 'User',
      rating: json['rating'],
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isVerifiedPurchase: (json['is_verified_purchase'] == true || json['is_verified_purchase'] == 1),
      createdAt: DateTime.parse(json['created_at']),
      status: (json['is_approved'] == true || json['is_approved'] == 1)
          ? ReviewStatus.approved
          : (json['is_approved'] == false || json['is_approved'] == 0)
              ? ReviewStatus.rejected
              : ReviewStatus.pending,
      adminComment: json['admin_comment'],
    );
  }
}

class ReviewsProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Review> _reviews = [];
  List<Review> _allReviews = []; // For admin purposes
  bool _isLoading = false;
  String? _error;

  ReviewsProvider(this._apiService);

  List<Review> get reviews => _reviews;
  List<Review> get allReviews => _allReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviews(int reviewableId, String reviewableType, {int page = 1, int perPage = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final encodedType = Uri.encodeComponent(reviewableType);
      final response = await _apiService.get('reviews?reviewable_type=$encodedType&reviewable_id=$reviewableId&page=$page&per_page=$perPage');
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        _reviews = data.map((json) => Review.fromJson(json)).toList();
      } else {
        _error = 'Failed to load reviews';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllReviews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('reviews');
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        _allReviews = data.map((json) => Review.fromJson(json)).toList();
      } else {
        _error = 'Failed to load reviews';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Review> getUserReviews(String filter) {
    switch (filter.toLowerCase()) {
      case 'pending':
        return _allReviews.where((r) => r.status == ReviewStatus.pending).toList();
      case 'approved':
        return _allReviews.where((r) => r.status == ReviewStatus.approved).toList();
      case 'rejected':
        return _allReviews.where((r) => r.status == ReviewStatus.rejected).toList();
      case 'all':
      default:
        return _allReviews;
    }
  }

  Future<void> updateReviewStatus(int reviewId, ReviewStatus status) async {
    try {
      await _apiService.put('reviews/$reviewId', body: {
        'is_approved': status == ReviewStatus.approved ? true : (status == ReviewStatus.rejected ? false : null)
      });
      await loadAllReviews();
    } catch (e) {
      throw Exception('Failed to update review status: $e');
    }
  }

  Future<void> addReview(int reviewableId, String reviewableType, double rating, String comment) async {
    try {
      await _apiService.post('reviews', body: {
        'reviewable_id': reviewableId,
        'reviewable_type': reviewableType,
        'rating': rating.toInt(),
        'comment': comment,
      });
      await loadReviews(reviewableId, reviewableType);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }
}
