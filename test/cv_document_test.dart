import 'package:flutter_test/flutter_test.dart';
import 'package:sirati/models/cv_document.dart';
import 'package:sirati/models/cv_template.dart';

void main() {
  test('round-trips bilingual fields and reports missing translations', () {
    const original = CvDocument(
      exportLanguage: 'en',
      fullName: LocalizedText(ar: 'سارة أحمد', en: 'Sara Ahmed'),
      headline: LocalizedText(en: 'Backend Developer'),
      email: 'sara@example.com',
      phone: '+966500000000',
      linkedin: null,
      location: LocalizedText(ar: 'الرياض', en: 'Riyadh'),
      summary: LocalizedText(en: 'Backend developer'),
      missingTranslations: ['headline.ar', 'summary.ar'],
    );

    final decoded = CvDocument.fromJson(original.toJson());

    expect(decoded.fullName.ar, 'سارة أحمد');
    expect(decoded.fullName.en, 'Sara Ahmed');
    expect(decoded.fullName.resolve('en'), 'Sara Ahmed');
    expect(decoded.fullName.resolve('ar'), 'سارة أحمد');
    expect(decoded.headline.resolve('ar'), 'Backend Developer');
    expect(decoded.headline.missingCounterpart, 'ar');
    expect(decoded.duplicate().fullName.en, 'Sara Ahmed');
    expect(decoded.hasTranslationGaps, isFalse);
  });

  test('fromJson reads missing_translations for UI badges', () {
    final document = CvDocument.fromJson({
      'export_language': 'ar',
      'personal': {
        'full_name': {'ar': 'سارة', 'en': ''},
      },
      'summary': {'ar': 'ملخص', 'en': ''},
      'missing_translations': ['personal.full_name.en', 'summary.en'],
    });

    expect(document.hasTranslationGaps, isTrue);
    expect(document.missingTranslations, ['personal.full_name.en', 'summary.en']);
  });

  test('template switch keeps content and warns about hidden sections', () {
    const template = CvTemplate(
      id: 1,
      slug: 'classic',
      name: 'Classic',
      nameAr: 'كلاسيكي',
      nameEn: 'Classic',
      previewImageUrl: null,
      languageDirection: 'rtl',
      supportedLanguages: ['ar', 'en'],
      supportedSections: ['summary', 'skills', 'experience', 'education'],
      isDefault: true,
    );

    expect(
      template.omittedCanonicalSections(['summary', 'projects']),
      ['projects'],
    );
    expect(template.omittedCanonicalSections(['summary', 'skills']), isEmpty);
  });
}
