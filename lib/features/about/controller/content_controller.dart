import 'package:flutter/foundation.dart';

import '../model/content_model.dart';
import '../repository/content_repo.dart';

class ContentController extends ChangeNotifier {
  final ContentRepo _repo = ContentRepo();

  ContentModel? _content;
  bool _isLoading = false;
  String? _errorMessage;

  ContentModel? get content => _content;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchContent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _content = await _repo.getContent(
        restaurantId: 1248,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
