import 'package:json_annotation/json_annotation.dart';

// Single file with all classes
part 'admin_dashboard_data.g.dart';

// Main class
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
      AdminDashboardData(
        stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
        recentActivities: RecentActivities.fromJson(
            json['recent_activities'] as Map<String, dynamic>),
        systemInfo:
            SystemInfo.fromJson(json['system_info'] as Map<String, dynamic>),
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

// SystemInfo class
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

  factory SystemInfo.fromJson(Map<String, dynamic> json) => SystemInfo(
        phpVersion: json['php_version'] as String? ?? '',
        laravelVersion: json['laravel_version'] as String? ?? '',
        serverSoftware: json['server_software'] as String? ?? '',
        databaseConnection: json['database_connection'] as String? ?? '',
        timezone: json['timezone'] as String? ?? '',
        memoryUsage: json['memory_usage'] as String? ?? '',
        diskFreeSpace: json['disk_free_space'] as String? ?? '',
        uploadMaxFilesize: json['upload_max_filesize'] as String? ?? '',
        maxExecutionTime: json['max_execution_time'] as String? ?? '',
        serverTime: json['server_time'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => _$SystemInfoToJson(this);
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
