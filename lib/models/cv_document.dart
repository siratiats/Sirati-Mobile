/// Canonical bilingual CV document (schema_version 1).
///
/// Mirrors the Laravel `App\Cv\CvDocument` contract so the ATS engine,
/// PDF templates, and Flutter editors share one typed shape.
class LocalizedText {
  final String ar;
  final String en;

  const LocalizedText({this.ar = '', this.en = ''});

  factory LocalizedText.fromJson(dynamic json) {
    if (json is String) {
      return LocalizedText(ar: json);
    }
    if (json is Map<String, dynamic>) {
      return LocalizedText(
        ar: json['ar']?.toString() ?? '',
        en: json['en']?.toString() ?? '',
      );
    }
    return const LocalizedText();
  }

  String resolve(String language, {bool fallback = true}) {
    final primary = language == 'en' ? en : ar;
    if (primary.isNotEmpty || !fallback) return primary;
    return language == 'en' ? ar : en;
  }

  bool get isEmpty => ar.isEmpty && en.isEmpty;

  /// `ar` or `en` when only one variant is filled.
  String? get missingCounterpart {
    if (ar.isNotEmpty && en.isEmpty) return 'en';
    if (en.isNotEmpty && ar.isEmpty) return 'ar';
    return null;
  }

  Map<String, String> toJson() => {'ar': ar, 'en': en};

  LocalizedText copyWith({String? ar, String? en}) {
    return LocalizedText(ar: ar ?? this.ar, en: en ?? this.en);
  }
}

class CvDocument {
  static const schemaVersion = 1;

  final String exportLanguage;
  final LocalizedText fullName;
  final LocalizedText headline;
  final String? email;
  final String? phone;
  final String? linkedin;
  final LocalizedText location;
  final LocalizedText summary;
  final List<String> missingTranslations;

  const CvDocument({
    required this.exportLanguage,
    required this.fullName,
    required this.headline,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.location,
    required this.summary,
    this.missingTranslations = const [],
  });

  factory CvDocument.fromJson(Map<String, dynamic> json) {
    final personal = json['personal'] is Map<String, dynamic>
        ? json['personal'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return CvDocument(
      exportLanguage: json['export_language']?.toString() == 'en' ? 'en' : 'ar',
      fullName: LocalizedText.fromJson(personal['full_name']),
      headline: LocalizedText.fromJson(personal['headline']),
      email: personal['email']?.toString(),
      phone: personal['phone']?.toString(),
      linkedin: personal['linkedin']?.toString(),
      location: LocalizedText.fromJson(personal['location']),
      summary: LocalizedText.fromJson(json['summary']),
      missingTranslations: (json['missing_translations'] is List)
          ? (json['missing_translations'] as List)
              .map((item) => item.toString())
              .toList()
          : const [],
    );
  }

  bool get hasTranslationGaps => missingTranslations.isNotEmpty;

  CvDocument duplicate() => CvDocument(
        exportLanguage: exportLanguage,
        fullName: fullName,
        headline: headline,
        email: email,
        phone: phone,
        linkedin: linkedin,
        location: location,
        summary: summary,
        missingTranslations: missingTranslations,
      );

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'export_language': exportLanguage,
        'personal': {
          'full_name': fullName.toJson(),
          'headline': headline.toJson(),
          'email': email,
          'phone': phone,
          'linkedin': linkedin,
          'location': location.toJson(),
        },
        'summary': summary.toJson(),
      };
}
