import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.profilePicture,
    required super.subscriptionType,
    super.subscriptionExpiry,
    required super.creditsRemaining,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profilePicture'] ?? json['profile_picture'],
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.name == (json['subscriptionType'] ?? json['subscription_type'] ?? 'free'),
        orElse: () => SubscriptionType.free,
      ),
      subscriptionExpiry: json['subscriptionExpiry'] != null || json['subscription_expiry'] != null
          ? DateTime.parse(json['subscriptionExpiry'] ?? json['subscription_expiry'])
          : null,
      creditsRemaining: json['creditsRemaining'] ?? json['credits_remaining'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'subscriptionType': subscriptionType.name,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'creditsRemaining': creditsRemaining,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePicture,
    SubscriptionType? subscriptionType,
    DateTime? subscriptionExpiry,
    int? creditsRemaining,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      creditsRemaining: creditsRemaining ?? this.creditsRemaining,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final String token;
  final String? refreshToken;
  final UserModel user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}





