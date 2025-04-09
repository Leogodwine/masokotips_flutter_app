// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDashboardData _$AdminDashboardDataFromJson(Map<String, dynamic> json) =>
    AdminDashboardData(
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      recent_activities: RecentActivities.fromJson(
          json['recent_activities'] as Map<String, dynamic>),
      system_info:
          SystemInfo.fromJson(json['system_info'] as Map<String, dynamic>),
      quick_links:
          QuickLinks.fromJson(json['quick_links'] as Map<String, dynamic>),
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$AdminDashboardDataToJson(AdminDashboardData instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'recent_activities': instance.recent_activities,
      'system_info': instance.system_info,
      'quick_links': instance.quick_links,
      'last_updated': instance.lastUpdated,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      users: Users.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'users': instance.users,
    };

Users _$UsersFromJson(Map<String, dynamic> json) => Users(
      total: (json['total'] as num).toInt(),
      admins: (json['admins'] as num).toInt(),
      sellers: (json['sellers'] as num).toInt(),
      buyers: (json['buyers'] as num).toInt(),
      service_providers: (json['service_providers'] as num).toInt(),
      newUsersToday: (json['new_users_today'] as num).toInt(),
      activeUsers: (json['active_users'] as num).toInt(),
      verifiedUsers: (json['verified_users'] as num).toInt(),
    );

Map<String, dynamic> _$UsersToJson(Users instance) => <String, dynamic>{
      'total': instance.total,
      'admins': instance.admins,
      'sellers': instance.sellers,
      'buyers': instance.buyers,
      'service_providers': instance.service_providers,
      'new_users_today': instance.newUsersToday,
      'active_users': instance.activeUsers,
      'verified_users': instance.verifiedUsers,
    };

RecentActivities _$RecentActivitiesFromJson(Map<String, dynamic> json) =>
    RecentActivities(
      latestUsers: (json['latest_users'] as List<dynamic>)
          .map((e) => LatestUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecentActivitiesToJson(RecentActivities instance) =>
    <String, dynamic>{
      'latest_users': instance.latestUsers,
    };

LatestUser _$LatestUserFromJson(Map<String, dynamic> json) => LatestUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$LatestUserToJson(LatestUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'created_at': instance.createdAt,
    };

SystemInfo _$SystemInfoFromJson(Map<String, dynamic> json) => SystemInfo(
      phpVersion: json['php_version'] as String,
      laravelVersion: json['laravel_version'] as String,
      serverSoftware: json['server_software'] as String,
      databaseConnection: json['database_connection'] as String,
      timezone: json['timezone'] as String,
      memoryUsage: json['memory_usage'] as String,
      diskFreeSpace: json['disk_free_space'] as String,
      uploadMaxFilesize: json['upload_max_filesize'] as String,
      maxExecutionTime: json['max_execution_time'] as String,
      serverTime: json['server_time'] as String,
    );

Map<String, dynamic> _$SystemInfoToJson(SystemInfo instance) =>
    <String, dynamic>{
      'php_version': instance.phpVersion,
      'laravel_version': instance.laravelVersion,
      'server_software': instance.serverSoftware,
      'database_connection': instance.databaseConnection,
      'timezone': instance.timezone,
      'memory_usage': instance.memoryUsage,
      'disk_free_space': instance.diskFreeSpace,
      'upload_max_filesize': instance.uploadMaxFilesize,
      'max_execution_time': instance.maxExecutionTime,
      'server_time': instance.serverTime,
    };

QuickLinks _$QuickLinksFromJson(Map<String, dynamic> json) => QuickLinks(
      users: (json['users'] as List<dynamic>)
          .map((e) => Link.fromJson(e as Map<String, dynamic>))
          .toList(),
      reports: (json['reports'] as List<dynamic>)
          .map((e) => Link.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuickLinksToJson(QuickLinks instance) =>
    <String, dynamic>{
      'users': instance.users,
      'reports': instance.reports,
    };

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
      title: json['title'] as String,
      route: json['route'] as String,
    );

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'title': instance.title,
      'route': instance.route,
    };
