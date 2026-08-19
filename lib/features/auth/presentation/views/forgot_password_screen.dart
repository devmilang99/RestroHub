import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/aesthetic_dialog.dart';
import 'package:restro_hub/core/widgets/loading_dialog.dart';

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
  String _otpErrorMessage = '';

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

    unawaited(_animationController.forward());
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _start = 180;
      _otpErrorMessage = '';
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

    // Simulate automatic OTP reception after 3 seconds
    unawaited(
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _currentStep == 2) {
          const mockOtp = '123456';
          for (var i = 0; i < 6; i++) {
            otpControllers[i].text = mockOtp[i];
          }
          setState(() {
            _otpErrorMessage = 'OTP detected automatically!';
          });
        }
      }),
    );
  }

  @override
  void dispose() {
    identifierController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
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
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AestheticDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = context.colorScheme;
    final primaryColor = colorScheme.primary;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final glassColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: .3,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
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
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Opacity(
              opacity: isDark ? 0.6 : 0.4,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      isDark ? 'assets/food3.webp' : 'assets/food4.webp',
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
                    backgroundColor.withValues(alpha: .1),
                    backgroundColor.withValues(alpha: .5),
                    backgroundColor,
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: MediaQuery.of(context).viewPadding.bottom > 30,
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
                            color: primaryColor,
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
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (_currentStep == 1) ...[
                                    _buildTextField(
                                      context: context,
                                      controller: identifierController,
                                      label: 'Email / Phone',
                                      icon: Icons.person_outline,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildNextButton(
                                      context: context,
                                      onPressed: () async {
                                        if (identifierController
                                            .text
                                            .isNotEmpty) {
                                          LoadingDialog.show(
                                            context,
                                            message: 'Sending OTP...',
                                          );
                                          unawaited(
                                            Future.delayed(
                                              const Duration(seconds: 2),
                                              () {
                                                if (!context.mounted) return;
                                                LoadingDialog.hide(context);
                                                setState(() => _currentStep = 2);
                                                _startTimer();
                                              },
                                            ),
                                          );
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
                                          '6-Digit OTP',
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
                                            color: primaryColor,
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
                                              counterText: '',
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
                                                borderSide: BorderSide(
                                                  color: primaryColor,
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
                                            color: primaryColor,
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
                                                'automatic',
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
                                        onPressed: _startTimer,
                                        child: Text(
                                          'RESEND CODE',
                                          style: GoogleFonts.poppins(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    _buildNextButton(
                                      context: context,
                                      label: 'VERIFY OTP',
                                      onPressed: () async {
                                        final otp = otpControllers
                                            .map((e) => e.text)
                                            .join();
                                        if (otp.length == 6) {
                                          LoadingDialog.show(
                                            context,
                                            message: 'Verifying OTP...',
                                          );
                                          unawaited(
                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () {
                                                if (!context.mounted) return;
                                                LoadingDialog.hide(context);
                                                if (otp == '123456') {
                                                  setState(
                                                    () => _currentStep = 3,
                                                  );
                                                } else {
                                                  setState(
                                                    () => _otpErrorMessage =
                                                        'Invalid OTP pin. Please try again.',
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        } else {
                                          setState(
                                            () => _otpErrorMessage =
                                                'Please enter all 6 digits.',
                                          );
                                        }
                                      },
                                    ),
                                  ] else if (_currentStep == 3) ...[
                                    _buildTextField(
                                      context: context,
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
                                      context: context,
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
                                      context: context,
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
                                          unawaited(
                                            Future.delayed(
                                              const Duration(seconds: 2),
                                              () {
                                                if (!context.mounted) return;
                                                LoadingDialog.hide(context);
                                                _showAestheticDialog(
                                                  isSuccess: true,
                                                  title: 'Success!',
                                                  message:
                                                      'Your password has been updated successfully. Log in with your new password.',
                                                );
                                              },
                                            ),
                                          );
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
      ),
    );
  }

  Widget _buildNextButton({
    required BuildContext context,
    required VoidCallback onPressed,
    String label = 'CONTINUE',
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 12,
          shadowColor: primaryColor.withValues(alpha: .5),
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
