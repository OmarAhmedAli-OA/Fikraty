import '../../domain/entities/explore_content_item.dart';

class ExploreContentItemModel extends ExploreContentItem {
  const ExploreContentItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    super.iconOrEmoji,
    required super.subtitle,
    super.author,
    super.readTime,
    super.repliesCount,
    super.avatarUrl,
    super.isSaved,
  });

  factory ExploreContentItemModel.fromJson(Map<String, dynamic> json) {
    return ExploreContentItemModel(
      id: json['id'] as int,
      type: ExploreContentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExploreContentType.post,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconOrEmoji: json['iconOrEmoji'] as String?,
      subtitle: json['subtitle'] as String? ?? '',
      author: json['author'] as String?,
      readTime: json['readTime'] as String?,
      repliesCount: json['repliesCount'] as int?,
      avatarUrl: json['avatarUrl'] as String?,
      isSaved: json['isSaved'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'iconOrEmoji': iconOrEmoji,
      'subtitle': subtitle,
      'author': author,
      'readTime': readTime,
      'repliesCount': repliesCount,
      'avatarUrl': avatarUrl,
      'isSaved': isSaved,
    };
  }
}
