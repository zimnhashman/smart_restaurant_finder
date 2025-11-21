import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static final FacebookAuth _facebookAuth = FacebookAuth.instance;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Cache the last signed-in Google user
  static GoogleSignInAccount? _cachedGoogleUser;

  static Stream<GoogleSignInAuthenticationEvent> get googleAuthEvents =>
      _googleSignIn.authenticationEvents;

  /// Initialize Google Sign-In
  static Future<void> initializeGoogleSignIn({
    String? clientId,
    String? serverClientId,
  }) async {
    try {
      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

      // Listen for sign-in/out events and cache the user
      _googleSignIn.authenticationEvents.listen((event) {
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            _cachedGoogleUser = event.user;
          case GoogleSignInAuthenticationEventSignOut():
            _cachedGoogleUser = null;
        }
      });

      await _googleSignIn.attemptLightweightAuthentication();
    } catch (e, s) {
      _logError('Google initialize error', e, s);
    }
  }

  /// Interactive Google Sign-In
  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.authenticate();
      _cachedGoogleUser = account;
      return account;
    } catch (e, s) {
      _logError('Google Sign-In error', e, s);
      return null;
    }
  }

  /// Get the currently signed-in user (cached)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _cachedGoogleUser;
    if (user != null) {
      return {
        'id': user.id,
        'name': user.displayName?.isNotEmpty == true ? user.displayName! : 'Food Hunter',
        'email': user.email,
        'photoUrl': user.photoUrl,
        'provider': 'google',
      };
    }
    return null;
  }


  /// Facebook Sign-In
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final userData = await _facebookAuth.getUserData(
          fields: "name,email,picture.width(200)",
        );

        return {
          'name': userData['name'] ?? 'User',
          'email': userData['email'],
          'photoUrl': userData['picture']?['data']?['url'],
          'provider': 'facebook',
          'id': userData['id'],
        };
      }
      return null;
    } catch (e, s) {
      _logError('Facebook Sign-In error', e, s);
      return null;
    }
  }

  /// Fake Apple Sign-In
  static Future<Map<String, dynamic>> signInWithApple() async {
    return {
      'name': 'Apple User',
      'email': 'appleuser@example.com',
      'photoUrl': null,
      'provider': 'apple',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  /// Sign out from all providers
  static Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      _cachedGoogleUser = null;
      await _facebookAuth.logOut();
      await _secureStorage.deleteAll();
    } catch (e, s) {
      _logError('Sign-out error', e, s);
    }
  }

  static void _logError(String message, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('$message: $error\n$stackTrace');
    }
  }
}
