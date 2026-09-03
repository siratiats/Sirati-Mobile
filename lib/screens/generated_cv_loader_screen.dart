import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../models/generated_cv.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading/branded_loader.dart';
import 'generated_cv_screen.dart';

/// Deep-link entry for `/cv/:id` — loads the CV then shows the real screen.
class GeneratedCvLoaderScreen extends StatefulWidget {
  final int cvId;

  const GeneratedCvLoaderScreen({super.key, required this.cvId});

  @override
  State<GeneratedCvLoaderScreen> createState() =>
      _GeneratedCvLoaderScreenState();
}

class _GeneratedCvLoaderScreenState extends State<GeneratedCvLoaderScreen> {
  late Future<GeneratedCv> _future;

  @override
  void initState() {
    super.initState();
    _future = CvApiService().getGeneratedCv(widget.cvId);
  }

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);
    return FutureBuilder<GeneratedCv>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GeneratedCvScreen(generatedCv: snapshot.data!);
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: context.sirati.background,
            appBar: AppBar(),
            body: AppErrorState(
              english: english,
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).displayMessage
                  : (english
                      ? 'Could not open this CV.'
                      : 'تعذر فتح هذه السيرة.'),
              onRetry: () {
                setState(() {
                  _future = CvApiService().getGeneratedCv(widget.cvId);
                });
              },
            ),
          );
        }
        return const Scaffold(
          body: Center(child: BrandedLoader()),
        );
      },
    );
  }
}
