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
import '../../widgets/manage_loading_shimmer.dart';

class DonationBookDetailPage extends StatefulWidget {
  final int bookId;
  const DonationBookDetailPage({super.key, required this.bookId});

  @override
  State<DonationBookDetailPage> createState() => _DonationBookDetailPageState();
}

class _DonationBookDetailPageState extends State<DonationBookDetailPage> {
  String _address = 'Alamat belum tersedia';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    await context
        .read<DonationBookProvider>()
        .fetchDonationBookById(bookId: widget.bookId);
    if (!mounted) return;
    await context.read<OfficeAddressProvider>().fetchOfficeAddresses();
  }

  @override
  void dispose() {
    super.dispose();
    context.read<DonationBookProvider>().reset();
    context.read<OfficeAddressProvider>().refreshOfficeAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Consumer2<DonationBookProvider, OfficeAddressProvider>(
            builder:
                (context, donationBookProvider, officeAddressProvider, child) {
              // final DonationBook book = donationBookProvider.donationBook!;
              if (officeAddressProvider.officeAddresses.isNotEmpty) {
                _address = officeAddressProvider.officeAddresses[0].address;
              }
              switch (donationBookProvider.donationBookState) {
                case DonationBookState.initial:
                  return ManageLoadingShimmer();
                case DonationBookState.loading:
                  return ManageLoadingShimmer();
                case DonationBookState.loaded:
                  // return Expanded(
                  //     child: Container(
                  //   color: Colors.blue,
                  // ));

                  return Padding(
                    padding: const EdgeInsets.only(
                      left: PaddingSizes.medium,
                      right: PaddingSizes.medium,
                      bottom: PaddingSizes.medium,
                    ),
                    child: RefreshIndicator(
                      color: AppColors.primaryColor,
                      onRefresh: () async => fetchData(),
                      child: ListView(
                        // physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          GetByDonationStatus.donationStatusImage(
                              donationBookProvider.donationBook!.status),
                          SizedBox(height: PaddingSizes.large),
                          Text(
                            GetByDonationStatus.titleByStatus(
                                donationBookProvider.donationBook!.status),
                            style: AppStyles.headingTextStyle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: PaddingSizes.large),
                          Text(
                            GetByDonationStatus.descByStatus(
                                donationBookProvider.donationBook!.status),
                            style: AppStyles.hintTextStyle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: PaddingSizes.small),
                          TabBar(
                            tabs: [Tab(text: 'Gambar'), Tab(text: 'Detail')],
                            labelColor: AppColors.primaryColor,
                            unselectedLabelColor: AppColors.accentColor,
                            indicatorColor: AppColors.primaryColor,
                            indicatorSize: TabBarIndicatorSize.label,
                          ),
                          SizedBox(height: PaddingSizes.medium),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 3.5),
                              child: TabBarView(children: [
                                Image.network(
                                  fit: BoxFit.fitHeight,
                                  GetNetworkImage.getBooks(donationBookProvider
                                      .donationBook!.imageUrl),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          donationBookProvider.donationBook!.name,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.labelTextStyle),
                                      SizedBox(height: PaddingSizes.small),
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
                              ])),
                          SizedBox(height: PaddingSizes.large),
                          Divider(color: AppColors.accentColor),
                          SizedBox(height: PaddingSizes.small),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("ID Buku: ", style: AppStyles.hintTextStyle),
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
                                      donationBookProvider
                                          .donationBook!.status),
                                  style: AppStyles.labelTextStyle),
                            ],
                          ),
                          SizedBox(height: PaddingSizes.small),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  GetByDonationStatus.textByDonationDate(
                                      donationBookProvider
                                          .donationBook!.status),
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
                                    _address,
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
                    ),
                  );
                case DonationBookState.error:
                  return Center(
                    child: TextButton(
                        onPressed: fetchData, child: Text("Refresh")),
                  );
                default:
                  return Center(
                    child: TextButton(
                        onPressed: fetchData, child: Text("Refresh")),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
