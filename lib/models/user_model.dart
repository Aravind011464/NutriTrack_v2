class UserModel {
  final String uid;
  final String email;
  double? height;
  double? weight;
  DateTime? dateOfBirth;
  String? bloodGroup;
  String? activityLevel;
  String? gender;

  UserModel({
    required this.uid,
    required this.email,
    this.height,
    this.weight,
    this.dateOfBirth,
    this.bloodGroup,
    this.activityLevel,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'height': height,
      'weight': weight,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'activityLevel': activityLevel,
      'gender': gender,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['uid'],
        email: json['email'],
        height: json['height']?.toDouble(),
        weight: json['weight']?.toDouble(),
        dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
        bloodGroup: json['bloodGroup'],
        activityLevel: json['activityLevel'],
        gender: json['gender']
    );
  }
}