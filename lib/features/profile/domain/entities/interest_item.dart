import 'package:equatable/equatable.dart';

enum InterestStatus { pending, accepted, declined }
enum InterestDirection { received, sent }

class InterestItem extends Equatable {
  final int id;
  final String name;
  final String organization; // Firm name or Startup name
  final String amount;
  final String stage;
  final String sector;
  final String date;
  final int matchPercentage;
  final String initials;
  final int colorValue;
  final InterestDirection direction;
  final InterestStatus status;
  final String? avatarUrl;

  const InterestItem({
    required this.id,
    required this.name,
    required this.organization,
    required this.amount,
    required this.stage,
    required this.sector,
    required this.date,
    this.matchPercentage = 0,
    required this.initials,
    required this.colorValue,
    required this.direction,
    this.status = InterestStatus.pending,
    this.avatarUrl,
  });

  InterestItem copyWith({
    int? id,
    String? name,
    String? organization,
    String? amount,
    String? stage,
    String? sector,
    String? date,
    int? matchPercentage,
    String? initials,
    int? colorValue,
    InterestDirection? direction,
    InterestStatus? status,
    String? avatarUrl,
  }) {
    return InterestItem(
      id: id ?? this.id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      amount: amount ?? this.amount,
      stage: stage ?? this.stage,
      sector: sector ?? this.sector,
      date: date ?? this.date,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      initials: initials ?? this.initials,
      colorValue: colorValue ?? this.colorValue,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        organization,
        amount,
        stage,
        sector,
        date,
        matchPercentage,
        initials,
        colorValue,
        direction,
        status,
        avatarUrl,
      ];
}
