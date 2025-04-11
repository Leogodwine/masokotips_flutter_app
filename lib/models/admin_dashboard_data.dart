import 'package:json_annotation/json_annotation.dart';

part 'admin_dashboard_data.g.dart';

@JsonSerializable()
class AdminDashboardData {
  final UserStats stats;
  @JsonKey(name: 'recent_activities')
  final RecentActivities recentActivities;
  @JsonKey(name: 'system_info')
  final SystemInfo systemInfo;
  @JsonKey(name: 'quick_links')
  final QuickLinks quickLinks;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  AdminDashboardData({
    required this.stats,
    required this.recentActivities,
    required this.systemInfo,
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

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);

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

  factory LatestUser.fromJson(Map<String, dynamic> json) =>
      _$LatestUserFromJson(json);

  Map<String, dynamic> toJson() => _$LatestUserToJson(this);
}

@JsonSerializable()
class SystemInfo {
  @JsonKey(name: 'php_version')
  final String phpVersion;
  @JsonKey(name: 'laravel_version')
  final String laravelVersion;
  @JsonKey(name: 'server_software')
  final String serverSoftware;
  @JsonKey(name: 'database_connection')
  final String databaseConnection;
  final String timezone;
  @JsonKey(name: 'memory_usage')
  final String memoryUsage;
  @JsonKey(name: 'disk_free_space')
  final String diskFreeSpace;
  @JsonKey(name: 'upload_max_filesize')
  final String uploadMaxFilesize;
  @JsonKey(name: 'max_execution_time')
  final String maxExecutionTime;
  @JsonKey(name: 'server_time')
  final String serverTime;

  SystemInfo({
    required this.phpVersion,
    required this.laravelVersion,
    required this.serverSoftware,
    required this.databaseConnection,
    required this.timezone,
    required this.memoryUsage,
    required this.diskFreeSpace,
    required this.uploadMaxFilesize,
    required this.maxExecutionTime,
    required this.serverTime,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) =>
      _$SystemInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SystemInfoToJson(this);
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
