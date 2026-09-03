import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/cv_analysis_screen.dart';
import '../screens/cv_generator_screen.dart';
import '../screens/education_detail_screen.dart';
import '../screens/education_screen.dart';
import '../screens/generated_cv_loader_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/job_news_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/premium_gate_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import 'app_routes.dart';
import 'entitlement_store.dart';

final GlobalKey<NavigatorState> siratiNavigatorKey =
    GlobalKey<NavigatorState>();

/// Declarative router with deep-link parsing and entitlement guards.
class AppRouter {
  AppRouter._();

  static final _DeepLinkObserver _observer = _DeepLinkObserver();
  static bool _bindingInstalled = false;

  /// Consumed by [SplashScreen] after auth so cold-start deep links survive
  /// the session bootstrap `pushAndRemoveUntil`.
  static String? pendingLocation;

  /// Listen for warm-start OS route pushes (`sirati://app/...`).
  static void install() {
    if (_bindingInstalled) return;
    _bindingInstalled = true;
    WidgetsBinding.instance.addObserver(_observer);
  }

  static String consumePendingLocation() {
    final value = pendingLocation;
    pendingLocation = null;
    return value ?? AppRoutes.home;
  }

  /// After login / splash session restore: home under the stack, then deep link.
  static void openAfterAuth(BuildContext context) {
    final pending = pendingLocation;
    pendingLocation = null;
    if (pending == null ||
        pending == AppRoutes.splash ||
        pending == AppRoutes.home) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }
    if (pending == AppRoutes.myCvs) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: AppRoutes.myCvs),
          builder: (_) => const HomeScreen(initialIndex: 1),
        ),
        (route) => false,
      );
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      siratiNavigatorKey.currentState?.pushNamed(pending);
    });
  }

  static String resolveInitialRoute() {
    final preview = _webPreviewRoute();
    if (preview != null) return preview;

    final raw = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    if (raw.isEmpty || raw == '/') return AppRoutes.splash;

    final parsed = parse(raw);
    if (parsed.unknown) {
      pendingLocation = AppRoutes.notFound;
      return AppRoutes.splash;
    }
    if (parsed.name != AppRoutes.splash) return parsed.name;
    return AppRoutes.splash;
  }

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    final preview = _webPreviewRoute();
    if (preview != null) {
      return [_page(_widgetFor(parse(preview)), preview)];
    }

    final parsed = parse(initialRoute);
    if (parsed.name == AppRoutes.splash || parsed.unknown) {
      if (parsed.unknown &&
          initialRoute != '/' &&
          initialRoute != AppRoutes.splash) {
        pendingLocation = AppRoutes.notFound;
      }
      return [
        _page(const SplashScreen(), AppRoutes.splash),
      ];
    }

    pendingLocation = parsed.name;
    return [
      _page(const SplashScreen(), AppRoutes.splash),
    ];
  }

  /// Warm-start / subsequent OS deep link.
  static bool handleIncoming(String location) {
    final parsed = parse(location);
    final name = parsed.unknown ? AppRoutes.notFound : parsed.name;
    if (name == AppRoutes.splash) return false;

    final nav = siratiNavigatorKey.currentState;
    if (nav == null) {
      pendingLocation = name;
      return true;
    }
    nav.pushNamed(name);
    return true;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final parsed = parse(settings.name ?? AppRoutes.splash);
    if (parsed.unknown) {
      return _page(const NotFoundScreen(), AppRoutes.notFound);
    }
    if (parsed.requiresEntitlement && !EntitlementStore.hasPremium) {
      return _page(const PremiumGateScreen(), AppRoutes.premium);
    }
    return _page(_widgetFor(parsed), parsed.name);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _page(const NotFoundScreen(), AppRoutes.notFound);
  }

  static ParsedRoute parse(String location) {
    var path = location.trim();
    if (path.isEmpty) path = AppRoutes.splash;

    if (path.contains('://')) {
      final uri = Uri.tryParse(path);
      if (uri != null) {
        if (uri.scheme == 'sirati') {
          path = uri.path.isEmpty ? '/${uri.host}' : uri.path;
          if (path == '/app' || path == 'app') path = AppRoutes.splash;
          if (!path.startsWith('/')) path = '/$path';
          if (uri.host == 'app' && uri.path.isNotEmpty) {
            path = uri.path;
          }
        } else {
          path = uri.path;
        }
      }
    }

    if (!path.startsWith('/')) path = '/$path';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    switch (path) {
      case AppRoutes.splash:
      case AppRoutes.home:
      case AppRoutes.login:
      case AppRoutes.register:
      case AppRoutes.history:
      case AppRoutes.createCv:
      case AppRoutes.myCvs:
      case AppRoutes.education:
      case AppRoutes.jobNews:
      case AppRoutes.privacy:
      case AppRoutes.settings:
      case AppRoutes.notifications:
      case AppRoutes.notFound:
        return ParsedRoute(name: path);
      case AppRoutes.premium:
        return const ParsedRoute(
          name: AppRoutes.premium,
          requiresEntitlement: true,
        );
    }

    final cvId = _idAfter(path, AppRoutes.cvPrefix);
    if (cvId != null) {
      return ParsedRoute(name: AppRoutes.cv(cvId), id: cvId);
    }
    final analysisId = _idAfter(path, AppRoutes.analysisPrefix);
    if (analysisId != null) {
      return ParsedRoute(name: AppRoutes.analysis(analysisId), id: analysisId);
    }
    final educationId = _idAfter(path, AppRoutes.educationItemPrefix);
    if (educationId != null) {
      return ParsedRoute(
        name: AppRoutes.educationItem(educationId),
        id: educationId,
      );
    }

    return ParsedRoute(name: path, unknown: true);
  }

  static Widget _widgetFor(ParsedRoute parsed) {
    switch (parsed.name) {
      case AppRoutes.splash:
        return const SplashScreen();
      case AppRoutes.home:
        return const HomeScreen();
      case AppRoutes.login:
        return const LoginScreen();
      case AppRoutes.register:
        return const RegisterScreen();
      case AppRoutes.history:
        return const HistoryScreen();
      case AppRoutes.createCv:
        return const CvGeneratorScreen();
      case AppRoutes.myCvs:
        return const HomeScreen(initialIndex: 1);
      case AppRoutes.education:
        return const EducationScreen();
      case AppRoutes.jobNews:
        return const JobNewsScreen();
      case AppRoutes.privacy:
        return const PrivacyPolicyScreen();
      case AppRoutes.settings:
        return const SettingsScreen();
      case AppRoutes.notifications:
        return const NotificationsScreen();
      case AppRoutes.premium:
        return const PremiumGateScreen();
      case AppRoutes.notFound:
        return const NotFoundScreen();
    }

    if (parsed.name.startsWith(AppRoutes.cvPrefix) && parsed.id != null) {
      return GeneratedCvLoaderScreen(cvId: parsed.id!);
    }
    if (parsed.name.startsWith(AppRoutes.analysisPrefix)) {
      return const CvAnalysisScreen();
    }
    if (parsed.name.startsWith(AppRoutes.educationItemPrefix) &&
        parsed.id != null) {
      return EducationDetailScreen(id: parsed.id, fallback: const {});
    }
    return const NotFoundScreen();
  }

  static String? _webPreviewRoute() {
    if (!kIsWeb) return null;
    return _previewScreen(Uri.base.queryParameters['screen']);
  }

  static String? _previewScreen(String? screen) {
    return switch (screen) {
      'register' => AppRoutes.register,
      'create-cv' => AppRoutes.createCv,
      'mycvs' => AppRoutes.myCvs,
      'education' => AppRoutes.education,
      'history' => AppRoutes.history,
      'job-news' => AppRoutes.jobNews,
      'privacy' => AppRoutes.privacy,
      'home' => AppRoutes.home,
      _ => null,
    };
  }

  static int? _idAfter(String path, String prefix) {
    if (!path.startsWith(prefix)) return null;
    return int.tryParse(path.substring(prefix.length));
  }

  static MaterialPageRoute<dynamic> _page(Widget child, String name) {
    return MaterialPageRoute<dynamic>(
      settings: RouteSettings(name: name),
      builder: (_) => child,
    );
  }
}

class _DeepLinkObserver extends WidgetsBindingObserver {
  @override
  Future<bool> didPushRoute(String route) async {
    return AppRouter.handleIncoming(route);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    return AppRouter.handleIncoming(routeInformation.uri.toString());
  }
}
