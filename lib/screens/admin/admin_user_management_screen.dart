import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.isEmpty) return users;
    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.phoneNumber?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or phone...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
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
              setState(() => _searchQuery = value);
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
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final users = _filterUsers(adminProvider.users);
              if (users.isEmpty) {
                return const Center(child: Text('No users found'));
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
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          if (user.isSuspended)
                            const PopupMenuItem(
                              value: 'unsuspend',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Unsuspend'),
                                ],
                              ),
                            )
                          else
                            const PopupMenuItem(
                              value: 'suspend',
                              child: Row(
                                children: [
                                  Icon(Icons.block,
                                      size: 20, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Suspend'),
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
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditUserDialog(context, user, adminProvider);
            },
            child: const Text('Edit'),
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
          title: const Text('Edit User'),
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
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                    DropdownMenuItem(value: 'seller', child: Text('Seller')),
                    DropdownMenuItem(
                        value: 'service_provider',
                        child: Text('Service Provider')),
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
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Suspended'),
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
              child: const Text('Cancel'),
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
                  const SnackBar(content: Text('Updating user...')),
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
              child: const Text('Save'),
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
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // Close the dialog
              Navigator.pop(dialogContext);

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting user...')),
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
            child: const Text('Delete'),
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
            child: const Text('Cancel'),
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
