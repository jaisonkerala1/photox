class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int dailyCredits;
  final bool hdExport;
  final bool noAds;
  final bool priorityProcessing;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.dailyCredits,
    required this.hdExport,
    required this.noAds,
    required this.priorityProcessing,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      monthlyPrice: (json['monthlyPrice'] ?? json['monthly_price'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? json['yearly_price'] ?? 0).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      dailyCredits: json['dailyCredits'] ?? json['daily_credits'] ?? 0,
      hdExport: json['hdExport'] ?? json['hd_export'] ?? false,
      noAds: json['noAds'] ?? json['no_ads'] ?? false,
      priorityProcessing: json['priorityProcessing'] ?? json['priority_processing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'features': features,
      'dailyCredits': dailyCredits,
      'hdExport': hdExport,
      'noAds': noAds,
      'priorityProcessing': priorityProcessing,
    };
  }

  static const SubscriptionPlan free = SubscriptionPlan(
    id: 'free',
    name: 'Free',
    description: 'Basic access with limited features',
    monthlyPrice: 0,
    yearlyPrice: 0,
    features: [
      '3 AI edits per day',
      'Standard quality export',
      'Basic filters',
      'Ad-supported',
    ],
    dailyCredits: 3,
    hdExport: false,
    noAds: false,
    priorityProcessing: false,
  );

  static const SubscriptionPlan pro = SubscriptionPlan(
    id: 'pro',
    name: 'PRO',
    description: 'Unlimited access to all features',
    monthlyPrice: 9.99,
    yearlyPrice: 59.99,
    features: [
      'Unlimited AI edits',
      'HD quality export',
      'All filters & styles',
      'No ads',
      'Priority processing',
      'Advanced face tools',
      'Batch processing',
      'Cloud storage',
    ],
    dailyCredits: 9999,
    hdExport: true,
    noAds: true,
    priorityProcessing: true,
  );
}

class SubscriptionStatus {
  final String id;
  final String planId;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? paymentId;
  final DateTime? cancelledAt;

  const SubscriptionStatus({
    required this.id,
    required this.planId,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.paymentId,
    this.cancelledAt,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      id: json['id'] ?? json['_id'] ?? '',
      planId: json['planId'] ?? json['plan_id'] ?? '',
      status: json['status'] ?? 'inactive',
      startDate: DateTime.parse(
        json['startDate'] ?? json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.parse(json['endDate'] ?? json['end_date'])
          : null,
      isActive: json['isActive'] ?? json['is_active'] ?? false,
      paymentId: json['paymentId'] ?? json['payment_id'],
      cancelledAt: json['cancelledAt'] != null || json['cancelled_at'] != null
          ? DateTime.parse(json['cancelledAt'] ?? json['cancelled_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'paymentId': paymentId,
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}





