import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/providers/office_address_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../models/borrow_books_model.dart';
import '../../utils/date_to_show_by_borrow_status.dart';
import '../../utils/get_network_image.dart';
import '../../utils/text_by_borrow_status.dart';
import '../../widgets/button_builder.dart';

class BorrowBookDetailPage extends StatefulWidget {
  final BorrowBook borrowBook;
  final String fromPage;
  const BorrowBookDetailPage(
      {super.key, required this.borrowBook, this.fromPage = "/manageBooks"});

  @override
  State<BorrowBookDetailPage> createState() => _BorrowBookDetailPageState();
}

class _BorrowBookDetailPageState extends State<BorrowBookDetailPage> {
  String parseDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final officeAddressProvider =
          Provider.of<OfficeAddressProvider>(context, listen: false);
      officeAddressProvider.fetchOfficeAddresses();
    });
    super.initState();
  }

  String imagePathByStatus(String status) {
    switch (status) {
      case "PENDING":
        return 'images/question.png';
      case "ALLOWED":
        return 'images/approved.png';
      case "TAKEN":
        return 'images/alert.png';
      case "RETURNED":
        return 'images/approved.png';
      case "CANCELLED":
        return 'images/cancel.png';
      default:
        return 'images/question.png';
    }
  }

  String titleByStatus(String status) {
    switch (status) {
      case "PENDING":
        return 'Pinjam Buku Diajukan';
      case "ALLOWED":
        return 'Pinjam Buku Disetujui';
      case "TAKEN":
        return 'Buku Sedang Dipinjam';
      case "RETURNED":
        return 'Buku telah Dipinjam';
      case "CANCELLED":
        return 'Pinjam Buku Gagal';
      default:
        return 'Pinjam Buku Diajukan';
    }
  }

  String descByStatus(String status) {
    switch (status) {
      case "PENDING":
        return 'Mohon untuk menunggu hingga admin menyetujui peminjaman buku anda.';
      case "ALLOWED":
        return 'Silahkan untuk mengambil buku di waktu dan tempat yang telah ditentukan.';
      case "TAKEN":
        return 'Mohon untuk mengembalikan buku ke tempat yang telah ditentukan dengan tepat waktu.';
      case "RETURNED":
        return 'Terimakasih telah meminjam buku.';
      case "CANCELLED":
        return 'Mohon maaf pinjam buku tidak dapat dipinjam.';
      default:
        return 'Mohon untuk menunggu hingga admin menyetujui peminjaman buku anda.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfficeAddressProvider>(
        builder: (context, officeAddressProvider, child) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
                left: PaddingSizes.medium,
                right: PaddingSizes.medium,
                bottom: PaddingSizes.medium),
            child: Column(
              children: [
                Image.asset(
                  imagePathByStatus(widget.borrowBook.status),
                  width: 126,
                  height: 126,
                ),
                SizedBox(height: PaddingSizes.large),
                Text(
                  titleByStatus(widget.borrowBook.status),
                  style: AppStyles.headingTextStyle,
                ),

                SizedBox(height: PaddingSizes.small),
                Text(
                  descByStatus(widget.borrowBook.status),
                  style: AppStyles.hintTextStyle,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: PaddingSizes.large),
                Expanded(
                  child: Image.network(
                    GetNetworkImage.getBooks(widget.borrowBook.book.imageUrl),
                  ),
                ),
                SizedBox(height: PaddingSizes.large),
                Divider(color: AppColors.accentColor),
                SizedBox(height: PaddingSizes.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ID Peminjaman: ", style: AppStyles.hintTextStyle),
                    Text('#${widget.borrowBook.id.toString()}',
                        style: AppStyles.labelTextStyle),
                  ],
                ),
                SizedBox(height: PaddingSizes.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Status: ", style: AppStyles.hintTextStyle),
                    Text(
                        GetByBorrowStatus.statusByBorrowStatus(
                            widget.borrowBook.status),
                        style: AppStyles.labelTextStyle),
                  ],
                ),
                SizedBox(height: PaddingSizes.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        GetByBorrowStatus.textByBorrowStatus(
                            widget.borrowBook.status),
                        style: AppStyles.hintTextStyle),
                    Text(
                        DateToShow.dateToShowByBorrowStatus(
                            widget.borrowBook.status, widget.borrowBook),
                        style: AppStyles.labelTextStyle),
                  ],
                ),
                SizedBox(height: PaddingSizes.small),
                // Row(
                //   children: [
                //     Text("Jumlah Buku: "),
                //     Text(widget.borrowBook.quantity.toString()),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Judul Buku: ", style: AppStyles.hintTextStyle),
                    SizedBox(width: PaddingSizes.doubleExtraLarge),
                    Expanded(
                        child: Text(widget.borrowBook.book.name,
                            textAlign: TextAlign.end,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: AppStyles.labelTextStyle)),
                  ],
                ),
                SizedBox(height: PaddingSizes.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Alamat: ", style: AppStyles.hintTextStyle),
                    SizedBox(width: PaddingSizes.doubleExtraLarge),
                    if (officeAddressProvider.officeAddresses.isNotEmpty)
                      Expanded(
                        child: Text(
                            textAlign: TextAlign.end,
                            officeAddressProvider.officeAddresses[0].address,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: AppStyles.labelTextStyle),
                      ),
                  ],
                ),
                SizedBox(height: PaddingSizes.small),
                Divider(color: AppColors.accentColor),
                SizedBox(height: PaddingSizes.small),
                ButtonBuilder(
                  child: Text("Lihat semua buku yang dipinjam"),
                  onPressed: () async {
                    onSeeAllBorrowedBooksTapped(context, widget.fromPage);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  onSeeAllBorrowedBooksTapped(BuildContext context, String fromPage) {
    if (fromPage == "/bookDetail") {
      Navigator.pushReplacementNamed(context, "/manageBooks");
    } else {
      Navigator.of(context).pop();
    }
  }
}
