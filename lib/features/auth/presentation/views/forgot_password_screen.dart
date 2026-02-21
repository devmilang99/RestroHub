import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/widgets/loading_dialog.dart';
import 'dart:ui';
import 'dart:async';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  int _currentStep = 1; // 1: Email/Phone, 2: OTP, 3: New Password

  final TextEditingController identifierController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isOtpVisible = true;
  String _otpErrorMessage = "";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _timer;
  int _start = 180;
  bool _canResend = false;

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

    _animationController.forward();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _start = 180;
      _otpErrorMessage = "";
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });

    // Simulate automatic OTP reception (e.g. from SMS/Firebase) after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentStep == 2) {
        final mockOtp = "123456";
        for (int i = 0; i < 6; i++) {
          otpControllers[i].text = mockOtp[i];
        }
        setState(() {
          _otpErrorMessage = "OTP detected automatically!";
        });
      }
    });
  }

  @override
  void dispose() {
    identifierController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showAestheticDialog({
    required bool isSuccess,
    required String title,
    required String message,
    VoidCallback? onConfirmCustom,
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
          if (onConfirmCustom != null) {
            onConfirmCustom();
          } else if (isSuccess && _currentStep == 3) {
            context.goNamed('mainLoginScreen');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    const Color goldColor = Colors.orange;
    final Color blackColor = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color glassColor = isDark
        ? Colors.white.withValues(alpha: .05)
        : Colors.black.withValues(alpha: .05);

    return Scaffold(
      backgroundColor: blackColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.goNamed('mainLoginScreen');
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: isDark ? 0.6 : 0.4,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    isDark
                        ? 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=2070&auto=format&fit=crop'
                        : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=2074&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  blackColor.withValues(alpha: .1),
                  blackColor.withValues(alpha: .5),
                  blackColor,
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
                        _currentStep == 1
                            ? 'Forgot Password'
                            : _currentStep == 2
                            ? 'Verification'
                            : 'New Password',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentStep == 1
                            ? 'Enter your email or phone number to receive an OTP.'
                            : _currentStep == 2
                            ? 'Enter the 6-digit code sent to your registered contact.'
                            : 'Create a new secure password for your account.',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textColor.withValues(alpha: .7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
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
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                if (_currentStep == 1) ...[
                                  _buildTextField(
                                    controller: identifierController,
                                    label: 'Email / Phone',
                                    icon: Icons.person_outline,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildNextButton(
                                    onPressed: () async {
                                      if (identifierController
                                          .text
                                          .isNotEmpty) {
                                        LoadingDialog.show(
                                          context,
                                          message: 'Sending OTP...',
                                        );
                                        await Future.delayed(
                                          const Duration(seconds: 2),
                                        );
                                        if (mounted) {
                                          LoadingDialog.hide(context);
                                          setState(() => _currentStep = 2);
                                          _startTimer();
                                        }
                                      } else {
                                        _showAestheticDialog(
                                          isSuccess: false,
                                          title: 'Empty',
                                          message:
                                              'Please enter email or phone.',
                                        );
                                      }
                                    },
                                  ),
                                ] else if (_currentStep == 2) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "6-Digit OTP",
                                        style: GoogleFonts.poppins(
                                          color: textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isOtpVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: goldColor,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () =>
                                                _isOtpVisible = !_isOtpVisible,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) {
                                      return SizedBox(
                                        width: 45,
                                        child: TextFormField(
                                          controller: otpControllers[index],
                                          focusNode: otpFocusNodes[index],
                                          obscureText: !_isOtpVisible,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          style: GoogleFonts.poppins(
                                            color: textColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            counterText: "",
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: textColor.withValues(
                                                  alpha: 0.2,
                                                ),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: goldColor,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: textColor.withValues(
                                              alpha: 0.05,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (value.length == 1 &&
                                                index < 5) {
                                              otpFocusNodes[index + 1]
                                                  .requestFocus();
                                            }
                                            if (value.isEmpty && index > 0) {
                                              otpFocusNodes[index - 1]
                                                  .requestFocus();
                                            }
                                          },
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Resend code in ',
                                        style: GoogleFonts.poppins(
                                          color: textColor.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}',
                                        style: GoogleFonts.poppins(
                                          color: goldColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_otpErrorMessage.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _otpErrorMessage,
                                      style: GoogleFonts.poppins(
                                        color:
                                            _otpErrorMessage.contains(
                                              "automatic",
                                            )
                                            ? Colors.green
                                            : Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  if (_canResend)
                                    TextButton(
                                      onPressed: () {
                                        _startTimer();
                                      },
                                      child: Text(
                                        'RESEND CODE',
                                        style: GoogleFonts.poppins(
                                          color: goldColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  _buildNextButton(
                                    label: 'VERIFY OTP',
                                    onPressed: () async {
                                      String otp = otpControllers
                                          .map((e) => e.text)
                                          .join();
                                      if (otp.length == 6) {
                                        LoadingDialog.show(
                                          context,
                                          message: 'Verifying OTP...',
                                        );
                                        await Future.delayed(
                                          const Duration(seconds: 1),
                                        );
                                        if (mounted) {
                                          LoadingDialog.hide(context);
                                          if (otp == "123456") {
                                            setState(() => _currentStep = 3);
                                          } else {
                                            setState(
                                              () => _otpErrorMessage =
                                                  "Invalid OTP pin. Please try again.",
                                            );
                                          }
                                        }
                                      } else {
                                        setState(
                                          () => _otpErrorMessage =
                                              "Please enter all 6 digits.",
                                        );
                                      }
                                    },
                                  ),
                                ] else if (_currentStep == 3) ...[
                                  _buildTextField(
                                    controller: newPasswordController,
                                    label: 'New Password',
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    isPassword: true,
                                    isVisible: _isNewPasswordVisible,
                                    onVisibilityToggle: () {
                                      setState(
                                        () => _isNewPasswordVisible =
                                            !_isNewPasswordVisible,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: confirmPasswordController,
                                    label: 'Confirm Password',
                                    icon: Icons.check_circle_outline,
                                    isDark: isDark,
                                    isPassword: true,
                                    isVisible: _isConfirmPasswordVisible,
                                    onVisibilityToggle: () {
                                      setState(
                                        () => _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  _buildNextButton(
                                    label: 'RESET PASSWORD',
                                    onPressed: () async {
                                      if (newPasswordController
                                              .text
                                              .isNotEmpty &&
                                          newPasswordController.text ==
                                              confirmPasswordController.text) {
                                        LoadingDialog.show(
                                          context,
                                          message: 'Resetting password...',
                                        );
                                        await Future.delayed(
                                          const Duration(seconds: 2),
                                        );
                                        if (mounted) {
                                          LoadingDialog.hide(context);
                                          _showAestheticDialog(
                                            isSuccess: true,
                                            title: 'Success!',
                                            message:
                                                'Your password has been updated successfully. Log in with your new password.',
                                          );
                                        }
                                      } else {
                                        _showAestheticDialog(
                                          isSuccess: false,
                                          title: 'Error',
                                          message:
                                              'Passwords do not match or are empty.',
                                        );
                                      }
                                    },
                                  ),
                                ],
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

  Widget _buildNextButton({
    required VoidCallback onPressed,
    String label = 'CONTINUE',
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 12,
          shadowColor: Colors.orange.withValues(alpha: .5),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    final Color textColor = isDark ? Colors.white : Colors.black;

    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: GoogleFonts.poppins(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: textColor.withValues(alpha: .6)),
        prefixIcon: Icon(icon, color: Colors.orange.withValues(alpha: .8)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.orange.withValues(alpha: .8),
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
          borderSide: const BorderSide(color: Colors.orange, width: 2),
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
    _controller.repeat(reverse: true);
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
