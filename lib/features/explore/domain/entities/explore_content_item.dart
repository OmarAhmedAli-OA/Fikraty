import 'package:equatable/equatable.dart';

enum ExploreContentType {
  startup,
  investor,
  founder,
  event,
  campaign,
  community,
  knowledge,
  discussion,
  challenge,
  post,
}

class ExploreContentItem extends Equatable {
  const ExploreContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.iconOrEmoji,
    required this.subtitle,
    this.author,
    this.readTime,
    this.repliesCount,
    this.avatarUrl,
    this.isSaved = true,
  });

  final int id;
  final ExploreContentType type;
  final String title;
  final String description;
  final String? iconOrEmoji;
  final String subtitle;
  final String? author;
  final String? readTime;
  final int? repliesCount;
  final String? avatarUrl;
  final bool isSaved;

  ExploreContentItem copyWith({
    int? id,
    ExploreContentType? type,
    String? title,
    String? description,
    String? iconOrEmoji,
    String? subtitle,
    String? author,
    String? readTime,
    int? repliesCount,
    String? avatarUrl,
    bool? isSaved,
  }) {
    return ExploreContentItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      iconOrEmoji: iconOrEmoji ?? this.iconOrEmoji,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      readTime: readTime ?? this.readTime,
      repliesCount: repliesCount ?? this.repliesCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [id, type, title, isSaved];
}
