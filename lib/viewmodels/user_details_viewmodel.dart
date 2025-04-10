import 'package:flutter/material.dart';
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
  String? gender;

  bool isLoading = false;

  UserDetailsViewModel() {
    loadUserDetails();
  }

  Future<void> saveUserDetails() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    // Ensure no empty values are saved
    if (height == 0 || weight == 0 || dateOfBirth == null || bloodGroup == null || activityLevel == null || gender == null) {
      return;
    }

    final userDetails = {
      'height': height,
      'weight': weight,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'activityLevel': activityLevel,
      'gender': gender,
    };

    try {
      await _firestoreService.saveUserDetails(user.uid, userDetails);
    } catch (e) {
      print("Error saving user details: $e");
    }
    notifyListeners();
  }

  Future<void> loadUserDetails() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final userDetails = await _firestoreService.getUserDetails(user.uid);
      if (userDetails != null) {
        height = (userDetails['height'] ?? 0).toDouble();
        weight = (userDetails['weight'] ?? 0).toDouble();
        dateOfBirth = userDetails['dateOfBirth'] != null ? DateTime.parse(userDetails['dateOfBirth']) : null;
        bloodGroup = userDetails['bloodGroup'];
        activityLevel = userDetails['activityLevel'];
        gender = userDetails['gender'];
      }
    } catch (e) {
      print("Error loading user details: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}