import 'package:equatable/equatable.dart';

import '../../../data/models/subscription_model.dart';

enum SubscriptionStateStatus {
  initial,
  loading,
  loaded,
  purchasing,
  purchased,
  cancelled,
  restored,
  error,
}

class SubscriptionState extends Equatable {
  final SubscriptionStateStatus status;
  final List<SubscriptionPlan> plans;
  final SubscriptionStatus? currentSubscription;
  final int remainingCredits;
  final String? errorMessage;

  const SubscriptionState({
    this.status = SubscriptionStateStatus.initial,
    this.plans = const [],
    this.currentSubscription,
    this.remainingCredits = 0,
    this.errorMessage,
  });

  const SubscriptionState.initial() : this();

  SubscriptionState copyWith({
    SubscriptionStateStatus? status,
    List<SubscriptionPlan>? plans,
    SubscriptionStatus? currentSubscription,
    int? remainingCredits,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      remainingCredits: remainingCredits ?? this.remainingCredits,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == SubscriptionStateStatus.loading;
  bool get isPurchasing => status == SubscriptionStateStatus.purchasing;
  bool get isPro => currentSubscription?.isActive ?? false;
  bool get hasCredits => remainingCredits > 0;

  @override
  List<Object?> get props => [
    status,
    plans,
    currentSubscription,
    remainingCredits,
    errorMessage,
  ];
}





