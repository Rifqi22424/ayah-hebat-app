import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../consts/padding_sizes.dart';
import '../../models/borrow_books_model.dart';
import '../../models/donation_book.dart';
import '../../providers/borrow_books_provider.dart';
import '../../providers/donation_books_provider.dart';
import '../../utils/date_to_show_by_borrow_status.dart';
import '../../utils/get_network_image.dart';
import '../../utils/get_by_borrow_status.dart';
import '../../widgets/app_bar_builder.dart';

class ManageBooksPage extends StatefulWidget {
  const ManageBooksPage({super.key});

  @override
  State<ManageBooksPage> createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends State<ManageBooksPage> {
  final ScrollController _borrowScrollController = ScrollController();
  final ScrollController _donationScrollController = ScrollController();

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    final borrowBooksProvider =
        Provider.of<BorrowBooksProvider>(context, listen: false);
    final donationBooksProvider =
        Provider.of<DonationBooksProvider>(context, listen: false);
    borrowBooksProvider.fetchBorrowBooks();
    donationBooksProvider.fetchDonationBooks();

    _borrowScrollController.addListener(() {
      if (_borrowScrollController.position.pixels ==
          _borrowScrollController.position.maxScrollExtent) {
        borrowBooksProvider.fetchBorrowBooks();
      }
    });

    _donationScrollController.addListener(() {
      if (_donationScrollController.position.pixels ==
          _donationScrollController.position.maxScrollExtent) {
        donationBooksProvider.fetchDonationBooks();
      }
    });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBarBuilder(
          title: "Manajemen Buku",
          showBackButton: true,
          onBackButtonPressed: () {
            Navigator.of(context).pop();
          },
        ),
        body: Column(
          children: [
            TabBar(
              tabs: [Tab(text: "Peminjaman"), Tab(text: "Donasi")],
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.accentColor,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
            ),
            Expanded(
              child: TabBarView(children: [
                borrowSection(),
                donationSection(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget borrowSection() {
    return Consumer<BorrowBooksProvider>(
        builder: (context, borrowBooksProvider, child) {
      print("Borrow State: ${borrowBooksProvider.borrowBooksState}");

      if (borrowBooksProvider.borrowBooksState == BorrowBooksState.initial &&
              borrowBooksProvider.borrowBooks.isEmpty ||
          borrowBooksProvider.borrowBooksState == BorrowBooksState.loading &&
              borrowBooksProvider.borrowBooks.isEmpty) {
        return _buildManageShimmerEffect();
      }

      if (borrowBooksProvider.borrowBooksState == BorrowBooksState.error) {
        return Center(
          child: TextButton(
              onPressed: borrowBooksProvider.refreshBorrowBooks,
              child: Text("Refresh")),
        );
      }

      if (borrowBooksProvider.borrowBooks.isEmpty) {
        return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: borrowBooksProvider.refreshBorrowBooks,
            child: Column(
              children: [
                Expanded(
                    child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 3),
                        Text(
                          "Silahkan untuk meminjam buku terlebih dahulu",
                          style: AppStyles.labelTextStyle,
                        ),
                      ],
                    )
                  ],
                ))
              ],
            ));
      }

      return RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: borrowBooksProvider.refreshBorrowBooks,
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _borrowScrollController,
          itemCount: borrowBooksProvider.borrowBooks.length + 1,
          itemBuilder: (context, index) {
            if (index == borrowBooksProvider.borrowBooks.length) {
              return borrowBooksProvider.hasMoreData
                  ? Center(
                      child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ))
                  : SizedBox.shrink();
            }
            final borrow = borrowBooksProvider.borrowBooks[index];
            return Column(
              children: [
                Divider(color: AppColors.accentColor, height: 0.0),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/borrowBookDetail',
                        arguments: {
                          'borrowId': borrow.id,
                          'fromPage': '/manageBooks'
                        });
                  },
                  child: listTileBorrowBooks(borrow),
                )
              ],
            );
          },
        ),
      );
    });
  }

  Widget donationSection() {
    return Consumer<DonationBooksProvider>(
        builder: (context, donationBooksProvider, child) {
      print("DonationBooksState: ${donationBooksProvider.donationBooksState}");
      if (donationBooksProvider.donationBooksState ==
                  DonationBooksState.initial &&
              donationBooksProvider.donationBooks.isEmpty ||
          donationBooksProvider.donationBooksState ==
                  DonationBooksState.loading &&
              donationBooksProvider.donationBooks.isEmpty) {
        print("Loading triggered");
        return _buildManageShimmerEffect();
      }
      if (donationBooksProvider.donationBooksState ==
          DonationBooksState.error) {
        return Center(
          child: TextButton(
              onPressed: donationBooksProvider.refreshDonationBooks,
              child: Text("Refresh")),
        );
      }

      if (donationBooksProvider.donationBooks.isEmpty) {
        return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: donationBooksProvider.refreshDonationBooks,
            child: Column(
              children: [
                Expanded(
                    child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 3),
                        Text(
                          "Silahkan untuk mendonasikan buku terlebih dahulu",
                          style: AppStyles.labelTextStyle,
                        ),
                      ],
                    )
                  ],
                ))
              ],
            ));
      }
      // return _buildManageShimmerEffect();
      return RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: donationBooksProvider.refreshDonationBooks,
        child: ListView.builder(
          controller: _donationScrollController,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: donationBooksProvider.donationBooks.length + 1,
          itemBuilder: (context, index) {
            if (index == donationBooksProvider.donationBooks.length) {
              return donationBooksProvider.hasMoreData
                  ? Center(
                      child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ))
                  : SizedBox.shrink();
            }
            final book = donationBooksProvider.donationBooks[index];
            return Column(
              children: [
                Divider(color: AppColors.accentColor, height: 0.0),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/donationBookDetail',
                        arguments: {'bookId': book.id});
                  },
                  child: listTileDonationBooks(book),
                )
              ],
            );

            // return Row(
            //   children: [
            //     Text(book.book.name),
            //     Text(book.status),
            //   ],
            // );
          },
        ),
      );
    });
  }

  Color borrowStatusColor(String status) {
    switch (status) {
      case "PENDING":
        return AppColors.primaryColor;
      case "ALLOWED":
        return AppColors.greenColor;
      case "TAKEN":
        return AppColors.greenColor;
      case "RETURNED":
        return AppColors.greenColor;
      case "CANCELLED":
        return AppColors.redColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Color donationStatusColor(String status) {
    switch (status) {
      case "PENDING":
        return AppColors.primaryColor;
      case "ACCEPTED":
        return AppColors.greenColor;
      case "REJECTED":
        return AppColors.redColor;
      case "CANCELLED":
        return AppColors.redColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Color backgroundBorrowStatusColor(String status) {
    switch (status) {
      case "PENDING":
        return AppColors.lightPrimaryColor;
      case "ALLOWED":
        return AppColors.lightGreenColor;
      case "TAKEN":
        return AppColors.lightGreenColor;
      case "RETURNED":
        return AppColors.lightGreenColor;
      case "CANCELLED":
        return AppColors.lightRedColor;
      default:
        return AppColors.lightPrimaryColor;
    }
  }

  Color backgroundDonationStatusColor(String status) {
    switch (status) {
      case "PENDING":
        return AppColors.lightPrimaryColor;
      case "ACCEPTED":
        return AppColors.lightGreenColor;
      case "REJECTED":
        return AppColors.lightRedColor;
      case "CANCELLED":
        return AppColors.lightRedColor;
      default:
        return AppColors.lightPrimaryColor;
    }
  }

  String dateToShowDonation(String status, DonationBook borrowBook) {
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

  textByDonationDate(String status) {
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

  statusByDonationStatus(String status) {
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

  listTileDonationBooks(DonationBook book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: PaddingSizes.small),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.network(
                GetNetworkImage.getBooks(book.imageUrl),
                height: 80,
                width: 50,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                      width: 50,
                      height: 80,
                      // color: AppColors.grey,
                      child: Center(
                          child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      )));
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 80,
                    color: AppColors.darkGrey,
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.whiteColor,
                    ),
                  );
                },
              ),
              SizedBox(width: PaddingSizes.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.categories.join(", "),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: AppStyles.hintTextStyle,
                    ),
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.labelBoldTextStyle,
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
                  foregroundColor:
                      WidgetStatePropertyAll(donationStatusColor(book.status)),
                  backgroundColor: WidgetStatePropertyAll(
                      backgroundDonationStatusColor(book.status)),
                ),
                child: Text(
                  statusByDonationStatus(book.status),
                  style: AppStyles.plainLabelTextStyle,
                ),
              )
            ],
          ),
          // Text(book.id.toString()),
          SizedBox(height: PaddingSizes.small),
          Text(
            textByDonationDate(book.status),
            style: AppStyles.hintTextStyle,
          ),
          Text(
            dateToShowDonation(book.status, book).toString(),
            style: AppStyles.labelTextStyle,
          ),
          SizedBox(height: PaddingSizes.small),
        ],
      ),
    );
  }

  Widget _buildManageShimmerEffect() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Placeholder untuk gambar buku
                    Container(
                      width: 50,
                      height: 80,
                      color: Colors.white,
                    ),
                    SizedBox(width: 16),
                    // Placeholder untuk teks detail buku
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 10,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          SizedBox(height: 6),
                          Container(
                            height: 12,
                            width: 150,
                            color: Colors.white,
                          ),
                          SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 100,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    // Placeholder untuk tombol status
                    Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 10,
                  width: 150,
                  color: Colors.white,
                ),
                SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 100,
                  color: Colors.white,
                ),
                SizedBox(width: 16),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [

                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listTileBorrowBooks(BorrowBook borrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: PaddingSizes.small),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.network(
                GetNetworkImage.getBooks(borrow.book.imageUrl),
                height: 80,
                width: 50,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 50,
                    height: 80,
                    // color: AppColors.grey,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    )),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 80,
                    color: AppColors.darkGrey,
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.whiteColor,
                    ),
                  );
                },
              ),
              SizedBox(width: PaddingSizes.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      borrow.book.categories.join(", "),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: AppStyles.hintTextStyle,
                    ),
                    Text(
                      borrow.book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.labelBoldTextStyle,
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
                  foregroundColor:
                      WidgetStatePropertyAll(borrowStatusColor(borrow.status)),
                  backgroundColor: WidgetStatePropertyAll(
                      backgroundBorrowStatusColor(borrow.status)),
                ),
                child: Text(
                  GetByBorrowStatus.statusByBorrowStatus(borrow.status),
                  style: AppStyles.plainLabelTextStyle,
                ),
              )
            ],
          ),
          // Text(book.id.toString()),
          SizedBox(height: PaddingSizes.small),
          Text(
            GetByBorrowStatus.textByBorrowStatus(borrow.status),
            style: AppStyles.hintTextStyle,
          ),
          Text(
            DateToShow.dateToShowByBorrowStatus(borrow.status, borrow)
                .toString(),
            style: AppStyles.labelTextStyle,
          ),
          SizedBox(height: PaddingSizes.small),
        ],
      ),
    );
  }
}
