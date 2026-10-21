import 'package:equatable/equatable.dart';
import '../../../../core/constants/countries.dart';

enum UserRole { entrepreneur, investor }

class UserPost extends Equatable {
  final int id;
  final String text;
  final int likes;
  final String time;
  final bool isLikedByMe;

  const UserPost({
    required this.id,
    required this.text,
    required this.likes,
    required this.time,
    this.isLikedByMe = false,
  });

  UserPost copyWith({
    int? id,
    String? text,
    int? likes,
    String? time,
    bool? isLikedByMe,
  }) {
    return UserPost(
      id: id ?? this.id,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      time: time ?? this.time,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  @override
  List<Object?> get props => [id, text, likes, time, isLikedByMe];
}

class ProfileDocument extends Equatable {
  final String id;
  final String name;
  final String size;
  final String uploadDate;
  final String path;
  final String type; // pdf, image, doc

  const ProfileDocument({
    required this.id,
    required this.name,
    required this.size,
    required this.uploadDate,
    required this.path,
    this.type = 'pdf',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'uploadDate': uploadDate,
      'path': path,
      'type': type,
    };
  }

  factory ProfileDocument.fromMap(Map<String, dynamic> map) {
    return ProfileDocument(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      size: map['size'] as String? ?? '1.2 MB',
      uploadDate: map['uploadDate'] as String? ?? 'Just now',
      path: map['path'] as String? ?? '',
      type: map['type'] as String? ?? 'pdf',
    );
  }

  @override
  List<Object?> get props => [id, name, size, uploadDate, path, type];
}

class PortfolioStartup extends Equatable {
  final int id;
  final String name;
  final String sector;
  final String status;
  final String initials;
  final int colorValue;

  const PortfolioStartup({
    required this.id,
    required this.name,
    required this.sector,
    required this.status,
    required this.initials,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [id, name, sector, status, initials, colorValue];
}

class UserProfile extends Equatable {
  final String id;
  final UserRole role;
  final String fullName;
  final String title;
  final String bio;
  final String background;
  final String location;
  final Country country;
  final String photoUrl;
  final String coverUrl;
  final String website;
  final String linkedIn;
  final String twitter;
  final String angelList;
  final List<String> expertise;
  final String companyName;
  final String industry;
  final String companyStage;
  final String firmName;
  final String fundSize;
  final String yearsInvesting;
  final bool isVerified;
  final String verificationBadge;
  final int followersCount;
  final int followingCount;
  final int investorInterestCount;
  final int portfolioCount;
  final String totalDeployed;
  final String thesisQuote;
  final int profileViews;
  final String email;
  final String phone;
  final String profileVisibility;
  final String messagingFrom;
  final List<UserPost> posts;
  final List<PortfolioStartup> portfolioStartups;
  final List<ProfileDocument> documents;

  const UserProfile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.title,
    required this.bio,
    this.background = '',
    required this.location,
    required this.country,
    required this.photoUrl,
    this.coverUrl = '',
    this.website = '',
    this.linkedIn = '',
    this.twitter = '',
    this.angelList = '',
    this.expertise = const [],
    this.companyName = '',
    this.industry = '',
    this.companyStage = '',
    this.firmName = '',
    this.fundSize = '',
    this.yearsInvesting = '',
    this.isVerified = true,
    this.verificationBadge = '',
    this.followersCount = 0,
    this.followingCount = 0,
    this.investorInterestCount = 0,
    this.portfolioCount = 0,
    this.totalDeployed = '',
    this.thesisQuote = '',
    this.profileViews = 2840,
    this.email = 'sarah@novamed.ai',
    this.phone = '+971 50 123 4567',
    this.profileVisibility = 'Public',
    this.messagingFrom = 'Everyone',
    this.posts = const [],
    this.portfolioStartups = const [],
    this.documents = const [],
  });

  int get totalLikes => posts.fold(0, (sum, p) => sum + p.likes);
  int get realPostsCount => posts.length;

  UserProfile copyWith({
    String? id,
    UserRole? role,
    String? fullName,
    String? title,
    String? bio,
    String? background,
    String? location,
    Country? country,
    String? photoUrl,
    String? coverUrl,
    String? website,
    String? linkedIn,
    String? twitter,
    String? angelList,
    List<String>? expertise,
    String? companyName,
    String? industry,
    String? companyStage,
    String? firmName,
    String? fundSize,
    String? yearsInvesting,
    bool? isVerified,
    String? verificationBadge,
    int? followersCount,
    int? followingCount,
    int? investorInterestCount,
    int? portfolioCount,
    String? totalDeployed,
    String? thesisQuote,
    int? profileViews,
    String? email,
    String? phone,
    String? profileVisibility,
    String? messagingFrom,
    List<UserPost>? posts,
    List<PortfolioStartup>? portfolioStartups,
    List<ProfileDocument>? documents,
  }) {
    return UserProfile(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      background: background ?? this.background,
      location: location ?? this.location,
      country: country ?? this.country,
      photoUrl: photoUrl ?? this.photoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      website: website ?? this.website,
      linkedIn: linkedIn ?? this.linkedIn,
      twitter: twitter ?? this.twitter,
      angelList: angelList ?? this.angelList,
      expertise: expertise ?? this.expertise,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      companyStage: companyStage ?? this.companyStage,
      firmName: firmName ?? this.firmName,
      fundSize: fundSize ?? this.fundSize,
      yearsInvesting: yearsInvesting ?? this.yearsInvesting,
      isVerified: isVerified ?? this.isVerified,
      verificationBadge: verificationBadge ?? this.verificationBadge,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      investorInterestCount:
          investorInterestCount ?? this.investorInterestCount,
      portfolioCount: portfolioCount ?? this.portfolioCount,
      totalDeployed: totalDeployed ?? this.totalDeployed,
      thesisQuote: thesisQuote ?? this.thesisQuote,
      profileViews: profileViews ?? this.profileViews,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      messagingFrom: messagingFrom ?? this.messagingFrom,
      posts: posts ?? this.posts,
      portfolioStartups: portfolioStartups ?? this.portfolioStartups,
      documents: documents ?? this.documents,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        fullName,
        title,
        bio,
        location,
        country,
        photoUrl,
        coverUrl,
        website,
        linkedIn,
        companyName,
        industry,
        companyStage,
        firmName,
        fundSize,
        yearsInvesting,
        isVerified,
        followersCount,
        followingCount,
        investorInterestCount,
        portfolioCount,
        totalDeployed,
        profileViews,
        email,
        phone,
        profileVisibility,
        messagingFrom,
        posts,
        documents,
      ];
}
