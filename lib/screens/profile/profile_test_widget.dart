import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class ProfileTestWidget extends StatefulWidget {
  const ProfileTestWidget({super.key});

  @override
  State<ProfileTestWidget> createState() => _ProfileTestWidgetState();
}

class _ProfileTestWidgetState extends State<ProfileTestWidget> {
  final ApiService _apiService = ApiService(
    baseUrl: ApiConfig.baseUrl,
    apiKey: ApiConfig.apiKey,
  );
  String _responseText = "No response yet";
  bool _isLoading = false;

  Future<void> _testGetUser() async {
    setState(() {
      _isLoading = true;
      _responseText = "Loading...";
    });

    try {
      final user = await _apiService.getUserProfile();
      setState(() {
        _responseText = "Success! User: ${user.name}, Email: ${user.email}";
      });
    } catch (e) {
      setState(() {
        _responseText = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetProducts() async {
    setState(() {
      _isLoading = true;
      _responseText = "Loading...";
    });

    try {
      final products = await _apiService.getProducts(page: 1);
      setState(() {
        _responseText = "Success! Fetched ${products.length} products";
      });
    } catch (e) {
      setState(() {
        _responseText = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
      _responseText = "Logging in...";
    });

    try {
      // Use test account credentials
      await authProvider.login("test@example.com", "password");
      setState(() {
        _responseText = "Login successful! User: ${authProvider.user?.name}";
      });
    } catch (e) {
      setState(() {
        _responseText = "Login error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Integration Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Test Backend Integration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _testLogin,
                child: const Text('Test Login'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _testGetUser,
                child: const Text('Test Get User'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _testGetProducts,
                child: const Text('Test Get Products'),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        _responseText,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 32),
              // Display user info if logged in
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isAuthenticated &&
                      authProvider.user != null) {
                    final user = authProvider.user!;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${user.name}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Email: ${user.email}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Roles: ${user.roles.join(", ")}',
                                style: const TextStyle(fontSize: 16)),
                            ElevatedButton(
                              onPressed: () => authProvider.logout(),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Logout',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
