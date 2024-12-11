import 'package:ayahhebat/src/api/book_api.dart';
import 'package:ayahhebat/src/models/book_model.dart';
import 'package:ayahhebat/src/providers/book_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([BookApi])
void main() {
  late MockBookApi mockBookApi;
  late BookProvider bookProvider;

  setUp(() {
    mockBookApi = MockBookApi();
    bookProvider = BookProvider()..bookApi = mockBookApi;
  });

  group('BookProvider Tests', () {
    test('Initial state should be BookState.initial', () {
      expect(bookProvider.bookState, BookState.initial);
    });

    test('fetchBooks should fetch and append books', () async {
      // Mock response
      final books = List.generate(
        10,
        (index) => Book(
            id: index,
            name: 'Book $index',
            stock: index,
            imageurl: '',
            categories: []),
      );
      when(mockBookApi.getAllBooks(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        search: anyNamed('search'),
        category: anyNamed('category'),
      )).thenAnswer((_) async => books);

      await bookProvider.fetchBooks();

      expect(bookProvider.books.length, 10);
      expect(bookProvider.bookState, BookState.loaded);
      expect(bookProvider.hasMoreData, true);
      verify(mockBookApi.getAllBooks(
        limit: 10,
        offset: 0,
        search: null,
        category: 'semua',
      )).called(1);
    });

    test('fetchBooks should handle errors', () async {
      when(mockBookApi.getAllBooks(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        search: anyNamed('search'),
        category: anyNamed('category'),
      )).thenThrow(Exception('Failed to fetch'));

      await bookProvider.fetchBooks();

      expect(bookProvider.books.isEmpty, true);
      expect(bookProvider.bookState, BookState.error);
      expect(bookProvider.errorMessage, isNotNull);
    });

    test('clearBooks should reset provider state', () {
      bookProvider.clearBooks();
      expect(bookProvider.books.isEmpty, true);
      expect(bookProvider.bookState, BookState.initial);
      expect(bookProvider.hasMoreData, true);
    });
  });
}
