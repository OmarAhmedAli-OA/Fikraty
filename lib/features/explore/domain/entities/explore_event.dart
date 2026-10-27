import 'package:equatable/equatable.dart';

class ExploreEvent extends Equatable {
  const ExploreEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.time,
    required this.location,
    required this.isOnline,
    this.onlineLink,
    this.price,
    required this.attendeesCount,
    required this.imageUrl,
    required this.organizer,
    required this.description,
    this.isRegistered = false,
    this.isSaved = false,
  });

  final int id;
  final String title;
  final String type;
  final String date;
  final String time;
  final String location;
  final bool isOnline;
  final String? onlineLink;
  final double? price;
  final int attendeesCount;
  final String imageUrl;
  final String organizer;
  final String description;
  final bool isRegistered;
  final bool isSaved;

  bool get isFree => price == null || price == 0;

  ExploreEvent copyWith({
    int? id,
    String? title,
    String? type,
    String? date,
    String? time,
    String? location,
    bool? isOnline,
    String? onlineLink,
    double? price,
    int? attendeesCount,
    String? imageUrl,
    String? organizer,
    String? description,
    bool? isRegistered,
    bool? isSaved,
  }) {
    return ExploreEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      onlineLink: onlineLink ?? this.onlineLink,
      price: price ?? this.price,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      imageUrl: imageUrl ?? this.imageUrl,
      organizer: organizer ?? this.organizer,
      description: description ?? this.description,
      isRegistered: isRegistered ?? this.isRegistered,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        date,
        location,
        isRegistered,
        isSaved,
      ];
}
