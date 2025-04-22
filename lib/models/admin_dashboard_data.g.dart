// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDashboardData _$AdminDashboardDataFromJson(Map<String, dynamic> json) =>
    AdminDashboardData(
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      recentActivities: RecentActivities.fromJson(
          json['recent_activities'] as Map<String, dynamic>),
      systemInfo:
          SystemInfo.fromJson(json['system_info'] as Map<String, dynamic>),
      quickLinks:
          QuickLinks.fromJson(json['quick_links'] as Map<String, dynamic>),
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$AdminDashboardDataToJson(AdminDashboardData instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'recent_activities': instance.recentActivities,
      'system_info': instance.systemInfo,
      'quick_links': instance.quickLinks,
      'last_updated': instance.lastUpdated,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      users: Users.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'users': instance.users,
    };

Users _$UsersFromJson(Map<String, dynamic> json) => Users(
      total: const StringToIntConverter().fromJson(json['total']),
      admins: const StringToIntConverter().fromJson(json['admins']),
      sellers: const StringToIntConverter().fromJson(json['sellers']),
      buyers: const StringToIntConverter().fromJson(json['buyers']),
      serviceProviders:
          const StringToIntConverter().fromJson(json['service_providers']),
      newUsersToday:
          const StringToIntConverter().fromJson(json['new_users_today']),
      activeUsers: const StringToIntConverter().fromJson(json['active_users']),
      verifiedUsers:
          const StringToIntConverter().fromJson(json['verified_users']),
    );

Map<String, dynamic> _$UsersToJson(Users instance) => <String, dynamic>{
      'total': const StringToIntConverter().toJson(instance.total),
      'admins': const StringToIntConverter().toJson(instance.admins),
      'sellers': const StringToIntConverter().toJson(instance.sellers),
      'buyers': const StringToIntConverter().toJson(instance.buyers),
      'service_providers':
          const StringToIntConverter().toJson(instance.serviceProviders),
      'new_users_today':
          const StringToIntConverter().toJson(instance.newUsersToday),
      'active_users': const StringToIntConverter().toJson(instance.activeUsers),
      'verified_users':
          const StringToIntConverter().toJson(instance.verifiedUsers),
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
