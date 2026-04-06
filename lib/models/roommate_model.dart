import 'dart:ui' show Color;
import 'user_model.dart';

class RoommateMatch {
  final UserModel user;
  final int score;
  final String compatibilityLabel;
  final MatchBreakdown breakdown;

  const RoommateMatch({
    required this.user,
    required this.score,
    required this.compatibilityLabel,
    required this.breakdown,
  });

  factory RoommateMatch.fromJson(Map<String, dynamic> json) {
    return RoommateMatch(
      user: UserModel.fromJson({
        '_id': json['user']['id'],
        ...json['user'],
      }),
      score: json['score'] ?? 0,
      compatibilityLabel: json['compatibilityLabel'] ?? '',
      breakdown: MatchBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }

  Color get scoreColor {
    if (score >= 85) return const Color(0xFF00C896);
    if (score >= 70) return const Color(0xFF3068E6);
    if (score >= 55) return const Color(0xFFFFA726);
    return const Color(0xFF8A90A6);
  }
}

class MatchBreakdown {
  final int budget;
  final int gender;
  final int smoking;
  final int pets;
  final int university;

  const MatchBreakdown({
    required this.budget,
    required this.gender,
    required this.smoking,
    required this.pets,
    required this.university,
  });

  factory MatchBreakdown.fromJson(Map<String, dynamic> json) {
    return MatchBreakdown(
      budget: json['budget'] ?? 0,
      gender: json['gender'] ?? 0,
      smoking: json['smoking'] ?? 0,
      pets: json['pets'] ?? 0,
      university: json['university'] ?? 0,
    );
  }
}
