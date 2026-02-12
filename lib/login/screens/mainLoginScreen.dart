import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/model/User.dart';
import 'package:restro_hub/login/service/google_auth_service.dart';
import 'package:restro_hub/login/service/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_fonts/google_fonts.dart';

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const LoginCard();
  }
}

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  bool visibility = true;
  bool rememberMe = false;
  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  bool _isLoginLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
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
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Logo and Title
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RestroHub',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Delicious food, delivered to you',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Login Form Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 32),

                                  // Email Field
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.poppins(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!value.contains('@')) {
                                        return 'Not a valid email address';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: GoogleFonts.poppins(),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.orange.shade400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.orange.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: visibility,
                                    style: GoogleFonts.poppins(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      } else if (value.length < 6) {
                                        return 'Password must be at least 6 characters long';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: GoogleFonts.poppins(),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: Colors.orange.shade400,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            visibility = !visibility;
                                          });
                                        },
                                        icon: Icon(
                                          visibility
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.orange.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Remember Me & Forgot Password
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  rememberMe = value!;
                                                });
                                              },
                                              activeColor:
                                                  Colors.orange.shade400,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remember Me',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            'forgotPasswordScreen',
                                          );
                                        },
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.orange.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  SizedBox(
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoginLoading
                                          ? null
                                          : () async {
                                              if (loginFormKey.currentState!
                                                  .validate()) {
                                                setState(
                                                  () => _isLoginLoading = true,
                                                );
                                                try {
                                                  final user =
                                                      await _firebaseAuthService
                                                          .signInWithEmailAndPassword(
                                                            emailController.text
                                                                .trim(),
                                                            passwordController
                                                                .text,
                                                          );

                                                  if (user != null && mounted) {
                                                    context.goNamed(
                                                      'mainDashBoard',
                                                      extra: User(
                                                        email: user.email ?? '',
                                                        password:
                                                            'FIREBASE_AUTH',
                                                      ),
                                                    );
                                                  }
                                                } on fb.FirebaseAuthException catch (
                                                  e
                                                ) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          e.message ??
                                                              'Login failed',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } finally {
                                                  if (mounted) {
                                                    setState(
                                                      () => _isLoginLoading =
                                                          false,
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade400,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: _isLoginLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Signing in...',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.login,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Login',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Register Button
                                  SizedBox(
                                    height: 54,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        context.pushNamed('registerScreen');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange.shade600,
                                        side: BorderSide(
                                          color: Colors.orange.shade400,
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.person_add,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Create Account',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: GoogleFonts.poppins(
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

                                  const SizedBox(height: 24),

                                  // Social Login
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final fb.User? firebaseUser =
                                              await _googleAuthService.signIn();

                                          if (firebaseUser != null) {
                                            if (mounted) {
                                              context.goNamed(
                                                'mainDashBoard',
                                                extra: User(
                                                  email:
                                                      firebaseUser.email ?? '',
                                                  password: 'GOOGLE_AUTH_USER',
                                                ),
                                              );
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Google Sign-In failed or cancelled.',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                'https://www.google.com/favicon.ico',
                                                width: 24,
                                                height: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Continue with Google',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
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

                        const SizedBox(height: 24),

                        // Help and Contact Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Navigate to help screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Help section coming soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white70,
                                size: 20,
                              ),
                              label: Text(
                                'Help',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 20,
                              width: 1,
                              color: Colors.white30,
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Navigate to contact screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Contact support: support@restrohub.com',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.contact_support_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              label: Text(
                                'Contact Us',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
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
}
