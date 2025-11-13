enum ReviewStatus { pending, approved, rejected }

class Review {
  final String id;
  final String userId;
  final String userName;
  final String serviceId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final ReviewStatus status;
  final String? adminComment;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.status,
    this.adminComment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      serviceId: json['service_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: ReviewStatus.values.firstWhere(
        (e) => e.toString() == 'ReviewStatus.${json['status']}',
      ),
      adminComment: json['admin_comment'] as String?,
    );
  }
}
