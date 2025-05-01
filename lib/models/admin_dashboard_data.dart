import 'package:json_annotation/json_annotation.dart';

// Single file with all classes
part 'admin_dashboard_data.g.dart';

// Main class
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
      AdminDashboardData(
        stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
        recentActivities: RecentActivities.fromJson(
            json['recent_activities'] as Map<String, dynamic>),
        quickLinks:
            QuickLinks.fromJson(json['quick_links'] as Map<String, dynamic>),
        lastUpdated: json['last_updated'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => _$AdminDashboardDataToJson(this);
}

// UserStats class
@JsonSerializable()
class UserStats {
  final Users users;
  UserStats({required this.users});

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        users: Users.fromJson(json['users'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

// Users class with proper numeric field handling
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

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        total: int.tryParse(json['total'].toString()) ?? 0,
        admins: int.tryParse(json['admins'].toString()) ?? 0,
        sellers: int.tryParse(json['sellers'].toString()) ?? 0,
        buyers: int.tryParse(json['buyers'].toString()) ?? 0,
        serviceProviders:
            int.tryParse(json['service_providers'].toString()) ?? 0,
        newUsersToday: int.tryParse(json['new_users_today'].toString()) ?? 0,
        activeUsers: int.tryParse(json['active_users'].toString()) ?? 0,
        verifiedUsers: int.tryParse(json['verified_users'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => _$UsersToJson(this);
}

// RecentActivities class
@JsonSerializable()
class RecentActivities {
  @JsonKey(name: 'latest_users')
  final List<LatestUser> latestUsers;

  RecentActivities({required this.latestUsers});

  factory RecentActivities.fromJson(Map<String, dynamic> json) =>
      RecentActivities(
        latestUsers: (json['latest_users'] as List<dynamic>)
            .map((e) => LatestUser.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => _$RecentActivitiesToJson(this);
}

// LatestUser class with proper numeric field handling
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

  factory LatestUser.fromJson(Map<String, dynamic> json) => LatestUser(
        id: int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => _$LatestUserToJson(this);
}

// QuickLinks class
@JsonSerializable()
class QuickLinks {
  final List<Link> users;
  final List<Link> reports;

  QuickLinks({
    required this.users,
    required this.reports,
  });

  factory QuickLinks.fromJson(Map<String, dynamic> json) => QuickLinks(
        users: (json['users'] as List<dynamic>)
            .map((e) => Link.fromJson(e as Map<String, dynamic>))
            .toList(),
        reports: (json['reports'] as List<dynamic>)
            .map((e) => Link.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => _$QuickLinksToJson(this);
}

// Link class
@JsonSerializable()
class Link {
  final String title;
  final String route;

  Link({
    required this.title,
    required this.route,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        title: json['title'] as String? ?? '',
        route: json['route'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}
