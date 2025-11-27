import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionLoadRequested extends SubscriptionEvent {
  const SubscriptionLoadRequested();
}

class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final String planId;
  final bool isYearly;

  const SubscriptionPurchaseRequested({
    required this.planId,
    this.isYearly = false,
  });

  @override
  List<Object?> get props => [planId, isYearly];
}

class SubscriptionCancelRequested extends SubscriptionEvent {
  const SubscriptionCancelRequested();
}

class SubscriptionRestoreRequested extends SubscriptionEvent {
  const SubscriptionRestoreRequested();
}





