import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.subscriptionTier,
    required super.timezone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Usuario sin nombre',
      subscriptionTier: json['subscription_tier'] ?? 'FREE',
      timezone: json['timezone'] ?? 'America/La_Paz',
    );
  }
}
