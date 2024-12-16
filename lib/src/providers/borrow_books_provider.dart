import 'package:flutter/material.dart';
import '../api/book_api.dart';
import '../models/borrow_books_model.dart';

enum BorrowBooksState { initial, loading, loaded, error }

class BorrowBooksProvider extends ChangeNotifier {
  List<BorrowBook> _borrowBooks = [];
  BorrowBooksState _borrowBooksState = BorrowBooksState.initial;
  String? _errorMessage;
  bool _hasMoreData = true;
  int _currentPage = 1;

  List<BorrowBook> get borrowBooks => _borrowBooks;
  BorrowBooksState get borrowBooksState => _borrowBooksState;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  final BookApi bookService = BookApi();

  Future<void> fetchBorrowBooks() async {
    if (!_hasMoreData) return;

    try {
      _borrowBooksState = BorrowBooksState.loading;
      notifyListeners();

      final BorrowBooksResponse response =
          await bookService.getBorrowBooks(page: _currentPage);

      if (response.data.isNotEmpty) {
        _borrowBooks.addAll(response.data);
        _currentPage++;
        _hasMoreData = response.data.length >= response.pagination.itemsPerPage;
      } else {
        _hasMoreData = false;
      }

      _borrowBooksState = BorrowBooksState.loaded;
    } catch (e) {
      _borrowBooksState = BorrowBooksState.error;
      _errorMessage = e.toString();
    }

    print("Error message: $_errorMessage");

    notifyListeners();
  }

  Future<void> refreshBorrowBooks() async {
    try {
      _currentPage = 1;
      _borrowBooks = [];

      _borrowBooksState = BorrowBooksState.loading;
      notifyListeners();

      final BorrowBooksResponse response =
          await bookService.getBorrowBooks(page: _currentPage);

      if (response.data.isNotEmpty) {
        _borrowBooks = response.data;
        _currentPage++;
        _hasMoreData = response.data.length >= response.pagination.itemsPerPage;
      } else {
        _hasMoreData = false;
      }

      _borrowBooksState = BorrowBooksState.loaded;
    } catch (e) {
      _borrowBooksState = BorrowBooksState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _borrowBooks = [];
    _borrowBooksState = BorrowBooksState.initial;
    _errorMessage = null;
    _hasMoreData = true;
    _currentPage = 1;
    notifyListeners();
  }
}
