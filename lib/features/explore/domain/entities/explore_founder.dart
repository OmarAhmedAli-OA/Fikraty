import 'package:equatable/equatable.dart';

class ExploreFounder extends Equatable {
  const ExploreFounder({
    required this.id,
    required this.name,
    required this.role,
    required this.startupName,
    required this.avatarUrl,
    required this.location,
    required this.skills,
    required this.followers,
    required this.isVerified,
    required this.bio,
    required this.lookingFor,
    this.isSaved = false,
    this.isInterestSent = false,
    this.isFollowing = false,
  });

  final int id;
  final String name;
  final String role;
  final String startupName;
  final String avatarUrl;
  final String location;
  final List<String> skills;
  final int followers;
  final bool isVerified;
  final String bio;
  final String lookingFor;
  final bool isSaved;
  final bool isInterestSent;
  final bool isFollowing;

  ExploreFounder copyWith({
    int? id,
    String? name,
    String? role,
    String? startupName,
    String? avatarUrl,
    String? location,
    List<String>? skills,
    int? followers,
    bool? isVerified,
    String? bio,
    String? lookingFor,
    bool? isSaved,
    bool? isInterestSent,
    bool? isFollowing,
  }) {
    return ExploreFounder(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      startupName: startupName ?? this.startupName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      followers: followers ?? this.followers,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      lookingFor: lookingFor ?? this.lookingFor,
      isSaved: isSaved ?? this.isSaved,
      isInterestSent: isInterestSent ?? this.isInterestSent,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        startupName,
        location,
        isSaved,
        isInterestSent,
        isFollowing,
      ];
}
