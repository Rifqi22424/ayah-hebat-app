import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/book_api.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../models/book_detail_model.dart';
import '../../models/borrow_books_model.dart';
import '../../providers/book_detail_provider.dart';
import '../../utils/get_network_image.dart';
import '../../widgets/app_bar_builder.dart';
import '../../widgets/button_builder.dart';
import '../../widgets/date_picker_row.dart';
import '../../widgets/snack_bar_builder.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  // Future<void> _selectDate(BuildContext context, String title,
  //     DateTime? initialDate, void Function(DateTime) onDatePicked) async {
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: initialDate ?? DateTime.now(),
  //       firstDate: DateTime.now(),
  //       lastDate: DateTime(2100));

  //   if (picked != null && picked != initialDate) {
  //     setState(() {
  //       onDatePicked(picked);
  //     });
  //   }
  // }
  final BookApi bookService = BookApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookDetailProvider>(context, listen: false);
      provider.fetchBookDetail(id: widget.bookId);
    });
  }

  showBorrowBookDialog(BuildContext context, BookDetail book) {
    DateTime? getBookDate;
    DateTime? returnBookDate;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pinjam Buku', style: AppStyles.heading2TextStyle),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
                _buildDetailRow('Judul Buku', book.name),
                // _buildDetailRow('Lokasi', book.location),
                DatePickerRow(
                    title: 'Tanggal mengambil buku',
                    date: getBookDate,
                    onDatePicked: (DateTime pickedDate) {
                      setState(() {
                        getBookDate = pickedDate;
                        if (returnBookDate != null &&
                            returnBookDate!.isBefore(getBookDate!)) {
                          returnBookDate = null;
                        }
                      });
                    }),
                DatePickerRow(
                    title: 'Tanggal mengembalikan buku',
                    date: returnBookDate,
                    minDate: getBookDate, // Tanggal minimum adalah getBookDate
                    onDatePicked: (DateTime pickedDate) {
                      setState(() {
                        if (pickedDate.isAfter(getBookDate!)) {
                          returnBookDate = pickedDate;
                        } else {
                          // Tampilkan pesan kesalahan
                          showCostumSnackBar(
                              context: context,
                              message:
                                  'Tanggal mengembalikan harus lebih dari tanggal mengambil!',
                              backgroundColor: AppColors.redColor);
                        }
                      });
                    }),
                ButtonBuilder(
                    onPressed: () async {
                      if (getBookDate == null || returnBookDate == null) {
                        showCostumSnackBar(
                            context: context,
                            message:
                                "Waktu pengambilan atau waktu pengembalian tidak boleh kosong");
                        return;
                      }

                      try {
                        BorrowBook response = await bookService.borrowABook(
                          book.id,
                          getBookDate!.toIso8601String(),
                          returnBookDate!.toIso8601String(),
                        );

                        Navigator.pop(context);

                        Navigator.pushNamed(context, '/borrowBookDetail',
                            arguments: {'borrowBook': response, 'fromPage': '/bookDetail'});
                      } catch (e) {
                        print(e.toString());
                        showCostumSnackBar(
                          context: context,
                          message:
                              'Gagal mengajukan peminjaman: ${e.toString()}',
                          backgroundColor: AppColors.redColor,
                        );
                      }
                    },
                    child: Text("Ajukan Peminjaman"))
              ],
            ),
          );
        });
      },
    );
  }

  // _buildGetDateRow(BuildContext context, String title, DateTime? date,
  //     void Function(DateTime) onDatePicked) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title, style: AppStyles.hintTextStyle),
  //       InkWell(
  //         onTap: () {
  //           _selectDate(context, title, date, onDatePicked);
  //         },
  //         child: Card(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(32),
  //           ),
  //           child: ListTile(
  //             title: Text(
  //               date == null
  //                   ? 'Pilih tanggal'
  //                   : '${date.day}/${date.month}/${date.year}',
  //               style: AppStyles.labelTextStyle,
  //             ),
  //             trailing:
  //                 Image.asset('images/calendar.png', width: 24, height: 24),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  _buildDetailRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.hintTextStyle),
        Text(value, style: AppStyles.labelTextStyle)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final provider = Provider.of<BookDetailProvider>(context);
    final bookDetail = provider.bookDetail;

    if (provider.bookDetailState == BookDetailState.loading ||
        provider.bookDetailState == BookDetailState.initial) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBarBuilder(
          title: "Detail Buku",
          showBackButton: true,
          onBackButtonPressed: () => Navigator.pop(context),
        ),
        body: Column(
          children: [
            Container(
              height: height * 0.45,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Image.network(
                GetNetworkImage.getBooks(bookDetail!.imageUrl),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(bookDetail.categories.join(', ')),
                  Text("Stock: ${bookDetail.stock.toString()}"),
                ],
              ),
            ),
            TabBar(
              tabs: [Tab(text: 'Cerita Singkat'), Tab(text: 'Komentar')],
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.accentColor,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookDetail.description),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: bookDetail.reviews.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {},
                              leading: Image.network(GetNetworkImage.getUploads(
                                  bookDetail
                                      .reviews[index].user.profile.photo)),
                              title: Text(
                                  bookDetail.reviews[index].user.profile.nama),
                              subtitle:
                                  Text(bookDetail.reviews[index].description),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 16.0, left: 16.0, right: 16.0, top: 8.0),
              child: ButtonBuilder(
                child: Text("Pinjam Buku"),
                onPressed: () async {
                  showBorrowBookDialog(context, bookDetail);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
