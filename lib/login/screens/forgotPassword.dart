import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/model/m_ForgotPassword.dart';

enum Validation { empty, notMatch, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Validation validation() {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      return Validation.empty;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      return Validation.notMatch;
    }
    return Validation.success;
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot password")),
      body: SingleChildScrollView(
        child: Column(
          children:
              [
                    TextFormField(
                      controller: oldPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: "Old Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: newPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          switch (validation()) {
                            case Validation.success:
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password changed successfully",
                                  ),
                                ),
                              );
                              M_ForgotPassword(
                                oldPassword: oldPasswordController.text,
                                newPassword: newPasswordController.text,
                                confirmPassword: confirmPasswordController.text,
                              );
                              context.goNamed("mainLoginScreen");
                              break;
                            case Validation.empty:
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter all the fields"),
                                ),
                              );
                              break;
                            case Validation.notMatch:
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Passwords do not match"),
                                ),
                              );
                              break;
                          }
                        },
                        child: const Text("Submit"),
                      ),
                    ),
                  ]
                  .map(
                    (e) => Padding(padding: const EdgeInsets.all(16), child: e),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
