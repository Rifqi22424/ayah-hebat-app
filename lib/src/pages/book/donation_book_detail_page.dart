import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../providers/donation_book_provider.dart';
import '../../providers/office_address_provider.dart';
import '../../utils/get_by_donation_status.dart';
import '../../utils/get_network_image.dart';
import '../../widgets/button_builder.dart';

class DonationBookDetailPage extends StatefulWidget {
  final int bookId;
  const DonationBookDetailPage({super.key, required this.bookId});

  @override
  State<DonationBookDetailPage> createState() => _DonationBookDetailPageState();
}

class _DonationBookDetailPageState extends State<DonationBookDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<DonationBookProvider>()
        .fetchDonationBookById(bookId: widget.bookId);
    context.read<OfficeAddressProvider>().fetchOfficeAddresses();
  }

  @override
  void dispose() {
    super.dispose();
    context.read<DonationBookProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<DonationBookProvider, OfficeAddressProvider>(
          builder:
              (context, donationBookProvider, officeAddressProvider, child) {
            // final DonationBook book = donationBookProvider.donationBook!;
            switch (donationBookProvider.donationBookState) {
              case DonationBookState.initial:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case DonationBookState.loading:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case DonationBookState.loaded:
                return Padding(
                  padding: const EdgeInsets.only(
                    left: PaddingSizes.medium,
                    right: PaddingSizes.medium,
                    bottom: PaddingSizes.medium,
                  ),
                  child: Column(
                    children: [
                      GetByDonationStatus.donationStatusImage(
                          donationBookProvider.donationBook!.status),
                      SizedBox(height: PaddingSizes.large),
                      Text(
                        GetByDonationStatus.titleByStatus(
                            donationBookProvider.donationBook!.status),
                        style: AppStyles.headingTextStyle,
                      ),
                      SizedBox(height: PaddingSizes.large),
                      Text(
                        GetByDonationStatus.descByStatus(
                            donationBookProvider.donationBook!.status),
                        style: AppStyles.hintTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: PaddingSizes.large),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Image.network(
                                // width: 80,
                                // height: 80,
                                // fit: BoxFit.cover,
                                GetNetworkImage.getBooks(donationBookProvider
                                    .donationBook!.imageUrl),
                              ),
                            ),
                            SizedBox(width: PaddingSizes.medium),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(donationBookProvider.donationBook!.name,
                                      textAlign: TextAlign.center,
                                      style: AppStyles.labelTextStyle),
                                  Text(
                                      donationBookProvider
                                          .donationBook!.description,
                                      textAlign: TextAlign.justify,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: AppStyles.hintTextStyle),
                                ],
                              ),
                            ),
                          ],
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
                              '#${donationBookProvider.donationBook!.id.toString()}',
                              style: AppStyles.labelTextStyle),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status: ", style: AppStyles.hintTextStyle),
                          Text(
                              GetByDonationStatus.statusByDonationStatus(
                                  donationBookProvider.donationBook!.status),
                              style: AppStyles.labelTextStyle),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              GetByDonationStatus.textByDonationDate(
                                  donationBookProvider.donationBook!.status),
                              style: AppStyles.hintTextStyle),
                          Text(
                              GetByDonationStatus.dateToShowDonation(
                                  donationBookProvider.donationBook!.status,
                                  donationBookProvider.donationBook!),
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text("Judul Buku: ", style: AppStyles.hintTextStyle),
                      //     SizedBox(width: PaddingSizes.doubleExtraLarge),
                      //     Expanded(
                      //         child: Text('widget.borrowBook.book.name',
                      //             textAlign: TextAlign.end,
                      //             softWrap: true,
                      //             overflow: TextOverflow.visible,
                      //             style: AppStyles.labelTextStyle)),
                      //   ],
                      // ),
                      // SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Alamat: ", style: AppStyles.hintTextStyle),
                          SizedBox(width: PaddingSizes.doubleExtraLarge),
                          // if (officeAddressProvider.officeAddresses.isNotEmpty)
                          Expanded(
                            child: Text(
                                textAlign: TextAlign.end,
                                officeAddressProvider
                                    .officeAddresses[0].address,
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
                        child: Text("Lihat semua buku yang anda donasikan"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              case DonationBookState.error:
                return Center(
                  child: Text('error'),
                );
              default:
                return Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}
