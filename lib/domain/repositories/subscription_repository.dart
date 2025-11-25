import '../../data/models/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getPlans();

  Future<SubscriptionStatus> getSubscriptionStatus();

  Future<SubscriptionStatus> purchaseSubscription({
    required String planId,
    required String paymentMethod,
    bool isYearly = false,
  });

  Future<void> cancelSubscription();

  Future<void> restorePurchases();

  Future<int> getRemainingCredits();

  Future<void> useCredits(int amount);
}


