import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  State<DeveloperSettingsScreen> createState() =>
      _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  late final TextEditingController _apiUrlController;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
      baseUrl: ApiConfig.baseUrl,
      apiKey: ApiConfig.apiKey,
    );
    _apiUrlController = TextEditingController(text: _apiService.baseUrl);
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Environment Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // API URL Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Base URL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: Changing this requires app restart to take effect.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiUrlController,
                    decoration: const InputDecoration(
                      labelText: 'API URL',
                      border: OutlineInputBorder(),
                      hintText: 'http://192.168.100.103:8000/api',
                    ),
                    keyboardType: TextInputType.url,
                    onEditingComplete: _updateApiUrl,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateApiUrl,
                    child: const Text('Save URL'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Testing Tools',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Testing buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _testApiConnection,
                    child: const Text('Test API Connection'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _clearStoredData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear Stored Data'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateApiUrl() {
    String newUrl = _apiUrlController.text.trim();
    if (newUrl.isNotEmpty) {
      _apiService = ApiService(
        baseUrl: newUrl,
        apiKey: ApiConfig.apiKey,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API URL updated - restart app to apply changes'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _testApiConnection() async {
    // Capture context-dependent objects before async operation
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Testing API connection...'),
          duration: Duration(seconds: 1),
        ),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const AlertDialog(
          title: Text('Testing Connection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Trying to connect to the API...'),
            ],
          ),
        ),
      );

      final bool isConnected = await _apiService.checkConnection();
      if (mounted) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(isConnected
                ? 'Connection successful to ${_apiService.baseUrl}'
                : 'Connection failed to ${_apiService.baseUrl}'),
            backgroundColor: isConnected ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (navigator.canPop()) {
          navigator.pop();
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Connection test error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearStoredData() async {
    // Capture context-dependent objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Stored Data'),
        content: const Text(
          'This will clear all stored data including login information. You will need to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await authProvider.logout();
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('All stored data cleared'),
                  ),
                );
              }
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
