import 'package:flutter/foundation.dart';

enum ReviewStatus { pending, approved, rejected }

class Review {
  final int id;
  final int productId;
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
    required this.productId,
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
      productId: json['product_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      rating: json['rating'],
      comment: json['comment'],
      images: List<String>.from(json['images'] ?? []),
      isVerifiedPurchase: json['is_verified_purchase'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      status: json['is_approved'] == true
          ? ReviewStatus.approved
          : json['is_approved'] == false
              ? ReviewStatus.rejected
              : ReviewStatus.pending,
      adminComment: json['admin_comment'],
    );
  }
}

class ReviewsProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Review> _reviews = [];
  // ignore: prefer_final_fields
  List<Review> _allReviews = []; // For admin purposes
  bool _isLoading = false;
  String? _error;

  // Constructor
  ReviewsProvider();

  List<Review> get reviews => _reviews;
  List<Review> get allReviews => _allReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviews(int productId,
      {int page = 1, int perPage = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Real API call would go here
      // final reviews = await _apiService!.getProductReviews(productId, page: page, perPage: perPage);
      // _reviews = reviews;
      _error = null;
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
      // Real API call would go here
      // _allReviews = await _apiService!.getAllReviews();
      _error = null;
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
        return _allReviews
            .where((r) => r.status == ReviewStatus.pending)
            .toList();
      case 'approved':
        return _allReviews
            .where((r) => r.status == ReviewStatus.approved)
            .toList();
      case 'rejected':
        return _allReviews
            .where((r) => r.status == ReviewStatus.rejected)
            .toList();
      case 'all':
      default:
        return _allReviews;
    }
  }

  Future<void> updateReviewStatus(int reviewId, ReviewStatus status) async {
    try {
      // Real API call would go here
      // await _apiService!.updateReviewStatus(reviewId, status);
      await loadAllReviews();
    } catch (e) {
      throw Exception('Failed to update review status: $e');
    }
    notifyListeners();
  }

  Future<void> addReview(int productId, double rating, String comment) async {
    try {
      // Real API call would go here
      // await _apiService!.addProductReview(productId, rating, comment);
      await loadReviews(productId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
    notifyListeners();
  }
}
