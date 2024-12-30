import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/providers/office_address_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../providers/borrow_book_provider.dart';
import '../../utils/date_to_show_by_borrow_status.dart';
import '../../utils/get_network_image.dart';
import '../../utils/get_by_borrow_status.dart';
import '../../widgets/button_builder.dart';
import '../../widgets/manage_loading_shimmer.dart';

class BorrowBookDetailPage extends StatefulWidget {
  final String fromPage;
  final int borrowId;
  const BorrowBookDetailPage(
      {super.key, required this.borrowId, this.fromPage = "/manageBooks"});

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
    super.initState();
    fetchData();
  }

  fetchData() async {
    print("fetching data");
    await context
        .read<BorrowBookProvider>()
        .fetchBorrowBookById(borrowId: widget.borrowId);
    if (!mounted) return;
    await context.read<OfficeAddressProvider>().fetchOfficeAddresses();
  }

  @override
  void dispose() {
    super.dispose();
    context.read<BorrowBookProvider>().reset();
    context.read<OfficeAddressProvider>().refreshOfficeAddresses();
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
    return Scaffold(
      body: SafeArea(
        child: Consumer2<BorrowBookProvider, OfficeAddressProvider>(builder:
            (context, borrowBookProvider, officeAddressProvider, child) {
          switch (borrowBookProvider.borrowBookState) {
            case BorrowBookState.initial:
              return ManageLoadingShimmer();
            case BorrowBookState.loading:
              return ManageLoadingShimmer();
            case BorrowBookState.loaded:
              return Padding(
                padding: const EdgeInsets.only(
                    left: PaddingSizes.medium,
                    right: PaddingSizes.medium,
                    bottom: PaddingSizes.medium),
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () => fetchData(),
                  child: ListView(
                    children: [
                      Image.asset(
                        imagePathByStatus(
                            borrowBookProvider.borrowBook!.status),
                        width: 126,
                        height: 126,
                      ),
                      SizedBox(height: PaddingSizes.large),
                      Text(
                        titleByStatus(borrowBookProvider.borrowBook!.status),
                        style: AppStyles.headingTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Text(
                        descByStatus(borrowBookProvider.borrowBook!.status),
                        style: AppStyles.hintTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: PaddingSizes.large),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height / 3,
                            maxHeight: MediaQuery.of(context).size.height / 3),
                        child: Image.network(
                          GetNetworkImage.getBooks(
                              borrowBookProvider.borrowBook!.book.imageUrl),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: PaddingSizes.large),
                      Divider(color: AppColors.accentColor),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ID Peminjaman: ",
                              style: AppStyles.hintTextStyle),
                          Text(
                              '#${borrowBookProvider.borrowBook!.id.toString()}',
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
                                  borrowBookProvider.borrowBook!.status),
                              style: AppStyles.labelTextStyle),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              GetByBorrowStatus.textByBorrowStatus(
                                  borrowBookProvider.borrowBook!.status),
                              style: AppStyles.hintTextStyle),
                          Text(
                              DateToShow.dateToShowByBorrowStatus(
                                  borrowBookProvider.borrowBook!.status,
                                  borrowBookProvider.borrowBook!),
                              style: AppStyles.labelTextStyle),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Judul Buku: ", style: AppStyles.hintTextStyle),
                          SizedBox(width: PaddingSizes.doubleExtraLarge),
                          Expanded(
                              child: Text(
                                  borrowBookProvider.borrowBook!.book.name,
                                  textAlign: TextAlign.end,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: AppStyles.labelTextStyle)),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Alamat: ", style: AppStyles.hintTextStyle),
                          SizedBox(width: PaddingSizes.doubleExtraLarge),
                          if (officeAddressProvider.officeAddresses.isNotEmpty)
                            Expanded(
                              child: Text(
                                  textAlign: TextAlign.end,
                                  officeAddressProvider
                                      .officeAddresses[0].address,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: AppStyles.labelTextStyle),
                            )
                          else
                            Text("Loading...")
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
              );
            case BorrowBookState.error:
              return Center(
                child: TextButton(onPressed: fetchData, child: Text("Refresh")),
              );
            default:
              return Center(
                child: TextButton(onPressed: fetchData, child: Text("Refresh")),
              );
          }
        }),
      ),
    );
  }

  // Widget _buildBorrowDetailsShimmerEffect() {
  //   return Shimmer.fromColors(
  //     baseColor: Colors.grey[300]!,
  //     highlightColor: Colors.grey[100]!,
  //     child: Padding(
  //       padding: const EdgeInsets.only(
  //         left: PaddingSizes.medium,
  //         right: PaddingSizes.medium,
  //         bottom: PaddingSizes.medium,
  //       ),
  //       child: Column(
  //         children: [
  //           // Placeholder untuk image status
  //           Container(
  //             width: 126,
  //             height: 126,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(63),
  //             ),
  //           ),
  //           SizedBox(height: PaddingSizes.large),

  //           // Placeholder untuk title status
  //           Container(
  //             height: 20,
  //             width: 200,
  //             color: Colors.white,
  //           ),
  //           SizedBox(height: PaddingSizes.small),

  //           // Placeholder untuk description status
  //           Container(
  //             height: 14,
  //             width: 250,
  //             color: Colors.white,
  //           ),
  //           SizedBox(height: PaddingSizes.large),

  //           // Placeholder untuk gambar buku
  //           Expanded(
  //             child: Container(
  //               width: double.infinity,
  //               color: Colors.white,
  //             ),
  //           ),
  //           SizedBox(height: PaddingSizes.large),
  //           Divider(color: Colors.grey[300]),

  //           SizedBox(height: PaddingSizes.small),

  //           // Placeholder untuk rows informasi
  //           _buildShimmerRow(width1: 80, width2: 150),
  //           SizedBox(height: PaddingSizes.small),
  //           _buildShimmerRow(width1: 80, width2: 100),
  //           SizedBox(height: PaddingSizes.small),
  //           _buildShimmerRow(width1: 150, width2: 120),
  //           SizedBox(height: PaddingSizes.small),
  //           _buildShimmerRow(width1: 70, width2: 180),

  //           SizedBox(height: PaddingSizes.small),
  //           Divider(color: Colors.grey[300]),
  //           SizedBox(height: PaddingSizes.small),

  //           // Placeholder untuk tombol
  //           Container(
  //             height: 50,
  //             width: double.infinity,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(RoundedSizes.medium),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildShimmerRow({required double width1, required double width2}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Container(
  //         height: 12,
  //         width: width1,
  //         color: Colors.white,
  //       ),
  //       Container(
  //         height: 12,
  //         width: width2,
  //         color: Colors.white,
  //       ),
  //     ],
  //   );
  // }

  onSeeAllBorrowedBooksTapped(BuildContext context, String fromPage) {
    if (fromPage == "/bookDetail") {
      Navigator.pushReplacementNamed(context, "/manageBooks");
    } else {
      Navigator.of(context).pop();
    }
  }
}
