import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/api_error_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../utils/image_upload_helper.dart';
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../subscription/subscription_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _countryController = TextEditingController();
  final _referralCodeController = TextEditingController();

  String _selectedRole = 'buyer'; // Default role
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Proof of address fields
  String _selectedProofType = '';
  XFile? _proofOfAddressFile;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _countryController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final localizations = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authProvider = context.read<AuthProvider>();

        // 1. Register the user
        await authProvider.register(
          _nameController.text.trim(),
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          role: _selectedRole,
          phone: _phoneController.text,
          location: _locationController.text,
          country: _countryController.text,
          referralCode: _referralCodeController.text.isNotEmpty
              ? _referralCodeController.text
              : null,
          proofOfAddressType:
              _selectedProofType.isNotEmpty ? _selectedProofType : null,
          proofOfAddress: _proofOfAddressFile,
        );

        // 2. Automatically log the user in so that subscription APIs have a token
        await authProvider.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          // Registration & login were successful - redirect to profile screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.registrationSuccessful),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to subscription screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionScreen(),
            ),
          );
        }
      } catch (e) {
        String errorMsg = e.toString();

        // Check if it contains the "role" error message specifically
        if (errorMsg.contains('role') && errorMsg.contains('required')) {
          errorMsg = localizations.selectRoleError;
        } else if (errorMsg.contains('email') && errorMsg.contains('taken')) {
          errorMsg = localizations.emailTaken;
        } else {
          // Generic error fallback
          errorMsg = e.toString().contains('Exception:')
              ? e.toString().split('Exception:')[1].trim()
              : localizations.registrationFailed;
        }

        setState(() {
          _errorMessage = errorMsg;
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

  Future<void> _pickProofOfAddress() async {
    final XFile? pickedFile = await ImageUploadHelper.pickAndCropImage(
      context,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _proofOfAddressFile = pickedFile;
      });
    }
  }

  Future<void> _takeProofOfAddressPhoto() async {
    final XFile? pickedFile = await ImageUploadHelper.pickAndCropImage(
      context,
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _proofOfAddressFile = pickedFile;
      });
    }
  }

  void _removeProofOfAddress() {
    setState(() {
      _proofOfAddressFile = null;
      _selectedProofType = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createAccount),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    AppLocalizations.of(context)!.joinMasokotips,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(context)!.createAccountToGetStarted,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  ApiErrorWidget(
                    errorMessage: _errorMessage,
                    onRetry: _errorMessage != null ? _register : null,
                  ),

                  // Full Name Field
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fullName,
                      hintText: AppLocalizations.of(context)!.enterFullName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterName;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.username,
                      hintText: '${AppLocalizations.of(context)!.enterUsername} (min 3 chars, spaces allowed)',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterUsername;
                      }
                      if (trimmedValue.length < 3) {
                        return AppLocalizations.of(context)!.usernameTooShort;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      hintText: AppLocalizations.of(context)!.enterEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      final trimmedEmail = value?.trim();
                      if (trimmedEmail == null || trimmedEmail.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterEmail;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(trimmedEmail)) {
                        return AppLocalizations.of(context)!.invalidEmail;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneNumber,
                      hintText: AppLocalizations.of(context)!.enterPhoneNumber,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Location Field
                  TextFormField(
                    controller: _locationController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.location,
                      hintText: AppLocalizations.of(context)!.enterLocation,
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterLocation;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Country Field
                  TextFormField(
                    controller: _countryController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.country,
                      hintText: AppLocalizations.of(context)!.enterCountry,
                      prefixIcon: const Icon(Icons.public_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterCountry;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Agent / Referral Code Field (Optional)
                  TextFormField(
                    controller: _referralCodeController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.agentCodeOptional,
                      hintText: AppLocalizations.of(context)!.agentCodeHint,
                      helperText: AppLocalizations.of(context)!.agentCodeHelper,
                      helperMaxLines: 2,
                      prefixIcon: const Icon(Icons.group_add_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      // Optional field, so no validation needed
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterPassword;
                      }
                      if (value.length < 8) {
                        return AppLocalizations.of(context)!.passwordTooShort;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.confirmPassword,
                      hintText: AppLocalizations.of(context)!.confirmYourPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseConfirmPassword;
                      }
                      if (value != _passwordController.text) {
                        return AppLocalizations.of(context)!.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Role Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          AppLocalizations.of(context)!.registerAs,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _getRoleOptions(context).map((role) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = role['value'];
                                });
                              },
                              child: Card(
                                color: _selectedRole == role['value']
                                    ? theme.colorScheme.primary.withAlpha(25)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: _selectedRole == role['value']
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 8),
                                  child: Column(
                                    children: [
                                      Icon(
                                        role['icon'],
                                        color: _selectedRole == role['value']
                                            ? theme.colorScheme.primary
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        role['label'],
                                        style: TextStyle(
                                          color: _selectedRole == role['value']
                                              ? theme.colorScheme.primary
                                              : Colors.grey.shade800,
                                          fontWeight:
                                              _selectedRole == role['value']
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Proof of Address Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.proofOfIdentity,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.optionalText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.uploadDocumentHint,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Document Type Selection
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProofType.isEmpty
                                ? null
                                : _selectedProofType,
                            hint: Text(AppLocalizations.of(context)!.selectDocumentType),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.document_scanner),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'nida',
                                child: Text(AppLocalizations.of(context)!.nidaCard),
                              ),
                              DropdownMenuItem(
                                value: 'driving_license',
                                child: Text(AppLocalizations.of(context)!.drivingLicense),
                              ),
                              DropdownMenuItem(
                                value: 'voter_card',
                                child: Text(AppLocalizations.of(context)!.voterCard),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedProofType = value ?? '';
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // File Upload / Preview
                          if (_proofOfAddressFile != null)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: kIsWeb
                                        ? Image.network(
                                            _proofOfAddressFile!.path,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_proofOfAddressFile!.path),
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.green, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _proofOfAddressFile!.path
                                                .split('/')
                                                .last,
                                            style: theme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: _removeProofOfAddress,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickProofOfAddress,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withAlpha(100),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        color: theme.colorScheme.primary
                                            .withAlpha(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            size: 32,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            AppLocalizations.of(context)!.gallery,
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: _takeProofOfAddressPhoto,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.teal.withAlpha(150),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        color: Colors.teal.withAlpha(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt_outlined,
                                            size: 32,
                                            color: Colors.teal.shade600,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            AppLocalizations.of(context)!.camera,
                                            style: TextStyle(
                                              color: Colors.teal.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (_proofOfAddressFile == null) ...[
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.uploadTip,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  LoadingButton(
                    isLoading: _isLoading,
                    text: AppLocalizations.of(context)!.createAccountCaps,
                    onPressed: _register,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRoleOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {'value': 'buyer', 'label': localizations.roleBuyer, 'icon': Icons.shopping_cart},
      {'value': 'seller', 'label': localizations.roleSeller, 'icon': Icons.store},
      {
        'value': 'transporter',
        'label': localizations.roleTransporter,
        'icon': Icons.local_shipping
      },
      {
        'value': 'service_provider',
        'label': localizations.roleServiceProvider,
        'icon': Icons.handyman
      },
    ];
  }
}
