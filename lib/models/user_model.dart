/// Mirrors the backend User schema exactly.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? university;
  final String? bio;
  final String? avatar;
  final String role;
  final UserPreferences preferences;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.university,
    this.bio,
    this.avatar,
    required this.role,
    required this.preferences,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      university: json['university'],
      bio: json['bio'],
      avatar: json['avatar'],
      role: json['role'] ?? 'student',
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        if (phone != null) 'phone': phone,
        if (university != null) 'university': university,
        if (bio != null) 'bio': bio,
      };
}

class UserPreferences {
  final bool smoking;
  final bool pets;
  final String gender;
  final double budget;

  const UserPreferences({
    this.smoking = false,
    this.pets = false,
    this.gender = 'any',
    this.budget = 0,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      smoking: json['smoking'] ?? false,
      pets: json['pets'] ?? false,
      gender: json['gender'] ?? 'any',
      budget: (json['budget'] ?? 0).toDouble(),
    );
  }
}
