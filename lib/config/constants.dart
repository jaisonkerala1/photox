class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'PhotoX';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'AI-Powered Photo Magic';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 120);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  
  // Image Configuration
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const int imageQuality = 85;
  static const int thumbnailSize = 300;
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Free Tier Limits
  static const int freeCreditsDaily = 3;
  static const int freeSaveLimit = 10;
  static const int maxFreeEdits = 5;
  
  // Pro Tier Benefits
  static const int proCreditsDaily = 100;
  static const bool proUnlimitedSave = true;
  static const bool proNoAds = true;
  static const bool proHDExport = true;
  
  // Subscription
  static const String monthlyPlanId = 'photox_pro_monthly';
  static const String yearlyPlanId = 'photox_pro_yearly';
  static const double monthlyPrice = 9.99;
  static const double yearlyPrice = 59.99;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Ad Unit IDs (Test IDs - Replace with production IDs)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  // AI Features
  static const List<String> aiFeatures = [
    'enhance',
    'restore',
    'selfie_edit',
    'face_swap',
    'aging',
    'baby_generator',
    'animate',
    'style_transfer',
    'upscale',
    'filter',
  ];
  
  // Filter Categories
  static const List<String> filterCategories = [
    'Trending',
    'Artistic',
    'Vintage',
    'Film',
    'Seasonal',
    'Fantasy',
  ];
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  
  // Photos
  static const String photos = '/photos';
  static const String uploadPhoto = '/photos/upload';
  static String deletePhoto(String id) => '/photos/$id';
  static String getPhoto(String id) => '/photos/$id';
  
  // AI Processing
  static const String enhance = '/ai/enhance';
  static const String restore = '/ai/restore';
  static const String selfieEdit = '/ai/selfie-edit';
  static const String faceSwap = '/ai/face-swap';
  static const String aging = '/ai/aging';
  static const String babyGenerator = '/ai/baby-generator';
  static const String animate = '/ai/animate';
  static const String styleTransfer = '/ai/style-transfer';
  static const String upscale = '/ai/upscale';
  static const String applyFilter = '/ai/apply-filter';
  
  // Subscription
  static const String plans = '/subscription/plans';
  static const String purchase = '/subscription/purchase';
  static const String subscriptionStatus = '/subscription/status';
  static const String cancelSubscription = '/subscription/cancel';
  
  // History
  static const String history = '/history';
  static String deleteHistory(String id) => '/history/$id';
}


