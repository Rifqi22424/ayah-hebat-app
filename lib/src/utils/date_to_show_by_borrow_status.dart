import '../models/borrow_books_model.dart';
import 'indonesia_month.dart';

class DateToShow {

    static String parseDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    String? day = IndonesiaMonth.getDayName(parsedDate.day);
    String dayNumber = parsedDate.day.toString();
    String? month = IndonesiaMonth.getMonthName(parsedDate.month);
    String year = parsedDate.year.toString();
    return '$day, $dayNumber  $month $year';
  }

   static String dateToShowByBorrowStatus(String status, BorrowBook borrowBook) {
    switch (status) {
      case "PENDING":
        return parseDate(borrowBook.submissionDate.toString());
      case "ALLOWED":
        return parseDate(borrowBook.plannedPickUpDate.toString());
      case "TAKEN":
        return parseDate(borrowBook.deadlineDate.toString());
      case "RETURNED":
        return parseDate(borrowBook.returnDate.toString());
      case "CANCELLED":
        return parseDate(borrowBook.cancelDate.toString());
      default:
        return parseDate(borrowBook.submissionDate.toString());
    }
  }
}