import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/market_info.dart';
import '../../services/market_info_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/image_upload_helper.dart';

class MarketInfoManagementScreen extends StatefulWidget {
  const MarketInfoManagementScreen({super.key});

  @override
  State<MarketInfoManagementScreen> createState() =>
      _MarketInfoManagementScreenState();
}

class _MarketInfoManagementScreenState
    extends State<MarketInfoManagementScreen> {
  final MarketInfoService _marketInfoService = MarketInfoService();
  List<MarketInfo> _marketInfoList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _marketInfoService.setAuthToken(authProvider.token!);
      _loadMarketInfo();
    }
  }

  Future<void> _loadMarketInfo() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final marketInfo = await _marketInfoService.getAllMarketInfo();
      if (mounted) {
        setState(() {
          _marketInfoList = marketInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMarketInfo(MarketInfo marketInfo) async {
    try {
      await _marketInfoService.deleteMarketInfo(marketInfo.id.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Market information deleted successfully')),
        );
        _loadMarketInfo(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete market information: $e')),
        );
      }
    }
  }

  Future<void> _openAddMarketInfoScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated and is an admin
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add market information'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to admin login screen instead of regular login
        Navigator.pushNamed(context, '/admin/login');
      }
      return;
    }

    // Check if user has admin role
    if (!authProvider.user!.roles.contains('admin')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only administrators can add market information'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Set the auth token for the market info service
    _marketInfoService.setAuthToken(authProvider.token!);

    // Navigate to add market info screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMarketInfoScreen(
            onMarketInfoAdded: (marketInfo) {
              setState(() {
                _marketInfoList.add(marketInfo);
              });
            },
            marketInfoService: _marketInfoService,
          ),
        ),
      );
    }
  }

  Future<void> _openEditMarketInfoScreen(MarketInfo marketInfo) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to edit market information'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to admin login screen instead of regular login
        Navigator.pushNamed(context, '/admin/login');
      }
      return;
    }

    // Check if user has admin role
    if (!authProvider.user!.roles.contains('admin')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only administrators can edit market information'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Set the auth token for the market info service
    _marketInfoService.setAuthToken(authProvider.token!);

    // Navigate to edit market info screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditMarketInfoScreen(
            marketInfo: marketInfo,
            onMarketInfoUpdated: (updatedMarketInfo) {
              setState(() {
                final index = _marketInfoList
                    .indexWhere((info) => info.id == updatedMarketInfo.id);
                if (index != -1) {
                  _marketInfoList[index] = updatedMarketInfo;
                }
              });
            },
            marketInfoService: _marketInfoService,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Information Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorHandler(
                  message: _error!,
                  onRetry: _loadMarketInfo,
                )
              : RefreshIndicator(
                  onRefresh: _loadMarketInfo,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Market Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            ElevatedButton.icon(
                              onPressed: _openAddMarketInfoScreen,
                              icon: const Icon(Icons.add),
                              label: const Text('Add New'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _marketInfoList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No market information yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add your first market information to get started',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: _openAddMarketInfoScreen,
                                      icon: const Icon(Icons.add),
                                      label:
                                          const Text('Add Market Information'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _marketInfoList.length,
                                itemBuilder: (context, index) {
                                  final marketInfo = _marketInfoList[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      leading: marketInfo.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                marketInfo.imageUrl!,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      title: Text(marketInfo.title),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            marketInfo.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (marketInfo.location != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Chip(
                                                label: Text(
                                                  marketInfo.location!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                backgroundColor:
                                                    Colors.blue[100],
                                                labelStyle: TextStyle(
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                            ),
                                          if (marketInfo.category != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Chip(
                                                label: Text(
                                                  marketInfo.category!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                backgroundColor:
                                                    Colors.green[100],
                                                labelStyle: TextStyle(
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              _openEditMarketInfoScreen(
                                                  marketInfo);
                                              break;
                                            case 'delete':
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Delete Market Information'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this market information?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('CANCEL'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteMarketInfo(
                                                            marketInfo);
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.red,
                                                      ),
                                                      child:
                                                          const Text('DELETE'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              break;
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMarketInfoScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddMarketInfoScreen extends StatefulWidget {
  final Function(MarketInfo) onMarketInfoAdded;
  final MarketInfoService marketInfoService;

  const AddMarketInfoScreen({
    super.key,
    required this.onMarketInfoAdded,
    required this.marketInfoService,
  });

  @override
  State<AddMarketInfoScreen> createState() => _AddMarketInfoScreenState();
}

class _AddMarketInfoScreenState extends State<AddMarketInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await ImageUploadHelper.pickImage();

    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        String? imageUrl;
        if (_imageFile != null) {
          // Create a temporary market info to get an ID
          final tempMarketInfo = await widget.marketInfoService.addMarketInfo(
            title: _titleController.text,
            content: _contentController.text,
            location: _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
            category: _categoryController.text.isNotEmpty
                ? _categoryController.text
                : null,
          );

          // Upload the image
          imageUrl = await widget.marketInfoService.uploadMarketInfoImage(
            tempMarketInfo.id.toString(),
            _imageFile!.path,
          );

          // Update the market info with the image URL
          final updatedMarketInfo =
              await widget.marketInfoService.updateMarketInfo(
            id: tempMarketInfo.id.toString(),
            title: _titleController.text,
            content: _contentController.text,
            imageUrl: imageUrl,
            location: _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
            category: _categoryController.text.isNotEmpty
                ? _categoryController.text
                : null,
          );

          widget.onMarketInfoAdded(updatedMarketInfo);
        } else {
          // Create market info without image
          final marketInfo = await widget.marketInfoService.addMarketInfo(
            title: _titleController.text,
            content: _contentController.text,
            location: _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
            category: _categoryController.text.isNotEmpty
                ? _categoryController.text
                : null,
          );

          widget.onMarketInfoAdded(marketInfo);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Market Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Add Image'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 48),
                                ),
                              );
                            },
                          )
                        : Image.file(
                            _imageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 48),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Market Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditMarketInfoScreen extends StatefulWidget {
  final MarketInfo marketInfo;
  final Function(MarketInfo) onMarketInfoUpdated;
  final MarketInfoService marketInfoService;

  const EditMarketInfoScreen({
    super.key,
    required this.marketInfo,
    required this.onMarketInfoUpdated,
    required this.marketInfoService,
  });

  @override
  State<EditMarketInfoScreen> createState() => _EditMarketInfoScreenState();
}

class _EditMarketInfoScreenState extends State<EditMarketInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _locationController;
  late final TextEditingController _categoryController;
  File? _imageFile;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.marketInfo.title);
    _contentController = TextEditingController(text: widget.marketInfo.content);
    _locationController =
        TextEditingController(text: widget.marketInfo.location ?? '');
    _categoryController =
        TextEditingController(text: widget.marketInfo.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await ImageUploadHelper.pickImage();

    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await widget.marketInfoService.uploadMarketInfoImage(
            widget.marketInfo.id.toString(),
            _imageFile!.path,
          );
        }

        final updatedMarketInfo =
            await widget.marketInfoService.updateMarketInfo(
          id: widget.marketInfo.id.toString(),
          title: _titleController.text,
          content: _contentController.text,
          imageUrl: imageUrl ?? widget.marketInfo.imageUrl,
          location: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : null,
        );

        widget.onMarketInfoUpdated(updatedMarketInfo);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Market Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 48),
                                ),
                              );
                            },
                          )
                        : Image.file(
                            _imageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 48),
                                ),
                              );
                            },
                          ),
                  ),
                )
              else if (widget.marketInfo.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.marketInfo.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.error_outline, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Market Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
