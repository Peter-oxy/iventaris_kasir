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

  Future<bool> register(String email, String pass) => _run(
    () => _auth.createUserWithEmailAndPassword(email: email, password: pass),
  );

  Future<bool> login(String email, String pass) => _run(
    () => _auth.signInWithEmailAndPassword(email: email, password: pass),
  );

  Future<void> logout() => _auth.signOut();

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      error = _pesanAuth(e.code);
      return false;
    } catch (_) {
      error = 'Terjadi kesalahan. Silakan coba lagi.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Terjemahan kode error Firebase Auth ke bahasa Indonesia
  String _pesanAuth(String code) {
    switch (code) {
      // Login: Firebase terbaru menggabungkan "email tidak ada" dan "password salah"
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-login-credentials':
        return 'Email atau password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
      // Register
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'operation-not-allowed':
        return 'Login Email/Password belum diaktifkan di Firebase.';
      // Jaringan
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return 'Terjadi kesalahan ($code). Silakan coba lagi.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel(); // wajib dispose subscription
    super.dispose();
  }
}
