import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/services/auth_service.dart';

class SocialLoginButtons extends StatefulWidget {
  final Function(Map<String, dynamic> userData)? onSuccess;
  final Function(String error)? onError;

  const SocialLoginButtons({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      widget.onSuccess?.call(user);
    }
    setState(() => _loading = false);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final account = await AuthService.signInWithGoogle();
      if (account != null) {
        final userData = {
          'id': account.id,
          'name': account.displayName ?? 'User',
          'email': account.email,
          'photoUrl': account.photoUrl,
          'provider': 'google',
        };
        widget.onSuccess?.call(userData);
      } else {
        widget.onError?.call('Google sign in cancelled');
      }
    } catch (_) {
      widget.onError?.call('Google sign in failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);
    try {
      final userData = await AuthService.signInWithFacebook();
      if (userData != null) {
        widget.onSuccess?.call(userData);
      } else {
        widget.onError?.call('Facebook sign in cancelled');
      }
    } catch (_) {
      widget.onError?.call('Facebook sign in failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      final userData = await AuthService.signInWithApple();
      widget.onSuccess?.call(userData);
    } catch (_) {
      widget.onError?.call('Apple sign in failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Google Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _signInWithGoogle,
            icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
            label: const Text(
              'Continue with Google',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Facebook Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _signInWithFacebook,
            icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
            label: const Text(
              'Continue with Facebook',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Apple Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _signInWithApple,
            icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.white),
            label: const Text(
              'Continue with Apple',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
