import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/services/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  UserModel? user;

  Future<bool> signUp(String email, String password) async {
    final userCredential = await _authService.signUpWithEmail(email, password);
    if (userCredential != null) {
      user = UserModel(uid: userCredential.uid, email: userCredential.email!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    final userCredential = await _authService.signInWithEmail(email, password);
    if (userCredential != null) {
      user = UserModel(uid: userCredential.uid, email: userCredential.email!);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }

  // Call the service's reset password method
  Future<bool> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }
}
