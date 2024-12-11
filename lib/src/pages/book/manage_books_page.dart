import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../consts/padding_sizes.dart';
import '../../models/borrow_books_model.dart';
import '../../models/donation_book.dart';
import '../../providers/borrow_books_provider.dart';
import '../../providers/donation_books_provider.dart';
import '../../utils/date_to_show_by_borrow_status.dart';
import '../../utils/get_network_image.dart';
import '../../utils/text_by_borrow_status.dart';
import '../../widgets/app_bar_builder.dart';

class ManageBooksPage extends StatefulWidget {
  const ManageBooksPage({super.key});

  @override
  State<ManageBooksPage> createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends State<ManageBooksPage> {
  ScrollController _borrowScrollController = ScrollController();
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
        return RefreshIndicator(
          onRefresh: borrowBooksProvider.refreshBorrowBooks,
          child: ListView.builder(
            controller: _borrowScrollController,
            itemCount: borrowBooksProvider.borrowBooks.length + 1,
            itemBuilder: (context, index) {
              if (index == borrowBooksProvider.borrowBooks.length) {
                return borrowBooksProvider.hasMoreData
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox.shrink();
              }
              final book = borrowBooksProvider.borrowBooks[index];
              return Column(
                children: [
                  Divider(color: AppColors.accentColor, height: 0.0),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/borrowBookDetail', arguments: {
                        'borrowBook': book,
                        'fromPage': '/manageBooks'
                      });
                    },
                    child: listTileBorrowBooks(book),
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
      }
    );
  }

  ListView donationSection() {
    final donationBooksProvider =
        Provider.of<DonationBooksProvider>(context, listen: false);
    print(donationBooksProvider.donationBooks.length);
    print(donationBooksProvider.donationBooksState);
    print(donationBooksProvider.errorMessage);

    return ListView.builder(
      itemCount: donationBooksProvider.donationBooks.length + 1,
      itemBuilder: (context, index) {
        if (index == donationBooksProvider.donationBooks.length) {
          return donationBooksProvider.hasMoreData
              ? Center(child: CircularProgressIndicator())
              : SizedBox.shrink();
        }
        final book = donationBooksProvider.donationBooks[index];
        return Column(
          children: [
            Divider(color: AppColors.accentColor, height: 0.0),
            InkWell(
              onTap: () {},
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
    );
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

  Column listTileDonationBooks(DonationBook book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.network(GetNetworkImage.getBooks(book.imageUrl), height: 100),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.categories.join(", "),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  Text(book.name)
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
              child: Text(statusByDonationStatus(book.status)),
            )
          ],
        ),
        // Text(book.id.toString()),
        Text(textByDonationDate(book.status)),
        Text(dateToShowDonation(book.status, book).toString()),
      ],
    );
  }

  Widget listTileBorrowBooks(BorrowBook book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: PaddingSizes.small),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.network(GetNetworkImage.getBooks(book.book.imageUrl),
                  height: 80),
              SizedBox(width: PaddingSizes.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.book.categories.join(", "),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: AppStyles.hintTextStyle,
                    ),
                    Text(
                      book.book.name,
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
                      WidgetStatePropertyAll(borrowStatusColor(book.status)),
                  backgroundColor: WidgetStatePropertyAll(
                      backgroundBorrowStatusColor(book.status)),
                ),
                child: Text(
                  GetByBorrowStatus.statusByBorrowStatus(book.status), style: AppStyles.plainLabelTextStyle,
                ),
              )
            ],
          ),
          // Text(book.id.toString()),
          SizedBox(height: PaddingSizes.small),
          Text(
            GetByBorrowStatus.textByBorrowStatus(book.status),
            style: AppStyles.hintTextStyle,
          ),
          Text(
            DateToShow.dateToShowByBorrowStatus(book.status, book).toString(),
            style: AppStyles.labelTextStyle,
          ),
          SizedBox(height: PaddingSizes.small),
        ],
      ),
    );
  }
}
