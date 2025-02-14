import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/services/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? user;

  Future<bool> signUp(String email, String password) async {
    final userCredential = await _authService.signUpWithEmail(email, password);
    if (userCredential != null) {
      user = UserModel(uid: userCredential.uid, email: userCredential.email!);

      // Store user data in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user!.uid,
        'email': user!.email,
        'height': null,  // Default placeholders
        'weight': null,
        'dateOfBirth': null,
        'bloodGroup': null,
        'activityLevel': null,
      });

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

  Future<bool> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }
}
