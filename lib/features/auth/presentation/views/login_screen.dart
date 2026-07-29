import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/widgets/loading_dialog.dart';
import 'package:restro_hub/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class MainLoginScreen extends ConsumerStatefulWidget {
  const MainLoginScreen({super.key});

  @override
  ConsumerState<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends ConsumerState<MainLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const LoginCard();
  }
}

class LoginCard extends ConsumerStatefulWidget {
  const LoginCard({super.key});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard>
    with SingleTickerProviderStateMixin {
  bool visibility = true;
  bool rememberMe = false;
  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _getBackgroundImageUrl() {
    if (kIsWeb) {
      return 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=1600&q=80';
    } else {
      return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80';
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    unawaited(_animationController.forward());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = context.colorScheme;
    final primaryColor = colorScheme.primary;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(_getBackgroundImageUrl()),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                ref
                                    .read(themeProvider.notifier)
                                    .toggleTheme(isDark: !isDark);
                              },
                              icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Restro Hub',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Form(
                          key: loginFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildTextField(
                                controller: emailController,
                                hint: 'Email Address',
                                icon: Icons.email_outlined,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: passwordController,
                                hint: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        onChanged: (v) {
                                          setState(() => rememberMe = v!);
                                        },
                                        activeColor: primaryColor,
                                      ),
                                      const Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.pushNamed('forgotPasswordScreen');
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => unawaited(_handleLogin(ref)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          unawaited(_handleGoogleLogin(ref)),
                                      icon: const Icon(
                                        Icons.login,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'GOOGLE',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        side: const BorderSide(
                                          color: Colors.white24,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account? ",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.pushNamed('registerScreen');
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && visibility,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    visibility ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                  ),
                  onPressed: () => setState(() => visibility = !visibility),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Future<void> _handleLogin(WidgetRef ref) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ref
          .read(errorServiceProvider.notifier)
          .showError(
            message: 'Please fill in all fields',
            type: ErrorType.auth,
          );
      return;
    }

    LoadingDialog.show(context, message: 'Logging in...');
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email, password);

      if (mounted) {
        LoadingDialog.hide(context);
        if (user != null) {
          context.goNamed('mainDashBoard');
        }
      }
    } on sb.AuthException catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ref
            .read(errorServiceProvider.notifier)
            .showError(message: e.message, type: ErrorType.auth);
      }
    } on Object catch (_) {
      if (mounted) {
        LoadingDialog.hide(context);
        ref
            .read(errorServiceProvider.notifier)
            .showError(
              message: 'An unexpected error occurred',
            );
      }
    }
  }

  Future<void> _handleGoogleLogin(WidgetRef ref) async {
    LoadingDialog.show(context, message: 'Signing in with Google...');
    try {
      final user = await _googleAuthService.signIn();
      if (mounted) {
        LoadingDialog.hide(context);
        if (user != null) {
          context.goNamed('mainDashBoard', extra: user);
        }
      }
    } on sb.AuthException catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ref
            .read(errorServiceProvider.notifier)
            .showError(message: e.message, type: ErrorType.auth);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        var message = 'Google Sign-In failed';
        if (e.code == 'network_error' || e.message?.contains('7') == true) {
          message =
              'Network error or configuration mismatch (SHA-1). Please check your connection and app setup.';
        }
        ref
            .read(errorServiceProvider.notifier)
            .showError(message: message, type: ErrorType.auth);
      }
    } on Object catch (_) {
      if (mounted) {
        LoadingDialog.hide(context);
        ref
            .read(errorServiceProvider.notifier)
            .showError(message: 'Google Sign-In failed', type: ErrorType.auth);
      }
    }
  }
}
