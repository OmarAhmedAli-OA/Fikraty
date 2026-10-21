import '../../domain/entities/interest_item.dart';

class InterestItemModel extends InterestItem {
  const InterestItemModel({
    required super.id,
    required super.name,
    required super.organization,
    required super.amount,
    required super.stage,
    required super.sector,
    required super.date,
    super.matchPercentage = 0,
    required super.initials,
    required super.colorValue,
    required super.direction,
    super.status = InterestStatus.pending,
    super.avatarUrl,
  });

  factory InterestItemModel.fromEntity(InterestItem entity) {
    return InterestItemModel(
      id: entity.id,
      name: entity.name,
      organization: entity.organization,
      amount: entity.amount,
      stage: entity.stage,
      sector: entity.sector,
      date: entity.date,
      matchPercentage: entity.matchPercentage,
      initials: entity.initials,
      colorValue: entity.colorValue,
      direction: entity.direction,
      status: entity.status,
      avatarUrl: entity.avatarUrl,
    );
  }

  factory InterestItemModel.fromMap(Map<String, dynamic> map) {
    final statusStr = map['status'] as String? ?? 'pending';
    final status = switch (statusStr) {
      'accepted' => InterestStatus.accepted,
      'declined' => InterestStatus.declined,
      _ => InterestStatus.pending,
    };

    final directionStr = map['direction'] as String? ?? 'received';
    final direction = directionStr == 'sent'
        ? InterestDirection.sent
        : InterestDirection.received;

    return InterestItemModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      organization: map['organization'] as String? ?? '',
      amount: map['amount'] as String? ?? '',
      stage: map['stage'] as String? ?? '',
      sector: map['sector'] as String? ?? '',
      date: map['date'] as String? ?? '',
      matchPercentage: map['matchPercentage'] as int? ?? 0,
      initials: map['initials'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0xFF5548E8,
      direction: direction,
      status: status,
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'amount': amount,
      'stage': stage,
      'sector': sector,
      'date': date,
      'matchPercentage': matchPercentage,
      'initials': initials,
      'colorValue': colorValue,
      'direction': direction.name,
      'status': status.name,
      'avatarUrl': avatarUrl,
    };
  }
}
