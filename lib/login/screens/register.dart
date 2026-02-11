import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/model/m_Register.dart';
import 'package:restro_hub/login/service/firebase_auth_service.dart';
import 'package:restro_hub/login/service/registration_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          onPressed: () {
            context.goNamed('mainLoginScreen');
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: RegistrationValidator.validateEmail,
                        ),
                        TextFormField(
                          controller: fullNameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: RegistrationValidator.validateFullName,
                        ),
                        TextFormField(
                          controller: addressController,
                          keyboardType: TextInputType.streetAddress,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: RegistrationValidator.validateAddress,
                        ),
                        TextFormField(
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            prefixText: "+977 ",
                          ),
                          validator: RegistrationValidator.validatePhone,
                        ),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: RegistrationValidator.validatePassword,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      try {
                                        final fb.User? user = await _authService
                                            .signUpWithEmailAndPassword(
                                              emailController.text.trim(),
                                              passwordController.text,
                                            );

                                        if (user != null) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Registration Successful!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            context.goNamed('mainLoginScreen');
                                          }
                                        }
                                      } on fb.FirebaseAuthException catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                e.message ?? 'Signup failed',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    }
                                  },
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Register'),
                          ),
                        ),
                      ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: e,
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

void sendData(ModelRegister modelRegister) {
  debugPrint(modelRegister.email);
  debugPrint(modelRegister.fullName);
  debugPrint(modelRegister.address);
  debugPrint(modelRegister.phoneNumber);
  debugPrint(modelRegister.password);
}
