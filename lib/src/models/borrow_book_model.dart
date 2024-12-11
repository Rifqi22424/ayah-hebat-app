// class BorrowABookResponse {
//   final int idPeminjaman;
//   final String bookName;
//   final String imageUrl;
//   final DateTime submissionDate;
//   final DateTime deadlineDate;
//   final String from;
//   final String to;

//   BorrowABookResponse({
//     required this.idPeminjaman,
//     required this.bookName,
//     required this.imageUrl,
//     required this.submissionDate,
//     required this.deadlineDate,
//     required this.from,
//     required this.to,
//   });

//   factory BorrowABookResponse.fromJson(Map<String, dynamic> json) {
//     return BorrowABookResponse(
//       idPeminjaman: json['idPeminjaman'] as int,
//       bookName: json['bookName'] as String,
//       imageUrl: json['imageUrl'] as String,
//       submissionDate: DateTime.parse(json['submissionDate'] as String),
//       deadlineDate: DateTime.parse(json['deadlineDate'] as String),
//       from: json['from'] as String,
//       to: json['to'] as String,
//     );
//   }

//   @override
//   String toString() {
//     return 'BorrowBookResponse(idPeminjaman: $idPeminjaman, bookName: $bookName, imageUrl: $imageUrl, submissionDate: $submissionDate, deadlineDate: $deadlineDate, from: $from, to: $to)';
//   }
// }
