import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restro_hub/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleLoginDemo extends StatefulWidget {
  const GoogleLoginDemo({super.key});

  @override
  State<GoogleLoginDemo> createState() => _GoogleLoginDemoState();
}

class _GoogleLoginDemoState extends State<GoogleLoginDemo> {
  final GoogleAuthService _authService = GoogleAuthService();
  User? _user;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkExistingSession());
  }

  Future<void> _checkExistingSession() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInSilently();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signIn();

    setState(() {
      _user = user;
      _error = (user == null) ? 'Sign-in failed' : null;
      _isLoading = false;
    });
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    await _authService.signOut();
    setState(() {
      _user = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Login')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _user != null
            ? _buildUserInfo()
            : _buildSignInButton(),
      ),
    );
  }

  Widget _buildUserInfo() {
    final avatarUrl = _user!.userMetadata?['avatar_url'] as String?;
    final fullName = _user!.userMetadata?['full_name'] as String?;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (avatarUrl != null)
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        const SizedBox(height: 16),
        Text(
          'Welcome, ${fullName ?? 'User'}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(_user!.email ?? 'No email'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleSignOut,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ElevatedButton.icon(
          onPressed: _handleSignIn,
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
        ),
      ],
    );
  }
}
