// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AdminDashboardDataToJson(AdminDashboardData instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'recent_activities': instance.recentActivities,
      'quick_links': instance.quickLinks,
      'last_updated': instance.lastUpdated,
    };

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'users': instance.users,
    };

Map<String, dynamic> _$UsersToJson(Users instance) => <String, dynamic>{
      'total': instance.total,
      'admins': instance.admins,
      'sellers': instance.sellers,
      'buyers': instance.buyers,
      'service_providers': instance.serviceProviders,
      'new_users_today': instance.newUsersToday,
      'active_users': instance.activeUsers,
      'verified_users': instance.verifiedUsers,
    };

Map<String, dynamic> _$RecentActivitiesToJson(RecentActivities instance) =>
    <String, dynamic>{
      'latest_users': instance.latestUsers,
    };

Map<String, dynamic> _$LatestUserToJson(LatestUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'created_at': instance.createdAt,
    };

Map<String, dynamic> _$QuickLinksToJson(QuickLinks instance) =>
    <String, dynamic>{
      'users': instance.users,
      'reports': instance.reports,
    };

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'title': instance.title,
      'route': instance.route,
    };
