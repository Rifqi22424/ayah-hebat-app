import 'package:flutter/material.dart';
import '../api/book_api.dart';
import '../models/donation_book.dart';

enum DonationBookState { initial, loading, loaded, error }

class DonationBookProvider extends ChangeNotifier {
  DonationBook? _donationBook;
  DonationBookState _donationBookState = DonationBookState.initial;
  String? _errorMessage;

  DonationBook? get donationBook => _donationBook;
  DonationBookState get donationBookState => _donationBookState;
  String? get errorMessage => _errorMessage;

  final BookApi donationService = BookApi();

  Future<void> fetchDonationBookById({required int bookId}) async {
    try {
      _donationBook = null;

      _donationBookState = DonationBookState.loading;
      notifyListeners();

      final DonationBookByIdResponse response =
          await donationService.getDonationBookById(bookId: bookId);

      _donationBook = response.data;

      _donationBookState = DonationBookState.loaded;
    } catch (e) {
      _donationBookState = DonationBookState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _donationBook = null;
    _donationBookState = DonationBookState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
