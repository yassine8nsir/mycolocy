import 'housing_model.dart';

class RecommendationModel {
  final HousingModel housing;
  final int score;
  final List<String> reasons;
  final RecommendationBreakdown breakdown;

  const RecommendationModel({
    required this.housing,
    required this.score,
    required this.reasons,
    required this.breakdown,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      housing: HousingModel.fromJson(json['housing']),
      score: json['score'] ?? 0,
      reasons: List<String>.from(json['reasons'] ?? []),
      breakdown: RecommendationBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }
}

class RecommendationBreakdown {
  final int budget;
  final int university;
  final int gender;
  final int recency;
  final int furnished;

  const RecommendationBreakdown({
    required this.budget,
    required this.university,
    required this.gender,
    required this.recency,
    required this.furnished,
  });

  factory RecommendationBreakdown.fromJson(Map<String, dynamic> json) {
    return RecommendationBreakdown(
      budget: json['budget'] ?? 0,
      university: json['university'] ?? 0,
      gender: json['gender'] ?? 0,
      recency: json['recency'] ?? 0,
      furnished: json['furnished'] ?? 0,
    );
  }
}
