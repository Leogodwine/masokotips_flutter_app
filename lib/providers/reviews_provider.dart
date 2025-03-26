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
  List<Review> _reviews = [];
  List<Review> _allReviews = []; // For admin purposes
  bool _isLoading = false;
  String? _error;
  bool _useMockData = true;

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
      if (_useMockData) {
        // Use mock data
        await Future.delayed(const Duration(milliseconds: 800));
        _reviews = _getMockReviews(productId);
      } else {
        // Real API call would go here
        // final reviews = await _apiService!.getProductReviews(productId, page: page, perPage: perPage);
        // _reviews = reviews;
      }
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
      if (_useMockData) {
        // Use mock data
        await Future.delayed(const Duration(milliseconds: 800));
        _allReviews = _getAllMockReviews();
      } else {
        // Real API call would go here
        // _allReviews = await _apiService!.getAllReviews();
      }
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
      if (_useMockData) {
        // Mock implementation
        await Future.delayed(const Duration(milliseconds: 500));
        _allReviews = _allReviews.map((review) {
          if (review.id == reviewId) {
            return Review(
              id: review.id,
              productId: review.productId,
              userId: review.userId,
              userName: review.userName,
              rating: review.rating,
              comment: review.comment,
              images: review.images,
              isVerifiedPurchase: review.isVerifiedPurchase,
              createdAt: review.createdAt,
              status: status,
              adminComment: review.adminComment,
            );
          }
          return review;
        }).toList();
      } else {
        // Real API call would go here
        // await _apiService!.updateReviewStatus(reviewId, status);
        await loadAllReviews();
      }
    } catch (e) {
      throw Exception('Failed to update review status: $e');
    }
    notifyListeners();
  }

  Future<void> addReview(int productId, double rating, String comment) async {
    try {
      if (_useMockData) {
        // Mock implementation
        await Future.delayed(const Duration(milliseconds: 500));
        final newReview = Review(
          id: DateTime.now().millisecondsSinceEpoch,
          productId: productId,
          userId: 1,
          userName: 'Current User',
          rating: rating.toInt(),
          comment: comment,
          images: [],
          isVerifiedPurchase: true,
          createdAt: DateTime.now(),
          status: ReviewStatus.approved,
        );

        _reviews.add(newReview);
      } else {
        // Real API call would go here
        // await _apiService!.addProductReview(productId, rating, comment);
        await loadReviews(productId);
      }
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
    notifyListeners();
  }

  // Mock data methods
  List<Review> _getMockReviews(int productId) {
    return _getAllMockReviews().where((r) => r.productId == productId).toList();
  }

  List<Review> _getAllMockReviews() {
    return [
      Review(
        id: 1,
        productId: 1,
        userId: 1,
        userName: 'John Doe',
        rating: 5,
        comment: 'Great product! Very fresh and tasty.',
        images: [],
        isVerifiedPurchase: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: ReviewStatus.approved,
      ),
      Review(
        id: 2,
        productId: 1,
        userId: 2,
        userName: 'Jane Smith',
        rating: 4,
        comment: 'Good quality but a bit expensive.',
        images: [],
        isVerifiedPurchase: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        status: ReviewStatus.approved,
      ),
      Review(
        id: 3,
        productId: 2,
        userId: 3,
        userName: 'Bob Johnson',
        rating: 3,
        comment: 'Average product, nothing special.',
        images: [],
        isVerifiedPurchase: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        status: ReviewStatus.approved,
      ),
    ];
  }
}
