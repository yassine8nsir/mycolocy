import 'user_model.dart';

class HousingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String city;
  final String? address;
  final String? university;
  final int rooms;
  final int bathrooms;
  final double? area;
  final String type;
  final bool furnished;
  final HousingAmenities amenities;
  final List<String> images;
  final UserModel? owner;
  final bool isAvailable;
  final int roommatesNeeded;
  final String genderPreference;
  final DateTime createdAt;

  const HousingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    this.address,
    this.university,
    required this.rooms,
    required this.bathrooms,
    this.area,
    required this.type,
    required this.furnished,
    required this.amenities,
    required this.images,
    this.owner,
    required this.isAvailable,
    required this.roommatesNeeded,
    required this.genderPreference,
    required this.createdAt,
  });

  factory HousingModel.fromJson(Map<String, dynamic> json) {
    return HousingModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      city: json['city'] ?? '',
      address: json['address'],
      university: json['university'],
      rooms: json['rooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      area: json['area'] != null ? (json['area']).toDouble() : null,
      type: json['type'] ?? 'apartment',
      furnished: json['furnished'] ?? false,
      amenities: HousingAmenities.fromJson(json['amenities'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      owner: json['owner'] is Map
          ? UserModel.fromJson(json['owner'])
          : null,
      isAvailable: json['isAvailable'] ?? true,
      roommatesNeeded: json['roommatesNeeded'] ?? 1,
      genderPreference: json['genderPreference'] ?? 'any',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Returns the full image URL given the backend base URL.
  String imageUrl(String baseUrl, int index) {
    if (images.isEmpty) return '';
    final img = images[index];
    if (img.startsWith('http')) return img;
    // Remove /api suffix from baseUrl and append the path
    final base = baseUrl.replaceAll('/api', '');
    return '$base$img';
  }

  String get firstImageUrl {
    if (images.isEmpty) return '';
    return images.first;
  }
}

class HousingAmenities {
  final bool wifi;
  final bool parking;
  final bool airConditioning;
  final bool heating;
  final bool washingMachine;
  final bool elevator;

  const HousingAmenities({
    this.wifi = false,
    this.parking = false,
    this.airConditioning = false,
    this.heating = false,
    this.washingMachine = false,
    this.elevator = false,
  });

  factory HousingAmenities.fromJson(Map<String, dynamic> json) {
    return HousingAmenities(
      wifi: json['wifi'] ?? false,
      parking: json['parking'] ?? false,
      airConditioning: json['airConditioning'] ?? false,
      heating: json['heating'] ?? false,
      washingMachine: json['washingMachine'] ?? false,
      elevator: json['elevator'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'wifi': wifi,
        'parking': parking,
        'airConditioning': airConditioning,
        'heating': heating,
        'washingMachine': washingMachine,
        'elevator': elevator,
      };
}
