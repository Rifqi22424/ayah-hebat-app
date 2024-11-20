import 'package:flutter/material.dart';
import '../api/book_category_api.dart';
import '../models/book_category_model.dart';

enum BookCategoryState { initial, loading, loaded, error }

class BookCategoryProvider extends ChangeNotifier {
  List<BookCategory> _bookCategories = [];
  BookCategoryState _state = BookCategoryState.initial;
  String? _errorMessage;

  // Getters
  List<BookCategory> get bookCategories => _bookCategories;
  BookCategoryState get state => _state;
  String? get errorMessage => _errorMessage;

  final BookCategoryApi _categoryApi = BookCategoryApi();

  // Fetch categories dengan optional search
  Future<void> fetchCategories({
    String? search,
    bool refresh = false,
  }) async {
    try {
      print("masuk category provider");
      // Set loading state
      if (refresh || _state == BookCategoryState.initial) {
        _state = BookCategoryState.loading;
        notifyListeners();
      }

      // Get categories dari API
      final response = await _categoryApi.getAllCategoryBooks(
        search: search,
      );

      // Update categories list
      _bookCategories = response;

      _state = BookCategoryState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = BookCategoryState.error;
    } finally {
      print(_errorMessage);
      notifyListeners();
    }
  }

  // Refresh categories
  Future<void> refreshCategories({
    String? search,
  }) async {
    _bookCategories = [];
    await fetchCategories(
      search: search,
      refresh: true,
    );
  }

  // Clear categories
  void clearCategories() {
    _bookCategories = [];
    _state = BookCategoryState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  // Get category by id
  BookCategory? getCategoryById(int id) {
    try {
      return _bookCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  BookCategory? getCategoryByName(String name) {
    try {
      return _bookCategories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
