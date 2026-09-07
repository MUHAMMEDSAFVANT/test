import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository this._repository}) {
    _repository.authStateChanges.listen(_onAuthStateChanged);
  } 

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signInWithGoogle();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _friendlyError(e);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('cancelled')) return 'Sign-in was cancelled.';
    if (msg.contains('network')) return 'No internet connection.';
    return 'Sign-in failed. Please try again.';
  }
}
