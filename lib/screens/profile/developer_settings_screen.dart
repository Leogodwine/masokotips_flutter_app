import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  State<DeveloperSettingsScreen> createState() =>
      _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  final TextEditingController _apiUrlController = TextEditingController(
    text: ApiService.baseUrl,
  );

  @override
  void initState() {
    super.initState();
    // Ensure ApiService methods exist
    ApiService.updateBaseUrl('http://127.0.0.1:8000/api');
    _apiUrlController.text = ApiService.baseUrl;
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
      ApiService.updateBaseUrl(newUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API URL updated - restart app to apply changes'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _testApiConnection() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing API connection...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Show a loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
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

      // Test the API connection
      final bool isConnected = await ApiService.checkApiConnection();

      // Dismiss the loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected
              ? 'Connection successful to ${ApiService.baseUrl}'
              : 'Connection failed to ${ApiService.baseUrl}'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // Dismiss the loading dialog if it's showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection test error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearStoredData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Stored Data'),
        content: const Text(
          'This will clear all stored data including login information. You will need to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All stored data cleared'),
                ),
              );
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
