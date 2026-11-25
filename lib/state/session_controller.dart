import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';

enum SessionStatus { loading, signedOut, signedIn }

/// Tracks the logged-in Firebase user and their `users/{uid}` profile.
class SessionController extends ChangeNotifier {
  SessionController(this._auth, this._data) {
    _authSub = _auth.authChanges().listen(_onAuth);
  }

  /// A session already signed in as [user], without listening to Firebase.
  /// Used by widget tests.
  @visibleForTesting
  SessionController.fixed(this._auth, this._data, AppUser user)
      : _status = SessionStatus.signedIn,
        _user = user;

  final AuthService _auth;
  final DataService _data;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  SessionStatus _status = SessionStatus.loading;
  AppUser? _user;

  SessionStatus get status => _status;
  AppUser? get user => _user;

  void _onAuth(User? fbUser) {
    _profileSub?.cancel();
    if (fbUser == null) {
      _user = null;
      _status = SessionStatus.signedOut;
      notifyListeners();
      return;
    }
    _status = SessionStatus.loading;
    notifyListeners();
    _profileSub = _data.watchUser(fbUser.uid).listen((profile) {
      // A brand-new account has no profile for a moment while registering.
      if (profile == null) return;
      _user = profile;
      _status = SessionStatus.signedIn;
      notifyListeners();
    }, onError: (_) {
      _status = SessionStatus.signedOut;
      notifyListeners();
    });
  }

  Future<void> logout() => _auth.logout();

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
