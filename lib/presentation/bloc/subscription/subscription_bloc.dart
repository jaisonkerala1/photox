import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({
    required this.subscriptionRepository,
  }) : super(const SubscriptionState.initial()) {
    on<SubscriptionLoadRequested>(_onLoadRequested);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested);
    on<SubscriptionCancelRequested>(_onCancelRequested);
    on<SubscriptionRestoreRequested>(_onRestoreRequested);
  }

  Future<void> _onLoadRequested(
    SubscriptionLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStateStatus.loading));

    try {
      final plans = await subscriptionRepository.getPlans();
      final subscriptionStatus = await subscriptionRepository.getSubscriptionStatus();
      final credits = await subscriptionRepository.getRemainingCredits();

      emit(state.copyWith(
        status: SubscriptionStateStatus.loaded,
        plans: plans,
        currentSubscription: subscriptionStatus,
        remainingCredits: credits,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPurchaseRequested(
    SubscriptionPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStateStatus.purchasing));

    try {
      final subscription = await subscriptionRepository.purchaseSubscription(
        planId: event.planId,
        paymentMethod: 'in_app',
        isYearly: event.isYearly,
      );

      emit(state.copyWith(
        status: SubscriptionStateStatus.purchased,
        currentSubscription: subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelRequested(
    SubscriptionCancelRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStateStatus.loading));

    try {
      await subscriptionRepository.cancelSubscription();
      emit(state.copyWith(status: SubscriptionStateStatus.cancelled));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreRequested(
    SubscriptionRestoreRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStateStatus.loading));

    try {
      await subscriptionRepository.restorePurchases();
      final subscriptionStatus = await subscriptionRepository.getSubscriptionStatus();
      
      emit(state.copyWith(
        status: SubscriptionStateStatus.restored,
        currentSubscription: subscriptionStatus,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}


