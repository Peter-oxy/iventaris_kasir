import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;

  User? user;
  bool busy = false;
  String? error;
  bool initialized = false;

  AuthProvider() {
    // STREAM<User?> auth state listener
    _sub = _auth.authStateChanges().listen((u) {
      user = u;
      initialized = true;
      notifyListeners();
    });
  }

  Future<bool> register(String email, String pass) =>
      _run(() => _auth.createUserWithEmailAndPassword(email: email, password: pass));

  Future<bool> login(String email, String pass) =>
      _run(() => _auth.signInWithEmailAndPassword(email: email, password: pass));

  Future<void> logout() => _auth.signOut();

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Terjadi kesalahan auth';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel(); // wajib dispose subscription
    super.dispose();
  }
}