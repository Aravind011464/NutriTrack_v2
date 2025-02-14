import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/services/firebase_firestore_service.dart';
import '../core/services/firebase_auth_service.dart';

class UserDetailsViewModel extends ChangeNotifier {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  double height = 0;
  double weight = 0;
  DateTime? dateOfBirth;
  String? bloodGroup;
  String? activityLevel;

  Future<void> saveUserDetails() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    final userDetails = {
      'height': height,
      'weight': weight,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'activityLevel': activityLevel,
    };

    await _firestoreService.saveUserDetails(user.uid, userDetails);
    notifyListeners();
  }

  Future<void> loadUserDetails() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    final userDetails = await _firestoreService.getUserDetails(user.uid);
    if (userDetails != null) {
      height = userDetails['height'] ?? 0;
      weight = userDetails['weight'] ?? 0;
      dateOfBirth = userDetails['dateOfBirth'] != null ? DateTime.parse(userDetails['dateOfBirth']) : null;
      bloodGroup = userDetails['bloodGroup'];
      activityLevel = userDetails['activityLevel'];
      notifyListeners();
    }
  }
}
