import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AdminProvider>(
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

          final users = adminProvider.users;
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name[0]),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditUserDialog(context, user, adminProvider);
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(
                          context, user, adminProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
    // We don't have an isActive field, so we'll default to true
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  value: selectedRole,
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                };

                // Close the dialog
                Navigator.pop(context);

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
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // Close the dialog
              Navigator.pop(context);

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
}
