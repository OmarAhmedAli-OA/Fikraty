import '../../domain/entities/explore_founder.dart';

class ExploreFounderModel extends ExploreFounder {
  const ExploreFounderModel({
    required super.id,
    required super.name,
    required super.role,
    required super.startupName,
    required super.avatarUrl,
    required super.location,
    required super.skills,
    required super.followers,
    required super.isVerified,
    required super.bio,
    required super.lookingFor,
    super.isSaved = false,
    super.isInterestSent = false,
    super.isFollowing = false,
  });

  factory ExploreFounderModel.fromJson(Map<String, dynamic> json) {
    return ExploreFounderModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      startupName: json['startupName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      location: json['location'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      followers: json['followers'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      bio: json['bio'] as String? ?? '',
      lookingFor: json['lookingFor'] as String? ?? '',
      isSaved: json['isSaved'] as bool? ?? false,
      isInterestSent: json['isInterestSent'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'startupName': startupName,
      'avatarUrl': avatarUrl,
      'location': location,
      'skills': skills,
      'followers': followers,
      'isVerified': isVerified,
      'bio': bio,
      'lookingFor': lookingFor,
      'isSaved': isSaved,
      'isInterestSent': isInterestSent,
      'isFollowing': isFollowing,
    };
  }
}
