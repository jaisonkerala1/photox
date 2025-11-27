import 'package:equatable/equatable.dart';

enum SubscriptionType { free, pro }

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profilePicture;
  final SubscriptionType subscriptionType;
  final DateTime? subscriptionExpiry;
  final int creditsRemaining;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.subscriptionType,
    this.subscriptionExpiry,
    required this.creditsRemaining,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPro => subscriptionType == SubscriptionType.pro;
  
  bool get hasActiveSubscription {
    if (subscriptionType == SubscriptionType.free) return false;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  bool get hasCredits => creditsRemaining > 0;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profilePicture,
    subscriptionType,
    subscriptionExpiry,
    creditsRemaining,
    createdAt,
    updatedAt,
  ];
}





