import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().loadUsers();
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
              context.read<AdminProvider>().loadUsers();
            },
          ),
        ],
      ),
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            style: TextStyle(color: Colors.white, fontSize: 10),
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditUserDialog(context, user);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, user);
                          break;
                        case 'suspend':
                          _showSuspendConfirmation(context, user);
                          break;
                        case 'unsuspend':
                          _showUnsuspendConfirmation(context, user);
                          break;
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
                              const Icon(Icons.block, size: 20, color: Colors.orange),
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
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content: Text(
            'Are you sure you want to delete ${user.name}?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final adminProvider = context.read<AdminProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.deletingUser)),
              );

              final success = await adminProvider.deleteUser(user.id);

              scaffoldMessenger.hideCurrentSnackBar();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'User deleted successfully'
                        : 'Failed to delete user: ${adminProvider.error ?? "Unknown error"}',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showSuspendConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.suspendUser),
        content: Text(
            'Are you sure you want to suspend ${user.name}?\n\nThe user will not be able to access the app until unsuspended.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final adminProvider = context.read<AdminProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.suspendingUser)),
              );

              final success = await adminProvider.suspendUser(user.id, true);

              scaffoldMessenger.hideCurrentSnackBar();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'User suspended successfully'
                        : 'Failed to suspend user: ${adminProvider.error ?? "Unknown error"}',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.suspend),
          ),
        ],
      ),
    );
  }

  void _showUnsuspendConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.unsuspendUser),
        content: Text(
            'Are you sure you want to unsuspend ${user.name}?\n\nThe user will be able to access the app again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final adminProvider = context.read<AdminProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.unsuspendingUser)),
              );

              final success = await adminProvider.suspendUser(user.id, false);

              scaffoldMessenger.hideCurrentSnackBar();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'User unsuspended successfully'
                        : 'Failed to unsuspend user: ${adminProvider.error ?? "Unknown error"}',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.unsuspend),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    String selectedRole = user.roles.isNotEmpty ? user.roles.first : 'buyer';
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
                final adminProvider = context.read<AdminProvider>();
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                // Prepare payload
                final userData = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text.isNotEmpty
                      ? phoneController.text
                      : null,
                  'role': selectedRole,
                  'is_active': isActive,
                  'is_suspended': isSuspended,
                };

                // Show loading SnackBar
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.updatingUser)),
                );

                final success =
                    await adminProvider.updateUser(user.id, userData);

                // Close the dialog
                navigator.pop();

                // Show result SnackBar
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User updated successfully'
                          : 'Failed: ${adminProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  adminProvider.loadUsers();
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }
}
