import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/model/User.dart';
import 'package:restro_hub/login/service/google_auth_service.dart';
import 'package:restro_hub/login/service/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return LoginCard();
  }
}

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool visibility = true;
  bool rememberMe = false;
  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  bool _isLoginLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.red, Colors.white],
            ),
          ),
          child: Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                  color: Colors.red,
                ),
              ),

              Center(
                child: Card(
                  elevation: 4,
                  child: SingleChildScrollView(
                    child: Form(
                      key: loginFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            [
                                  const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!value.contains('@')) {
                                        return 'Not a valid email address';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: visibility,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      } else if (value.length > 6) {
                                        return 'Password must be at least 6 characters long';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.lock),
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
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                rememberMe = value!;
                                              });
                                            },
                                          ),
                                          const Text('Remember Me'),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            'forgotPasswordScreen',
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _isLoginLoading
                                            ? null
                                            : () async {
                                                if (loginFormKey.currentState!
                                                    .validate()) {
                                                  setState(
                                                    () =>
                                                        _isLoginLoading = true,
                                                  );
                                                  try {
                                                    final user =
                                                        await _firebaseAuthService
                                                            .signInWithEmailAndPassword(
                                                              emailController
                                                                  .text
                                                                  .trim(),
                                                              passwordController
                                                                  .text,
                                                            );

                                                    if (user != null &&
                                                        mounted) {
                                                      context.goNamed(
                                                        'mainDashBoard',
                                                        extra: User(
                                                          email:
                                                              user.email ?? '',
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
                                        child: _isLoginLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text('Login'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.pushNamed('registerScreen');
                                        },
                                        child: const Text('Register'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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

                                        child: const CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.g_mobiledata,
                                            size: 40,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.person,
                                          size: 10,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.person,
                                          size: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void validationSuccessful() {}
