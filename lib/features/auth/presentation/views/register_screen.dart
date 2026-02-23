import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/auth/data/models/register_model.dart';
import 'package:restro_hub/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:restro_hub/features/auth/utils/registration_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/widgets/loading_dialog.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _formFadeAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeIn,
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _formAnimationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  void _showAestheticDialog({
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AestheticDialog(
        isSuccess: isSuccess,
        title: title,
        message: message,
        onConfirm: () {
          Navigator.pop(context);
          if (isSuccess) {
            context.goNamed('mainLoginScreen');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colorScheme = context.colorScheme;
    final primaryColor = colorScheme.primary;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final Color glassColor = colorScheme.surfaceContainerHighest.withOpacity(
      .3,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.goNamed('mainLoginScreen'),
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
      ),
      body: Stack(
        children: [
          // Background Image with dynamic opacity
          Opacity(
            opacity: isDark ? 0.6 : 0.4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1550966841-3ee32281831c?q=80&w=2070&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor.withValues(alpha: .1),
                  backgroundColor.withValues(alpha: .5),
                  backgroundColor,
                ],
              ),
            ),
          ),
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _formFadeAnimation,
                child: SlideTransition(
                  position: _formSlideAnimation,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Join Us',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We are delighted to have you join our premium dining community.',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: textColor.withValues(alpha: .7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Form Container with Glassmorphism
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: glassColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: textColor.withValues(alpha: .1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    context: context,
                                    controller: fullNameController,
                                    label: 'Full Name',
                                    icon: Icons.person_outline,
                                    isDark: themeMode == ThemeMode.dark,
                                    validator:
                                        RegistrationValidator.validateFullName,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    context: context,
                                    controller: emailController,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    isDark: themeMode == ThemeMode.dark,
                                    keyboardType: TextInputType.emailAddress,
                                    validator:
                                        RegistrationValidator.validateEmail,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    context: context,
                                    controller: addressController,
                                    label: 'Address',
                                    icon: Icons.location_on_outlined,
                                    isDark: themeMode == ThemeMode.dark,
                                    validator:
                                        RegistrationValidator.validateAddress,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    context: context,
                                    controller: phoneNumberController,
                                    label: 'Phone Number',
                                    icon: Icons.phone_outlined,
                                    isDark: themeMode == ThemeMode.dark,
                                    keyboardType: TextInputType.phone,
                                    prefixText: "+977 ",
                                    validator:
                                        RegistrationValidator.validatePhone,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    context: context,
                                    controller: passwordController,
                                    label: 'Password',
                                    isDark: themeMode == ThemeMode.dark,
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    validator:
                                        RegistrationValidator.validatePassword,
                                  ),
                                  const SizedBox(height: 40),
                                  // Register Button Logic
                                  SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          LoadingDialog.show(
                                            context,
                                            message: 'Creating your account...',
                                          );
                                          try {
                                            final fb.User? user =
                                                await _authService
                                                    .signUpWithEmailAndPassword(
                                                      emailController.text
                                                          .trim(),
                                                      passwordController.text,
                                                    );

                                            if (user != null) {
                                              if (mounted) {
                                                LoadingDialog.hide(context);
                                                _showAestheticDialog(
                                                  isSuccess: true,
                                                  title: 'Welcome!',
                                                  message:
                                                      'Your culinary journey begins now. We\'re so happy to have you!',
                                                );
                                              }
                                            }
                                          } on fb.FirebaseAuthException catch (
                                            e
                                          ) {
                                            if (mounted) {
                                              LoadingDialog.hide(context);
                                              _showAestheticDialog(
                                                isSuccess: false,
                                                title: 'Oops!',
                                                message:
                                                    e.message ??
                                                    'Something went wrong with your registration. Please try again.',
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              LoadingDialog.hide(context);
                                            }
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        elevation: 12,
                                        shadowColor: primaryColor.withValues(
                                          alpha: .5,
                                        ),
                                      ),
                                      child: Text(
                                        'CREATE ACCOUNT',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
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
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    final Color textColor = isDark ? Colors.white : Colors.black;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: textColor.withValues(alpha: .6)),
        prefixIcon: Icon(icon, color: primaryColor.withValues(alpha: .8)),
        prefixText: prefixText,
        prefixStyle: GoogleFonts.poppins(color: textColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: textColor.withValues(alpha: .1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: textColor.withValues(alpha: .05),
      ),
      validator: validator,
    );
  }
}

class _AestheticDialog extends StatefulWidget {
  final bool isSuccess;
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const _AestheticDialog({
    required this.isSuccess,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  State<_AestheticDialog> createState() => _AestheticDialogState();
}

class _AestheticDialogState extends State<_AestheticDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: .9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedStatusIcon(isSuccess: widget.isSuccess),
              const SizedBox(height: 24),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isSuccess
                        ? Colors.green
                        : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'CONTINUE',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatusIcon extends StatefulWidget {
  final bool isSuccess;
  const _AnimatedStatusIcon({required this.isSuccess});

  @override
  State<_AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceOut);
    _controller.repeat(reverse: true); // Make it pulse
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double glowSize = 10 + (15 * _animation.value);
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: widget.isSuccess
                ? Colors.green.withValues(alpha: .1)
                : Colors.red.withValues(alpha: .1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (widget.isSuccess ? Colors.green : Colors.red)
                    .withValues(alpha: .2 * _animation.value),
                blurRadius: glowSize,
                spreadRadius: glowSize / 2,
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: widget.isSuccess ? (1 - _animation.value) * 0.2 : 0,
              child: ScaleTransition(
                scale: _animation,
                child: Icon(
                  widget.isSuccess
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                  size: 64,
                  color: widget.isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void sendData(RegisterModel registerModel) {
  debugPrint(registerModel.email);
  debugPrint(registerModel.fullName);
  debugPrint(registerModel.address);
  debugPrint(registerModel.phoneNumber);
  debugPrint(registerModel.password);
}
