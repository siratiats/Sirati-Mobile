import 'package:flutter/foundation.dart';

/// Structured logger (SIRATI-16).
///
/// Debug lines are dropped in release. CV / personal fields are redacted
/// so PDPL-sensitive content never hits logcat, Crashlytics, or Sentry
/// breadcrumbs via this API.
enum AppLogLevel { debug, info, warn, error }

class AppLog {
  AppLog._();

  static const _piiKeys = {
    'resume_text',
    'experience_input',
    'education_input',
    'summary_input',
    'skills_input',
    'certifications_input',
    'draft',
    'full_name',
    'fullname',
    'name',
    'email',
    'phone',
    'linkedin',
    'location',
    'generated_markdown',
    'markdown',
    'content',
    'resume',
    'cv',
    'body',
    'bio',
    'password',
    'token',
    'authorization',
  };

  static const _maxMessageChars = 280;

  static final _email = RegExp(r'[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}',
      caseSensitive: false);
  static final _phone = RegExp(r'\+?\d[\d\s\-().]{7,}\d');

  static void debug(String message, {Map<String, Object?>? data}) {
    _emit(AppLogLevel.debug, message, data);
  }

  static void info(String message, {Map<String, Object?>? data}) {
    _emit(AppLogLevel.info, message, data);
  }

  static void warn(String message, {Map<String, Object?>? data}) {
    _emit(AppLogLevel.warn, message, data);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _emit(
      AppLogLevel.error,
      message,
      {
        ...?data,
        if (error != null) 'error': redact(error.toString()),
      },
    );
    if (kDebugMode && stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }

  static void _emit(
    AppLogLevel level,
    String message,
    Map<String, Object?>? data,
  ) {
    if (level == AppLogLevel.debug && kReleaseMode) return;

    final safeMessage = redact(message);
    final safeData = data == null ? null : redactMap(data);
    final buffer = StringBuffer('[${level.name.toUpperCase()}] $safeMessage');
    if (safeData != null && safeData.isNotEmpty) {
      buffer.write(' ');
      buffer.write(safeData);
    }
    debugPrint(buffer.toString());
  }

  static String redact(String input) {
    var out = input;
    out = out.replaceAll(_email, '[email]');
    out = out.replaceAll(_phone, '[phone]');
    if (out.length > _maxMessageChars) {
      out = '${out.substring(0, _maxMessageChars)}[truncated]';
    }
    return out;
  }

  static Map<String, Object?> redactMap(Map<String, Object?> data) {
    final out = <String, Object?>{};
    data.forEach((key, value) {
      if (_piiKeys.contains(key.toLowerCase())) {
        out[key] = '[Filtered]';
        return;
      }
      if (value is String) {
        out[key] = redact(value);
      } else if (value is Map<String, Object?>) {
        out[key] = redactMap(value);
      } else if (value is Map) {
        out[key] = redactMap(Map<String, Object?>.from(value));
      } else if (value is List) {
        out[key] = '[Filtered]';
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  /// Localized, non-technical copy for users. Never include [error] text.
  static String userMessage({required bool english}) {
    return english
        ? 'Something went wrong. Your data is safe — try again.'
        : 'حدث خطأ. بياناتك بأمان — حاول مرة أخرى.';
  }
}
