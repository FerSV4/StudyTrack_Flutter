import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String subscriptionTier;
  final String timezone;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.subscriptionTier,
    required this.timezone,
  });

  @override
  List<Object?> get props => [id, email, fullName, subscriptionTier, timezone];
}
