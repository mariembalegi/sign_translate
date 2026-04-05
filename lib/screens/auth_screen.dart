import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _handleAuth(AuthProvider authProvider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      SnackBarHelper.showError(context, 'Please fill in all fields');
      return;
    }
    
    if (!_isLogin && _passwordController.text != _confirmPasswordController.text) {
      SnackBarHelper.showError(context, 'Passwords do not match');
      return;
    }
    
    bool success;
    if (_isLogin) {
      success = await authProvider.signInWithEmail(email, password);
    } else {
      success = await authProvider.signUpWithEmail(email, password);
    }
    
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      SnackBarHelper.showError(context, authProvider.errorMessage ?? 'Authentication failed');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            message: _isLogin ? 'Signing in...' : 'Creating account...',
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    
                    // Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.waving_hand_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Title
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: AppText.heading1,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    Text(
                      _isLogin
                          ? 'Sign in to continue translating'
                          : 'Join us to start translating sign language',
                      style: AppText.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Email Input
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Password Input
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                    ),
                    
                    if (!_isLogin) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outlined,
                        obscureText: true,
                      ),
                    ],
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Main Button
                    GradientButton(
                      label: _isLogin ? 'Sign In' : 'Create Account',
                      onPressed: () => _handleAuth(authProvider),
                      isLoading: authProvider.isLoading,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'OR',
                            style: AppText.bodySmall,
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Google Sign In
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => authProvider.signInWithGoogle(),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/google_logo.png',
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.login,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text('Sign in with Google'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Toggle Auth Mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : 'Already have an account? ',
                          style: AppText.body,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isLogin = !_isLogin);
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          },
                          child: Text(
                            _isLogin ? 'Sign up' : 'Sign in',
                            style: AppText.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
