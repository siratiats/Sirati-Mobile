import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../logging/app_log.dart';
import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

/// Recoverable UI for uncaught Flutter errors (SIRATI-16).
class AppCrashView extends StatelessWidget {
  const AppCrashView({super.key});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.languageCode.value == 'en';
    return Directionality(
      textDirection: english ? TextDirection.ltr : TextDirection.rtl,
      child: Theme(
        data: AppTheme.lightFor(arabic: !english),
        child: Material(
          color: SiratiColors.light.background,
          child: SafeArea(
            child: AppErrorState(
              english: english,
              title: english ? 'Something went wrong' : 'حدث خطأ',
              message: AppLog.userMessage(english: english),
              scrollable: false,
            ),
          ),
        ),
      ),
    );
  }
}

/// In-app recoverable panel (has a real [Navigator]).
class AppRecoverableError extends StatelessWidget {
  const AppRecoverableError({super.key});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);
    return Scaffold(
      backgroundColor: context.sirati.background,
      body: AppErrorState(
        english: english,
        title: english ? 'Something went wrong' : 'حدث خطأ',
        message: AppLog.userMessage(english: english),
        onRetry: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        },
      ),
    );
  }
}
