import 'package:flutter/material.dart';
import '../api/book_api.dart';
import '../models/book_model.dart';

enum BookState { initial, loading, loaded, error }

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  BookState _bookState = BookState.initial;
  String? _errorMessage;
  bool _hasMoreData = true;

  // Getters
  List<Book> get books => _books;
  BookState get bookState => _bookState;  
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  late BookApi bookApi = BookApi();

  // Fetch books dengan pagination, search, dan category
  Future<void> fetchBooks({
    int limit = 10,
    int offset = 0,
    String? search,
    String category = "semua",
    bool refresh = false,
  }) async {
    if (!hasMoreData) return;

    try {
      // Jika refresh true atau initial load, set state ke loading
      if (refresh || _bookState == BookState.initial) {
        _bookState = BookState.loading;
        notifyListeners();
      }

      // Get books dari API
      final response = await bookApi.getAllBooks(
        limit: limit,
        offset: offset,
        search: search,
        category: category,
      );

      // Jika refresh, clear list lama
      if (refresh) {
        _books = response;
      } else {
        // Append ke list yang ada
        _books = [..._books, ...response];
      }

      // Update hasMoreData berdasarkan jumlah data yang diterima
      _hasMoreData = response.length >= limit;

      // print("Offset: ${offset}");
      // print("Books: ${_books.length}");
      // print("Has more data: $_hasMoreData");

      _bookState = BookState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _bookState = BookState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> searchBooks({
    int limit = 10,
    int offset = 0,
    String? search,
    String category = "semua",
  }) async {
    if (bookState == BookState.loading) return;

    _bookState = BookState.loading;
    notifyListeners();

    try {
      // Get books dari API
      final response = await bookApi.getAllBooks(
        limit: limit,
        offset: offset,
        search: search,
        category: category,
      );

      // Clear list lama
      _books = response;

      // Update hasMoreData berdasarkan jumlah data yang diterima
      _hasMoreData = response.length >= limit;

      _bookState = BookState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _bookState = BookState.error;
    } finally {
      notifyListeners();
    }
  }

  // Refresh books (reset dan fetch dari awal)
  Future<void> refreshBooks({
    String? search,
    String? category,
  }) async {
    _books = [];
    _hasMoreData = true;
    await fetchBooks(
      offset: 0,
      search: search,
      category: category!,
      refresh: true,
    );
  }

  // Clear semua data
  void clearBooks() {
    _books = [];
    _bookState = BookState.initial;
    _errorMessage = null;
    _hasMoreData = true;
    notifyListeners();
  }

  // Update book di list jika ada perubahan
  // void updateBook(Book updatedBook) {
  //   final index = _books.indexWhere((book) => book.id == updatedBook.id);
  //   if (index != -1) {
  //     _books[index] = updatedBook;
  //     notifyListeners();
  //   }
  // }

  // Hapus book dari list
  // void removeBook(int bookId) {
  //   _books.removeWhere((book) => book.id == bookId);
  //   notifyListeners();
  // }

  // Get single book by id
  Book? getBookById(int id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }
}
