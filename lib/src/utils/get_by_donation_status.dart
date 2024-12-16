import 'package:flutter/material.dart';

import '../models/donation_book.dart';
import 'date_to_show_by_borrow_status.dart';

class GetByDonationStatus {
  static Image donationStatusImage(String status) {
    switch (status) {
      case "PENDING":
        return Image.asset('images/question.png', width: 126, height: 126);
      case "ACCEPTED":
        return Image.asset('images/approved.png', width: 126, height: 126);
      case "REJECTED":
        return Image.asset('images/cancel.png', width: 126, height: 126);
      case "CANCELLED":
        return Image.asset('images/cancel.png', width: 126, height: 126);
      default:
        return Image.asset('images/question.png', width: 126, height: 126);
    }
  }

  static String descByStatus(String status) {
    switch (status) {
      case "PENDING":
        return 'Mohon untuk memberikan buku kepada kami pada alamat dan waktu yang ditentukan.';
      case "ACCEPTED":
        return 'Terimakasih telah mendonasikan buku kepada kami, semoga akan selalu menjadi kebermanfaatan.';
      case "REJECTED":
        return 'Mohon maaf buku ditolak oleh admin';
      case "CANCELLED":
        return 'Buku ditolak oleh anda';
      default:
        return "Status pinjam buku tidak diketahui";
    }
  }

  static String titleByStatus(String status) {
    switch (status) {
      case "PENDING":
        return "Donasi buku sedang diproses";
      case "ACCEPTED":
        return "Donasi buku berhasil";
      case "REJECTED":
        return "Donasi buku ditolak";
      case "CANCELLED":
        return "Donasi buku dibatalkan";
      default:
        return "Status donasi buku tidak diketahui";
    }
  }

  static String statusByDonationStatus(String status) {
    switch (status) {
      case "PENDING":
        return "Diajukan";
      case "ACCEPTED":
        return "Diterima";
      case "REJECTED":
        return "Ditolak";
      case "CANCELLED":
        return "Dibatalkan";
      default:
        return "Diajukan";
    }
  }

  static String textByDonationDate(String status) {
    switch (status) {
      case "PENDING":
        return "Tanggal pengajuan: ";
      case "ACCEPTED":
        return "Tanggal diterima: ";
      case "REJECTED":
        return "Tanggal ditolak: ";
      case "CANCELLED":
        return "Tanggal dibatalkan: ";
      default:
        return "Tanggal pengajuan: ";
    }
  }

  static String dateToShowDonation(String status, DonationBook borrowBook) {
    switch (status) {
      case "PENDING":
        return DateToShow.parseDate(borrowBook.planSentAt.toString());
      case "ACCEPTED":
        return DateToShow.parseDate(borrowBook.acceptedAt.toString());
      case "REJECTED":
        return DateToShow.parseDate(borrowBook.rejectedAt.toString());
      case "CANCELLED":
        return DateToShow.parseDate(borrowBook.canceledAt.toString());
      default:
        return DateToShow.parseDate(borrowBook.planSentAt.toString());
    }
  }
}
