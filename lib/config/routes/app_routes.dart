import 'package:flutter/material.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/ai_tools/ai_tools_screen.dart';
import '../../presentation/screens/editor/photo_editor_screen.dart';
import '../../presentation/screens/editor/enhance_screen.dart';
import '../../presentation/screens/editor/restore_screen.dart';
import '../../presentation/screens/editor/face_swap_screen.dart';
import '../../presentation/screens/editor/aging_screen.dart';
import '../../presentation/screens/editor/style_transfer_screen.dart';
import '../../presentation/screens/editor/filter_screen.dart';
import '../../presentation/screens/result/result_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/subscription/subscription_screen.dart';
import '../../presentation/screens/gallery/gallery_screen.dart';
import '../../presentation/screens/history/history_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String aiTools = '/ai-tools';
  static const String editor = '/editor';
  static const String enhance = '/enhance';
  static const String restore = '/restore';
  static const String faceSwap = '/face-swap';
  static const String aging = '/aging';
  static const String styleTransfer = '/style-transfer';
  static const String filter = '/filter';
  static const String result = '/result';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String gallery = '/gallery';
  static const String history = '/history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case onboarding:
        return _slideRoute(const OnboardingScreen(), settings);

      case login:
        return _slideRoute(const LoginScreen(), settings);

      case signup:
        return _slideRoute(const SignupScreen(), settings);

      case home:
        return _fadeRoute(const HomeScreen(), settings);

      case aiTools:
        return _slideRoute(const AIToolsScreen(), settings);

      case editor:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          PhotoEditorScreen(imagePath: args?['imagePath'] ?? ''),
          settings,
        );

      case enhance:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          EnhanceScreen(imagePath: args?['imagePath'] ?? ''),
          settings,
        );

      case restore:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          RestoreScreen(imagePath: args?['imagePath'] ?? ''),
          settings,
        );

      case faceSwap:
        return _slideRoute(const FaceSwapScreen(), settings);

      case aging:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          AgingScreen(imagePath: args?['imagePath'] ?? ''),
          settings,
        );

      case styleTransfer:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          StyleTransferScreen(imagePath: args?['imagePath'] ?? ''),
          settings,
        );

      case filter:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          FilterScreen(imagePath: args?['imagePath'] ?? ''),
          settings,
        );

      case result:
        final args = settings.arguments as Map<String, dynamic>;
        return _slideRoute(
          ResultScreen(
            originalImagePath: args['originalImagePath'],
            resultImagePath: args['resultImagePath'],
            editType: args['editType'],
          ),
          settings,
        );

      case profile:
        return _slideRoute(const ProfileScreen(), settings);

      case subscription:
        return _slideRoute(const SubscriptionScreen(), settings);

      case gallery:
        return _slideRoute(const GalleryScreen(), settings);

      case history:
        return _slideRoute(const HistoryScreen(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Fade transition
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide transition
  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}


