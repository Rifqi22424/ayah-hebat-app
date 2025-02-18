import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/widgets/infaq_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../consts/padding_sizes.dart';
import '../../providers/infaq_provider.dart';
import '../../widgets/app_bar_left_builder.dart';
import '../../widgets/button_builder.dart';

class InfaqPage extends StatefulWidget {
  const InfaqPage({super.key});

  @override
  State<InfaqPage> createState() => _InfaqPageState();
}

class _InfaqPageState extends State<InfaqPage> {
  final ScrollController _infaqScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    refreshInfaqsAndTotalInfaq();
    _infaqScrollController.addListener(() {
      if (_infaqScrollController.position.pixels ==
          _infaqScrollController.position.maxScrollExtent) {
        context.read<InfaqProvider>().fetchInfaqs();
        print("fetch infaq");
      }
    });
  }

  void refreshInfaqsAndTotalInfaq() async {
    context.read<InfaqProvider>().refreshInfaqs();
    context.read<InfaqProvider>().refreshTotalInfaq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarLeftBuilder(
          title: "Wadaah", description: "Diskusi tentang keluarga"),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          refreshInfaqsAndTotalInfaq();
        },
        child: Padding(
          padding: const EdgeInsets.only(
            top: PaddingSizes.small,
            left: PaddingSizes.medium,
            right: PaddingSizes.medium,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(PaddingSizes.medium),
                        color: AppColors.grey,
                      ),
                      padding: EdgeInsets.only(
                          left: PaddingSizes.medium,
                          top: PaddingSizes.medium,
                          bottom: PaddingSizes.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Iuran Anda",
                              style: AppStyles.hintTextStyle),
                          SizedBox(height: PaddingSizes.extrasmall),
                          Consumer<InfaqProvider>(
                            builder: (context, value, child) {
                              switch (value.totalAmountinfaqState) {
                                case TotalInfaqState.initial:
                                  return CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  );
                                case TotalInfaqState.loading:
                                  return CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  );
                                case TotalInfaqState.loaded:
                                  return Text(
                                      "Rp. ${formatNumber(value.totalInfaq)}",
                                      style: AppStyles.heading2TextStyle);
                                case TotalInfaqState.error:
                                  return TextButton(
                                    onPressed: () => context
                                        .read<InfaqProvider>()
                                        .fetchTotalInfaq(),
                                    child: Text("Retry"),
                                    style: TextButton.styleFrom(
                                        foregroundColor: AppColors.redColor,
                                        disabledBackgroundColor:
                                            AppColors.halfRedColor),
                                  );
                                default:
                                  return CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: PaddingSizes.small),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(PaddingSizes.medium),
                        color: AppColors.grey,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: PaddingSizes.medium,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Waqaf Dana Abadi",
                                      style: AppStyles.heading2TextStyle),
                                  SizedBox(height: PaddingSizes.small),
                                  Text(
                                      "Investasi Abadi untuk Masa Depan Gemilang",
                                      style: AppStyles.hintTextStyle)
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomRight:
                                          Radius.circular(PaddingSizes.medium)),
                                  child: Image.asset(
                                      "images/wadaah_ornament.png"))),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: PaddingSizes.small),
              ButtonBuilder(
                  onPressed: () async =>
                      Navigator.pushNamed(context, '/sendInfaq'),
                  child: Text("Iuran Sekarang")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("List Iuran", style: AppStyles.heading3BoldTextStyle),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/infaqHistory');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textColor,
                        disabledForegroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(PaddingSizes.medium)),
                      ),
                      child: Text("Lihat semua")),
                ],
              ),
              Consumer<InfaqProvider>(
                builder: (context, value, child) {
                  print("InfaqState: ${value.state}");

                  if ((value.state == InfaqState.initial &&
                          value.infaqs.isEmpty) ||
                      (value.state == InfaqState.loading &&
                          value.infaqs.isEmpty)) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  }

                  if (value.state == InfaqState.error) {
                    return Center(
                      child: TextButton(
                          onPressed: () =>
                              context.read<InfaqProvider>().refreshInfaqs(),
                          child: Text("Retry"),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.redColor,
                              disabledBackgroundColor: AppColors.halfRedColor)),
                    );
                  }

                  if (value.state == InfaqState.loaded &&
                      value.infaqs.isEmpty) {
                    return Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: PaddingSizes.small),
                      child: ListView(
                        children: [Center(child: Text("Belum ada infaq"))],
                      ),
                    ));
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: PaddingSizes.small),
                      child: ListView.builder(
                        controller: _infaqScrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: value.infaqs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == value.infaqs.length) {
                            if (value.hasMoreData) {
                              value.fetchInfaqs();
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }
                          return InfaqListTile(infaq: value.infaqs[index]);
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // infaqListTile(Infaq infaq) {
  //   DateTime date = DateTime.parse(infaq.updatedAt);
  //   DateTime localDate = date.toLocal();
  //   String formattedDate = DateFormat('dd MMM yyyy • HH:mm').format(localDate);
  //   print(formattedDate);

  //   return InkWell(
  //     onTap: () => Navigator.pushNamed(context, '/detailInfaq', arguments: {
  //       'id': infaq.id,
  //     }),
  //     child: Column(
  //       children: [
  //         SizedBox(height: PaddingSizes.small),
  //         Row(
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   border: Border.all(color: AppColors.darkGrey)),
  //               child: Padding(
  //                   padding: EdgeInsets.all(8),
  //                   child: Icon(Icons.monetization_on_outlined)),
  //             ),
  //             SizedBox(width: PaddingSizes.small),
  //             Expanded(
  //                 child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 SizedBox(width: PaddingSizes.small),
  //                 Text("Infaq", style: AppStyles.heading3BoldTextStyle),
  //                 // SizedBox(height: PaddingSizes.small),
  //                 SizedBox(height: PaddingSizes.extrasmall),
  //                 Text("Rp. ${formatNumber(infaq.amount)}",
  //                     style: AppStyles.hintTextStyle),
  //                 SizedBox(height: PaddingSizes.doubleExtraSmall),
  //                 Row(
  //                   children: [
  //                     // Text(
  //                     //     "${localDate.day} ${IndonesiaMonth.getMonthName(localDate.month)} ${localDate.year}"),
  //                     // Text("${localDate.hour}:${localDate.minute}"),
  //                     Text(formattedDate, style: AppStyles.hintTextStyle),
  //                   ],
  //                 ),
  //               ],
  //             )),
  //             TextButton(
  //               onPressed: () {},
  //               style: ButtonStyle(
  //                 shape: MaterialStatePropertyAll(RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(100))),
  //                 foregroundColor: MaterialStatePropertyAll(
  //                     ColorByInfaqStatus.getColor(infaq.status)),
  //                 backgroundColor: MaterialStatePropertyAll(
  //                     ColorByInfaqStatus.getBackgroundColor(infaq.status)),
  //               ),
  //               child: Text(
  //                 infaq.status.capitalize(),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: PaddingSizes.small),
  //         Divider(
  //           color: AppColors.grey,
  //           height: 2,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
