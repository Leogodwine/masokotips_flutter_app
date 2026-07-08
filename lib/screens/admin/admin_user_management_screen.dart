import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load users on initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<AdminProvider>().loadUsers(search: query);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminProvider>().loadUsers(search: _searchController.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<AdminProvider>().loadUsers(search: '');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {}); // For suffix icon visibility
                _onSearchChanged(value);
              },
            ),
          ),
        Expanded(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              if (adminProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${adminProvider.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          adminProvider.loadUsers();
                        },
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                );
              }

              final users = adminProvider.users;
              if (users.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noUsersFound));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            user.isSuspended ? Colors.red : Colors.green,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(user.name)),
                          if (user.isSuspended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Suspended',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          if (user.phoneNumber != null &&
                              user.phoneNumber!.isNotEmpty)
                            Text(user.phoneNumber!),
                          Text(
                            'Role: ${user.roles.join(", ")}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditUserDialog(context, user, adminProvider);
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(
                                context, user, adminProvider);
                          } else if (value == 'suspend') {
                            _showSuspendConfirmationDialog(
                                context, user, adminProvider, true);
                          } else if (value == 'unsuspend') {
                            _showSuspendConfirmationDialog(
                                context, user, adminProvider, false);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.edit),
                              ],
                            ),
                          ),
                          if (user.isSuspended)
                            PopupMenuItem(
                              value: 'unsuspend',
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 20, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.unsuspend),
                                ],
                              ),
                            )
                          else
                            PopupMenuItem(
                              value: 'suspend',
                              child: Row(
                                children: [
                                  const Icon(Icons.block,
                                      size: 20, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.suspend),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        _showUserDetailsDialog(context, user, adminProvider);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(
      BuildContext context, User user, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              Text('Phone: ${user.phoneNumber}'),
            Text('Role: ${user.roles.join(", ")}'),
            Text('Status: ${user.isSuspended ? "Suspended" : "Active"}'),
            Text('Created: ${user.createdAt.toString().split(" ")[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditUserDialog(context, user, adminProvider);
            },
            child: Text(AppLocalizations.of(context)!.edit),
          ),
        ],
      ),
    );
  }

  // Show dialog to edit user details
  void _showEditUserDialog(
      BuildContext context, User user, AdminProvider adminProvider) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    // Get the primary role from the user's roles list
    String selectedRole = user.roles.isNotEmpty ? user.roles.first : 'buyer';
    // Use the actual isActive value from user
    bool isActive = user.isActive;
    bool isSuspended = user.isSuspended;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.editUser),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: [
                    DropdownMenuItem(value: 'admin', child: Text(AppLocalizations.of(context)!.admin)),
                    DropdownMenuItem(value: 'buyer', child: Text(AppLocalizations.of(context)!.buyer)),
                    DropdownMenuItem(value: 'seller', child: Text(AppLocalizations.of(context)!.seller)),
                    DropdownMenuItem(
                        value: 'service_provider',
                        child: Text(AppLocalizations.of(context)!.serviceProvider)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.active),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.suspended),
                  value: isSuspended,
                  onChanged: (value) {
                    setState(() {
                      isSuspended = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                // Prepare user data for update
                final userData = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone_number': phoneController.text.isNotEmpty
                      ? phoneController.text
                      : null,
                  'role': selectedRole,
                  'is_active': isActive,
                  'is_suspended': isSuspended,
                };

                // Close the dialog
                Navigator.pop(dialogContext);

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.updatingUser)),
                );

                // Update the user
                final success =
                    await adminProvider.updateUser(user.id, userData);

                if (context.mounted) {
                  // Show result message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'User updated successfully'
                            : 'Failed to update user: ${adminProvider.error}',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog for deleting a user
  void _showDeleteConfirmationDialog(
      BuildContext context, User user, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // Close the dialog
              Navigator.pop(dialogContext);

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.deletingUser)),
              );

              // Delete the user
              final success = await adminProvider.deleteUser(user.id);

              if (context.mounted) {
                // Show result message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User deleted successfully'
                          : 'Failed to delete user: ${adminProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog for suspending/unsuspending a user
  void _showSuspendConfirmationDialog(BuildContext context, User user,
      AdminProvider adminProvider, bool suspend) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(suspend ? 'Suspend User' : 'Unsuspend User'),
        content: Text(suspend
            ? 'Are you sure you want to suspend ${user.name}?\n\nThe user will not be able to access the app until unsuspended.'
            : 'Are you sure you want to unsuspend ${user.name}?\n\nThe user will be able to access the app again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: suspend ? Colors.orange : Colors.green),
            onPressed: () async {
              // Close the dialog
              Navigator.pop(dialogContext);

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(suspend
                        ? 'Suspending user...'
                        : 'Unsuspending user...')),
              );

              // Suspend/unsuspend the user
              final success = await adminProvider.suspendUser(user.id, suspend);

              if (context.mounted) {
                // Show result message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User ${suspend ? "suspended" : "unsuspended"} successfully'
                          : 'Failed to ${suspend ? "suspend" : "unsuspend"} user: ${adminProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(suspend ? 'Suspend' : 'Unsuspend'),
          ),
        ],
      ),
    );
  }
}
