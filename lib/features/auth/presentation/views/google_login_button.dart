import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:restro_hub/features/auth/data/datasources/google_auth_datasource.dart';


class GoogleLoginDemo extends StatefulWidget {
  const GoogleLoginDemo({super.key});

  @override
  State<GoogleLoginDemo> createState() => _GoogleLoginDemoState();
}

class _GoogleLoginDemoState extends State<GoogleLoginDemo> {
  final GoogleAuthService _authService = GoogleAuthService();
  fb.User? _user;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_user!.photoURL != null)
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(_user!.photoURL!),
          ),
        const SizedBox(height: 16),
        Text(
          'Welcome, ${_user!.displayName ?? 'User'}',
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
            padding: const EdgeInsets.all(8.0),
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
