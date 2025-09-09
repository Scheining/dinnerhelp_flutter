import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:homechef/services/biometric_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _biometricAvailable = false;
  bool _hasSavedCredentials = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricAvailable = await BiometricService.instance.isBiometricAvailable();
    final biometricEnabled = await BiometricService.instance.isBiometricLoginEnabled();
    final hasSavedCredentials = await BiometricService.instance.getSavedCredentials() != null;
    
    if (mounted) {
      setState(() {
        _biometricAvailable = biometricAvailable;
        _hasSavedCredentials = biometricEnabled && hasSavedCredentials;
      });
      
      // Auto-prompt for biometric login if available
      if (_hasSavedCredentials && biometricAvailable) {
        _signInWithBiometric();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthStateAuthenticated) {
        // Add a small delay to ensure auth state is propagated
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            context.go('/');
          }
        });
      } else if (next is AuthStateError) {
        setState(() {
          _errorMessage = next.message;
          _isLoading = false;
        });
      } else if (next is AuthStateLoading) {
        setState(() {
          _isLoading = true;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                
                // Logo and Welcome Text
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              theme.brightness == Brightness.dark
                                  ? 'assets/images/round_logo_dark_500x500.png'
                                  : 'assets/images/round_logo_500x500.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Velkommen tilbage',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log ind for at fortsætte',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'din@email.dk',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast venligst din email';
                    }
                    if (!value.contains('@')) {
                      return 'Indtast en gyldig email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: 'Adgangskode',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast venligst din adgangskode';
                    }
                    if (value.length < 6) {
                      return 'Adgangskoden skal være mindst 6 tegn';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      'Glemt adgangskode?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sign In Button
                CustomButton(
                  text: _isLoading ? 'Logger ind...' : 'Log ind',
                  onPressed: _isLoading ? null : _signIn,
                  width: double.infinity,
                  icon: _isLoading ? null : Icons.login,
                ),
                
                const SizedBox(height: 16),
                
                // Biometric Login Button
                if (_biometricAvailable && _hasSavedCredentials)
                  Column(
                    children: [
                      OutlinedButton(
                        onPressed: _isLoading ? null : _signInWithBiometric,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            FutureBuilder<String>(
                              future: BiometricService.instance.getAvailableBiometricString(),
                              builder: (context, snapshot) {
                                final biometricType = snapshot.data ?? 'Biometrisk';
                                return Text(
                                  'Log ind med $biometricType',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ELLER',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Social Sign In Buttons
                _buildSocialButton(
                  context,
                  'Fortsæt med Google',
                  'assets/images/google_logo.png',
                  _signInWithGoogle,
                ),
                
                const SizedBox(height: 12),
                
                _buildSocialButton(
                  context,
                  'Fortsæt med Apple',
                  'assets/images/apple_logo.png',
                  _signInWithApple,
                  isDark: true,
                ),
                
                const SizedBox(height: 32),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Har du ikke en konto? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/auth/signup');
                      },
                      child: Text(
                        'Opret konto',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String text,
    String iconPath,
    VoidCallback onPressed, {
    bool isDark = false,
  }) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: isDark ? Colors.black : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use Icon instead of image asset for now
          Icon(
            isDark ? Icons.apple : Icons.g_mobiledata,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    await ref.read(authNotifierProvider.notifier).signIn(
      email: email,
      password: password,
    );
    
    // Save credentials for biometric login if successful
    final authState = ref.read(authNotifierProvider);
    if (authState is AuthStateAuthenticated && _biometricAvailable) {
      final shouldEnableBiometric = await _askToEnableBiometric();
      if (shouldEnableBiometric) {
        await BiometricService.instance.setBiometricLoginEnabled(true);
        await BiometricService.instance.saveCredentials(email, password);
      }
    }
  }
  
  Future<bool> _askToEnableBiometric() async {
    final biometricType = await BiometricService.instance.getAvailableBiometricString();
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aktiver $biometricType login'),
        content: Text(
          'Vil du bruge $biometricType til at logge ind hurtigere næste gang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nej tak'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ja, aktiver'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Future<void> _signInWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await BiometricService.instance.authenticateAndLogin();
      
      if (success) {
        // Auth state will be handled by the listener
        debugPrint('Biometric login successful');
      } else {
        setState(() {
          _errorMessage = 'Biometrisk login mislykkedes. Prøv igen eller brug din adgangskode.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Der opstod en fejl. Prøv igen.';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    await ref.read(authNotifierProvider.notifier).signInWithApple();
  }

  Future<void> _forgotPassword() async {
    // TODO: Navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Glemt adgangskode funktionen kommer snart')),
    );
  }
}