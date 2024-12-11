import 'package:flutter/material.dart';
import '../api/book_api.dart';
import '../models/donation_book.dart';

enum DonationBooksState { initial, loading, loaded, error }

class DonationBooksProvider extends ChangeNotifier {
  List<DonationBook> _donationBooks = [];
  DonationBooksState _donationBooksState = DonationBooksState.initial;
  String? _errorMessage;
  bool _hasMoreData = true;
  int _currentPage = 1;

  List<DonationBook> get donationBooks => _donationBooks;
  DonationBooksState get donationBooksState => _donationBooksState;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  final BookApi donationService = BookApi();

  Future<void> fetchDonationBooks() async {
    if (!_hasMoreData) return;

    try {
      _donationBooksState = DonationBooksState.loading;
      notifyListeners();

      final DonationBooksResponse response =
          await donationService.getDonationBooks(page: _currentPage);

      if (response.data.isNotEmpty) {
        _donationBooks.addAll(response.data);
        _currentPage++;
        _hasMoreData = response.data.length >= response.pagination.itemsPerPage;
      } else {
        _hasMoreData = false;
      }

      _donationBooksState = DonationBooksState.loaded;
    } catch (e) {
      _donationBooksState = DonationBooksState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _donationBooks = [];
    _donationBooksState = DonationBooksState.initial;
    _errorMessage = null;
    _hasMoreData = true;
    _currentPage = 1;
    notifyListeners();
  }
}
