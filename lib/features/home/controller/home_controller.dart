import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  int _selectedNavIndex = 0;
  int _selectedCategory = 0;

  Widget? _overlayScreen;

  String _searchQuery = "";
  bool _isSearching = false;

  int get selectedNavIndex => _selectedNavIndex;

  int get selectedCategory => _selectedCategory;

  Widget? get overlayScreen => _overlayScreen;

  String get searchQuery => _searchQuery;

  bool get isSearching => _isSearching;

  void setSelectedNavIndex(int index) {
    if (_selectedNavIndex == index && _overlayScreen == null) {
      return;
    }

    _selectedNavIndex = index;
    _overlayScreen = null;

    notifyListeners();
  }

  void setCategory(int index) {
    if (_selectedCategory == index) {
      return;
    }

    _selectedCategory = index;

    notifyListeners();
  }

  void setOverlay(Widget? screen) {
    _overlayScreen = screen;

    notifyListeners();
  }

  void closeOverlay() {
    if (_overlayScreen == null) {
      return;
    }

    _overlayScreen = null;

    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) {
      return;
    }

    _searchQuery = query;

    notifyListeners();
  }

  void setSearching(bool value) {
    if (_isSearching == value) {
      return;
    }

    _isSearching = value;

    if (!value) {
      _searchQuery = "";
    }

    notifyListeners();
  }

  void resetSearch() {
    _searchQuery = "";
    _isSearching = false;

    notifyListeners();
  }
}
