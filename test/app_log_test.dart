import 'package:flutter_test/flutter_test.dart';
import 'package:sirati/logging/app_log.dart';

void main() {
  test('redacts emails and phone numbers in free text', () {
    final out = AppLog.redact(
      'Contact nora@example.com or +966 50 123 4567 please',
    );
    expect(out, isNot(contains('nora@example.com')));
    expect(out, contains('[email]'));
    expect(out, contains('[phone]'));
    expect(out, isNot(contains('501234567')));
  });

  test('filters CV and identity keys', () {
    final out = AppLog.redactMap({
      'resume_text': 'Senior engineer at ACME, email hidden@x.com',
      'full_name': 'Nora Example',
      'email': 'nora@example.com',
      'phone': '+966501234567',
      'generated_markdown': '# CV\nsecret',
      'template': 'ats-classic-professional',
      'cv_id': 12,
    });

    expect(out['resume_text'], '[Filtered]');
    expect(out['full_name'], '[Filtered]');
    expect(out['email'], '[Filtered]');
    expect(out['phone'], '[Filtered]');
    expect(out['generated_markdown'], '[Filtered]');
    expect(out['template'], 'ats-classic-professional');
    expect(out['cv_id'], 12);
  });

  test('redacts emails nested in non-PII string fields', () {
    final out = AppLog.redactMap({
      'note': 'Wrote to person@sirati.app yesterday',
    });
    expect(out['note'], contains('[email]'));
    expect(out['note'], isNot(contains('person@sirati.app')));
  });

  test('truncates oversized blobs so CV bodies cannot flood logs', () {
    final blob = 'x' * 400;
    final out = AppLog.redact(blob);
    expect(out.length, lessThan(blob.length));
    expect(out, endsWith('[truncated]'));
  });

  test('user-facing copy is localized and non-technical', () {
    expect(AppLog.userMessage(english: true), isNot(contains('Exception')));
    expect(AppLog.userMessage(english: true), isNot(contains('null')));
    expect(AppLog.userMessage(english: false), contains('خطأ'));
  });
}
