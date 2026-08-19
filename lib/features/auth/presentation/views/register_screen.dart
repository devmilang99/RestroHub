import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/widgets/aesthetic_dialog.dart';
import 'package:restro_hub/core/widgets/loading_dialog.dart';
import 'package:restro_hub/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:restro_hub/features/auth/data/models/register_model.dart';
import 'package:restro_hub/features/auth/utils/registration_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SupabaseAuthService _authService = SupabaseAuthService();

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

    unawaited(_formAnimationController.forward());
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
            if (isSuccess) {
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
          onPressed: () => context.goNamed('mainLoginScreen'),
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/food7.webp'),
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
                  opacity: _formFadeAnimation,
                  child: SlideTransition(
                    position: _formSlideAnimation,
                    child: Form(
                      key: _formKey,
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
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      context: context,
                                      controller: fullNameController,
                                      label: 'Full Name',
                                      icon: Icons.person_outline,
                                      isDark: isDark,
                                      validator: RegistrationValidator
                                          .validateFullName,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      context: context,
                                      controller: emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      isDark: isDark,
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
                                      isDark: isDark,
                                      validator:
                                          RegistrationValidator.validateAddress,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      context: context,
                                      controller: phoneNumberController,
                                      label: 'Phone Number',
                                      icon: Icons.phone_outlined,
                                      isDark: isDark,
                                      keyboardType: TextInputType.phone,
                                      prefixText: '+977 ',
                                      validator:
                                          RegistrationValidator.validatePhone,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      context: context,
                                      controller: passwordController,
                                      label: 'Password',
                                      isDark: isDark,
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: RegistrationValidator
                                          .validatePassword,
                                    ),
                                    const SizedBox(height: 40),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            LoadingDialog.show(
                                              context,
                                              message:
                                                  'Creating your account...',
                                            );
                                            try {
                                              final user = await _authService
                                                  .signUpWithEmailAndPassword(
                                                    emailController.text.trim(),
                                                    passwordController.text,
                                                  );

                                              if (!context.mounted) return;
                                              if (user != null) {
                                                LoadingDialog.hide(context);
                                                _showAestheticDialog(
                                                  isSuccess: true,
                                                  title: 'Welcome!',
                                                  message:
                                                      "Your culinary journey begins now. We're so happy to have you!",
                                                );
                                              }
                                            } on sb.AuthException catch (e) {
                                              if (!context.mounted) return;
                                              LoadingDialog.hide(context);
                                              ref
                                                  .read(
                                                    errorServiceProvider
                                                        .notifier,
                                                  )
                                                  .handleException(e);
                                            } on Exception catch (e) {
                                              if (!context.mounted) return;
                                              LoadingDialog.hide(context);
                                              ref
                                                  .read(
                                                    errorServiceProvider
                                                        .notifier,
                                                  )
                                                  .handleException(e);
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor:
                                              colorScheme.onPrimary,
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
    final textColor = isDark ? Colors.white : Colors.black;
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
          borderSide: const BorderSide(color: Colors.redAccent),
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

void sendData(RegisterModel registerModel) {
  debugPrint(registerModel.email);
  debugPrint(registerModel.fullName);
  debugPrint(registerModel.address);
  debugPrint(registerModel.phoneNumber);
  debugPrint(registerModel.password);
}
