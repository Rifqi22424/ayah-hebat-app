import '../models/borrow_books_model.dart';
import 'indonesia_month.dart';

class DateToShow {

    static String parseDate(String date) {
    DateTime parsedDate = parseDateWithTimeZone(date);
    String? day = IndonesiaMonth.getDayName(parsedDate);
    String dayNumber = parsedDate.day.toString();
    String? month = IndonesiaMonth.getMonthName(parsedDate.month);
    String year = parsedDate.year.toString();
    return '$day, $dayNumber  $month $year';
  }

  static DateTime parseDateWithTimeZone(String date) {
  // Parse the date in UTC
  DateTime parsedDate = DateTime.parse(date).toUtc();
  
  // Adjust the parsed UTC date to the local timezone (Indonesia: UTC+7)
  DateTime indonesiaDate = parsedDate.add(Duration(hours: 7));

  return indonesiaDate;
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