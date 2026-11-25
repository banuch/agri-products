import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/theme.dart';
import '../models/app_user.dart';

enum AuthError { wrongLogin, mobileAlreadyUsed, noInternet, unknown }

class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;
}

/// Login with mobile number + 6-digit PIN.
///
/// Internally the mobile number becomes `<number>@agrisociety.app` for
/// Firebase email/password auth, so users never type an email address.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authChanges() => _auth.authStateChanges();

  static String normalizeMobile(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) digits = digits.substring(2);
    if (digits.length == 11 && digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  static bool isValidMobile(String input) =>
      RegExp(r'^[6-9][0-9]{9}$').hasMatch(normalizeMobile(input));

  static bool isValidPin(String pin) => RegExp(r'^[0-9]{6}$').hasMatch(pin);

  static String emailFor(String mobile) =>
      '${normalizeMobile(mobile)}@${AppConfig.authEmailDomain}';

  Future<void> login(String mobile, String pin) async {
    try {
      await _auth.signInWithEmailAndPassword(email: emailFor(mobile), password: pin);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  /// Creates the auth account and the `users/{uid}` profile.
  Future<void> register({
    required String mobile,
    required String pin,
    required AppUser profileWithoutUid,
  }) async {
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
          email: emailFor(mobile), password: pin);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
    final uid = cred.user!.uid;
    final profile = AppUser(
      uid: uid,
      role: profileWithoutUid.role,
      name: profileWithoutUid.name,
      phone: normalizeMobile(mobile),
      pincode: profileWithoutUid.pincode,
      village: profileWithoutUid.village,
      district: profileWithoutUid.district,
      state: profileWithoutUid.state,
      address: profileWithoutUid.address,
    );
    try {
      await _db.collection('users').doc(uid).set(profile.toCreateMap());
    } catch (e) {
      debugPrint('Saving user profile failed: $e');
      // Don't leave a login without a profile behind.
      await cred.user?.delete();
      throw const AuthException(AuthError.unknown);
    }
  }

  Future<void> logout() => _auth.signOut();

  AuthError _map(String code) {
    // Shown in the `flutter run` console to diagnose setup problems, e.g.
    // `operation-not-allowed` = Email/Password sign-in is not enabled.
    debugPrint('FirebaseAuth error: $code');
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return AuthError.wrongLogin;
      case 'email-already-in-use':
        return AuthError.mobileAlreadyUsed;
      case 'network-request-failed':
        return AuthError.noInternet;
      default:
        return AuthError.unknown;
    }
  }
}
