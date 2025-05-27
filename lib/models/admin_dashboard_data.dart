import 'package:json_annotation/json_annotation.dart';

part 'admin_dashboard_data.g.dart';

// Helper function to safely convert dynamic values to int
int _parseIntSafely(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }
  return 0;
}

@JsonSerializable()
class AdminDashboardData {
  final UserStats stats;
  @JsonKey(name: 'recent_activities')
  final RecentActivities recentActivities;
  @JsonKey(name: 'quick_links')
  final QuickLinks quickLinks;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  AdminDashboardData({
    required this.stats,
    required this.recentActivities,
    required this.quickLinks,
    required this.lastUpdated,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDashboardDataToJson(this);
}

@JsonSerializable()
class UserStats {
  final Users users;

  UserStats({required this.users});

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class Users {
  final int total;
  final int admins;
  final int sellers;
  final int buyers;
  @JsonKey(name: 'service_providers')
  final int serviceProviders;
  @JsonKey(name: 'new_users_today')
  final int newUsersToday;
  @JsonKey(name: 'active_users')
  final int activeUsers;
  @JsonKey(name: 'verified_users')
  final int verifiedUsers;

  Users({
    required this.total,
    required this.admins,
    required this.sellers,
    required this.buyers,
    required this.serviceProviders,
    required this.newUsersToday,
    required this.activeUsers,
    required this.verifiedUsers,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      total: _parseIntSafely(json['total']),
      admins: _parseIntSafely(json['admins']),
      sellers: _parseIntSafely(json['sellers']),
      buyers: _parseIntSafely(json['buyers']),
      serviceProviders: _parseIntSafely(json['service_providers']),
      newUsersToday: _parseIntSafely(json['new_users_today']),
      activeUsers: _parseIntSafely(json['active_users']),
      verifiedUsers: _parseIntSafely(json['verified_users']),
    );
  }

  Map<String, dynamic> toJson() => _$UsersToJson(this);
}

@JsonSerializable()
class RecentActivities {
  @JsonKey(name: 'latest_users')
  final List<LatestUser> latestUsers;

  RecentActivities({required this.latestUsers});

  factory RecentActivities.fromJson(Map<String, dynamic> json) =>
      _$RecentActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$RecentActivitiesToJson(this);
}

@JsonSerializable()
class LatestUser {
  final int id;
  final String name;
  final String email;
  final String role;
  @JsonKey(name: 'created_at')
  final String createdAt;

  LatestUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory LatestUser.fromJson(Map<String, dynamic> json) {
    return LatestUser(
      id: _parseIntSafely(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => _$LatestUserToJson(this);
}

@JsonSerializable()
class QuickLinks {
  final List<Link> users;
  final List<Link> reports;

  QuickLinks({
    required this.users,
    required this.reports,
  });

  factory QuickLinks.fromJson(Map<String, dynamic> json) =>
      _$QuickLinksFromJson(json);

  Map<String, dynamic> toJson() => _$QuickLinksToJson(this);
}

@JsonSerializable()
class Link {
  final String title;
  final String route;

  Link({
    required this.title,
    required this.route,
  });

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}
