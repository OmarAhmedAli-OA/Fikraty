import '../../domain/entities/explore_event.dart';

class ExploreEventModel extends ExploreEvent {
  const ExploreEventModel({
    required super.id,
    required super.title,
    required super.type,
    required super.date,
    required super.time,
    required super.location,
    required super.isOnline,
    super.onlineLink,
    super.price,
    required super.attendeesCount,
    required super.imageUrl,
    required super.organizer,
    required super.description,
    super.isRegistered,
    super.isSaved,
  });

  factory ExploreEventModel.fromJson(Map<String, dynamic> json) {
    return ExploreEventModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      onlineLink: json['onlineLink'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      attendeesCount: json['attendeesCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isRegistered: json['isRegistered'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date,
      'time': time,
      'location': location,
      'isOnline': isOnline,
      'onlineLink': onlineLink,
      'price': price,
      'attendeesCount': attendeesCount,
      'imageUrl': imageUrl,
      'organizer': organizer,
      'description': description,
      'isRegistered': isRegistered,
      'isSaved': isSaved,
    };
  }
}
