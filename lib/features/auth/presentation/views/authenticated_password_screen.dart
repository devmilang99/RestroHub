import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/loading_dialog.dart';

class AuthenticatedPasswordScreen extends ConsumerStatefulWidget {
  const AuthenticatedPasswordScreen({super.key});

  @override
  ConsumerState<AuthenticatedPasswordScreen> createState() =>
      _AuthenticatedPasswordScreenState();
}

class _AuthenticatedPasswordScreenState
    extends ConsumerState<AuthenticatedPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    unawaited(_animationController.forward());
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAestheticDialog({
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _AestheticDialog(
          isSuccess: isSuccess,
          title: title,
          message: message,
          onConfirm: () {
            Navigator.pop(context);
            if (isSuccess) {
              context.pop(); // Go back to original screen
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final primaryColor = colorScheme.primary;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final glassColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: .3,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Background Image
          Opacity(
            opacity: Theme.of(context).brightness == Brightness.dark
                ? 0.3
                : 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1517248135467-4c7ed9d42c77?q=80&w=2070&auto=format&fit=crop',
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Change Password',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep your account secure by updating your password regularly.',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textColor.withValues(alpha: .7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Glassmorphic Form
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: glassColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: textColor.withValues(alpha: .1),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildTextField(
                                  context: context,
                                  controller: currentPasswordController,
                                  label: 'Current Password',
                                  icon: Icons.lock_outline,
                                  isDark:
                                      Theme.of(context).brightness ==
                                      Brightness.dark,
                                  isPassword: true,
                                  isVisible: _isCurrentPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isCurrentPasswordVisible =
                                          !_isCurrentPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  context: context,
                                  controller: newPasswordController,
                                  label: 'New Password',
                                  icon: Icons.vpn_key_outlined,
                                  isDark:
                                      Theme.of(context).brightness ==
                                      Brightness.dark,
                                  isPassword: true,
                                  isVisible: _isNewPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isNewPasswordVisible =
                                          !_isNewPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  context: context,
                                  controller: confirmPasswordController,
                                  label: 'Confirm New Password',
                                  icon: Icons.check_circle_outline,
                                  isDark:
                                      Theme.of(context).brightness ==
                                      Brightness.dark,
                                  isPassword: true,
                                  isVisible: _isConfirmPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 40),
                                SizedBox(
                                  width: double.infinity,
                                  height: 64,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (currentPasswordController
                                              .text
                                              .isEmpty ||
                                          newPasswordController.text.isEmpty ||
                                          confirmPasswordController
                                              .text
                                              .isEmpty) {
                                        _showAestheticDialog(
                                          isSuccess: false,
                                          title: 'Incomplete',
                                          message: 'Please fill in all fields.',
                                        );
                                      } else if (newPasswordController.text !=
                                          confirmPasswordController.text) {
                                        _showAestheticDialog(
                                          isSuccess: false,
                                          title: 'Mismatch',
                                          message:
                                              'New passwords do not match.',
                                        );
                                      } else {
                                        LoadingDialog.show(
                                          context,
                                          message: 'Updating password...',
                                        );
                                        await Future<void>.delayed(
                                          const Duration(seconds: 2),
                                        );
                                        if (!context.mounted) return;
                                        LoadingDialog.hide(context);
                                        _showAestheticDialog(
                                          isSuccess: true,
                                          title: 'Success!',
                                          message:
                                              'Your password has been changed successfully.',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      elevation: 12,
                                    ),
                                    child: Text(
                                      'CHANGE PASSWORD',
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
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    final textColor = isDark ? Colors.white : Colors.black;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: GoogleFonts.poppins(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: textColor.withValues(alpha: .6)),
        prefixIcon: Icon(icon, color: primaryColor.withValues(alpha: .8)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor.withValues(alpha: .8),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: textColor.withValues(alpha: .1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: textColor.withValues(alpha: 0.05),
      ),
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
    unawaited(_controller.forward());
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
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: .9),
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
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .7),
                ),
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
    unawaited(_controller.repeat(reverse: true));
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
        final glowSize = 10 + (15 * _animation.value);
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
        );
      },
    );
  }
}
