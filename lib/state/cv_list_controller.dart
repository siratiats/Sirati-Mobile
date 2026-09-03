import 'package:flutter/foundation.dart';

import '../models/generated_cv.dart';
import '../services/cv_api_service.dart';
import 'async_state.dart';

/// Loads the signed-in user's generated CVs.
///
/// Reference vertical slice for [AsyncState] + [ChangeNotifier] (SIRATI-12).
/// Covers loading, success, and error. Test without pumping widgets.
class CvListController extends ChangeNotifier {
  CvListController({
    Future<List<GeneratedCv>> Function()? loader,
    CvApiService? api,
  }) : _loader = loader ?? api?.listGeneratedCvs ?? CvApiService().listGeneratedCvs;

  final Future<List<GeneratedCv>> Function() _loader;

  AsyncState<List<GeneratedCv>> _state = const AsyncLoading();
  int _generation = 0;

  AsyncState<List<GeneratedCv>> get state => _state;

  Future<void> load() async {
    final generation = ++_generation;
    _state = const AsyncLoading();
    notifyListeners();

    try {
      final items = await _loader();
      if (generation != _generation) return;
      _state = AsyncSuccess(List<GeneratedCv>.unmodifiable(items));
    } catch (error) {
      if (generation != _generation) return;
      _state = AsyncFailure(error);
    }
    notifyListeners();
  }
}
