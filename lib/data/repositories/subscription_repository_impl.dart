import '../../domain/repositories/subscription_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final ApiService apiService;

  SubscriptionRepositoryImpl({required this.apiService});

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await apiService.getPlans();
    final plans = (response['plans'] ?? response['data'] ?? []) as List;
    return plans.map((e) => SubscriptionPlan.fromJson(e)).toList();
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    final response = await apiService.getSubscriptionStatus();
    return SubscriptionStatus.fromJson(response['subscription'] ?? response);
  }

  @override
  Future<SubscriptionStatus> purchaseSubscription({
    required String planId,
    required String paymentMethod,
    bool isYearly = false,
  }) async {
    final response = await apiService.purchaseSubscription(
      planId: planId,
      paymentMethod: paymentMethod,
      isYearly: isYearly,
    );
    return SubscriptionStatus.fromJson(response['subscription'] ?? response);
  }

  @override
  Future<void> cancelSubscription() async {
    await apiService.cancelSubscription();
  }

  @override
  Future<void> restorePurchases() async {
    // TODO: Implement restore purchases logic with platform-specific code
  }

  @override
  Future<int> getRemainingCredits() async {
    final response = await apiService.getProfile();
    return response['creditsRemaining'] ?? response['credits_remaining'] ?? 0;
  }

  @override
  Future<void> useCredits(int amount) async {
    // Credits are automatically deducted on the server side
  }
}


