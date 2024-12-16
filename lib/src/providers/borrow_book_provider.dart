
import 'package:flutter/material.dart';

import '../api/book_api.dart';
import '../models/borrow_books_model.dart';

enum BorrowBookState { initial, loading, loaded, error }

class BorrowBookProvider extends ChangeNotifier {
  BorrowBook? _borrowBook;
  BorrowBookState _borrowBookState = BorrowBookState.initial;
  String? _errorMessage;

  BorrowBook? get borrowBook => _borrowBook;
  BorrowBookState get borrowBookState => _borrowBookState;
  String? get errorMessage => _errorMessage;

  final BookApi donationService = BookApi();

  Future<void> fetchBorrowBookById({required int borrowId}) async {
    try {
      _borrowBook = null;

      _borrowBookState = BorrowBookState.loading;
      notifyListeners();

      final BorrowBookByIdResponse response =
          await donationService.getBorrowBookById(borrowId: borrowId);

      _borrowBook = response.data;

      _borrowBookState = BorrowBookState.loaded;
    } catch (e) {
      _borrowBookState = BorrowBookState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _borrowBook = null;
    _borrowBookState = BorrowBookState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
