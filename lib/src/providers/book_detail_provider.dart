import 'package:ayahhebat/src/api/book_detail_api.dart';
import 'package:flutter/material.dart';

import '../models/book_detail_model.dart';

enum BookDetailState { initial, loading, loaded, error }

class BookDetailProvider extends ChangeNotifier {
  BookDetail? _bookDetail;
  BookDetailState _bookDetailState = BookDetailState.initial;
  String? _errorMessage;

  final BookDetailApi _bookDetailApi = BookDetailApi();

  BookDetail? get bookDetail => _bookDetail;
  BookDetailState get bookDetailState => _bookDetailState;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBookDetail({required int id}) async {
    try {
      _bookDetailState = BookDetailState.loading;
      notifyListeners();

      _bookDetail = await _bookDetailApi.getBookById(id: id);
      _bookDetailState = BookDetailState.loaded;
      _errorMessage = null;
    } catch (e) {
      _bookDetail = null;
      _bookDetailState = BookDetailState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearBookDetail() {
    _bookDetail = null;
    _bookDetailState = BookDetailState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
