import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'package:flutter/gestures.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/api_error_widget.dart';
import 'forgot_password_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Add listeners to clear field-specific errors when user starts typing
    _usernameController.addListener(_clearUsernameError);
    _passwordController.addListener(_clearPasswordError);
  }

  void _clearUsernameError() {
    if (_usernameError != null && _usernameController.text.isNotEmpty) {
      setState(() {
        _usernameError = null;
      });
    }
  }

  void _clearPasswordError() {
    if (_passwordError != null && _passwordController.text.isNotEmpty) {
      setState(() {
        _passwordError = null;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authProvider = context.read<AuthProvider>();

        // Clear previous field-specific errors
        setState(() {
          _usernameError = null;
          _passwordError = null;
        });

        await authProvider.login(
          _usernameController.text,
          _passwordController.text,
        );

        // Only navigate if the widget is still mounted
        if (mounted) {
          final user = authProvider.user;
          if (user != null) {
            // Debug print user roles
            debugPrint('User roles: ${user.roles}');

            // Navigate to profile screen first for all users
            debugPrint('Navigating to profile screen');
            Navigator.pushReplacementNamed(context, '/profile');
          } else {
            debugPrint('User is null after login');
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        // Parse the error message to extract field-specific errors
        final errorString = e.toString();

        // Check if the error contains field-specific messages (Username: or Password: prefix)
        if (errorString.contains('Exception:Username:') ||
            errorString.contains('Exception:Password:')) {
          String? usernameError;
          String? passwordError;

          // Extract username error
          if (errorString.contains('Username:')) {
            final match =
                RegExp(r'Username:\s*([^\s]+.*?)(?:\s*Exception|Password:|$)')
                    .firstMatch(errorString);
            if (match != null) {
              usernameError = match.group(1)?.trim();
            }
          }

          // Extract password error
          if (errorString.contains('Password:')) {
            final match = RegExp(r'Password:\s*([^\s]+.*?)(?:\s*Exception|$)')
                .firstMatch(errorString);
            if (match != null) {
              passwordError = match.group(1)?.trim();
            }
          }

          setState(() {
            _usernameError = usernameError;
            _passwordError = passwordError;
            // Show general error if no specific field error
            _errorMessage = (usernameError == null && passwordError == null)
                ? errorString.contains('Exception:')
                    ? errorString.split('Exception:')[1].trim()
                    : 'Login failed. Please check your credentials.'
                : null;
          });
        } else {
          // General error - check for common authentication failure patterns
          final errorMessage = errorString.contains('Exception:')
              ? errorString.split('Exception:')[1].trim()
              : 'Login failed. Please check your credentials.';

          // For generic "invalid credentials" errors, show more helpful message
          final lowerError = errorMessage.toLowerCase();
          String? specificError;

          if (lowerError.contains('invalid') &&
              (lowerError.contains('username') ||
                  lowerError.contains('password') ||
                  lowerError.contains('credential'))) {
            // Check if we can determine which field might be wrong based on what user entered
            final username = _usernameController.text.trim();
            final password = _passwordController.text;

            if (username.isEmpty) {
              specificError = 'Please enter your username';
              _usernameError = 'Username is required';
            } else if (password.isEmpty) {
              specificError = 'Please enter your password';
              _passwordError = 'Password is required';
            } else {
              // Show detailed error with both suggestions
              specificError =
                  'Invalid username or password. Please check your credentials and try again.';
              // Don't show field-specific errors since we can't determine which is wrong
            }
          }

          setState(() {
            _usernameError = _usernameError;
            _passwordError = _passwordError;
            _errorMessage = specificError ?? errorMessage;
          });
        }
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App Icon
                  Image.asset(
                    'assets/images/logo-moble.webp',
                    height: 80,
                    width: 80,
                  ),

                  const SizedBox(height: 16),

                  // Welcome Text
                  Text(
                    AppLocalizations.of(context)!.welcomeBack,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(context)!.signInToContinue,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null) ...[
                    ApiErrorWidget(
                      errorMessage: _errorMessage,
                      onRetry: _errorMessage != null ? _login : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.username,
                      hintText: AppLocalizations.of(context)!.enterUsername,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      errorText: _usernameError,
                      errorStyle: _usernameError != null
                          ? const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500)
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.usernameRequired;
                      }
                      if (value.length < 3) {
                        return AppLocalizations.of(context)!.usernameMinLength;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      hintText: AppLocalizations.of(context)!.enterPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      errorText: _passwordError,
                      errorStyle: _passwordError != null
                          ? const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500)
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.passwordRequired;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _login(),
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgotPassword,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  LoadingButton(
                    isLoading: _isLoading,
                    text: AppLocalizations.of(context)!.signIn,
                    onPressed: _login,
                  ),

                  const SizedBox(height: 32),

                  // Register Link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(context)!.noAccount,
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.register,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
