import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/widgets/alms_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../consts/padding_sizes.dart';
import '../../providers/alms_provider.dart';
import '../../widgets/app_bar_left_builder.dart';
import '../../widgets/button_builder.dart';

class AlmsPage extends StatefulWidget {
  const AlmsPage({super.key});

  @override
  State<AlmsPage> createState() => _AlmsPageState();
}

class _AlmsPageState extends State<AlmsPage> {
  final ScrollController _almsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await refreshAlmssAndTotalAlms();
        _almsScrollController.addListener(() async {
          if (_almsScrollController.position.pixels ==
              _almsScrollController.position.maxScrollExtent) {
            await context.read<AlmsProvider>().fetchAlmss();
            print("fetch alms");
          }
        });
      });
    }
  }

  Future<void> refreshAlmssAndTotalAlms() async {
    final almsProvider = context.read<AlmsProvider>();
    await almsProvider.refreshAlmss();
    await almsProvider.refreshTotalAlms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarLeftBuilder(
          title: "Wadaah", description: "Waqaf Dana Abadi Ayah Hebat"),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          await refreshAlmssAndTotalAlms();
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
                          Consumer<AlmsProvider>(
                            builder: (context, value, child) {
                              switch (value.totalAmountAlmsState) {
                                case TotalAlmsState.initial:
                                  return CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  );
                                case TotalAlmsState.loading:
                                  return CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  );
                                case TotalAlmsState.loaded:
                                  return Text(
                                      "Rp. ${formatNumber(value.totalAlms)}",
                                      style: AppStyles.heading2TextStyle);
                                case TotalAlmsState.error:
                                  return TextButton(
                                    onPressed: () => context
                                        .read<AlmsProvider>()
                                        .fetchTotalAlms(),
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
                      Navigator.pushNamed(context, '/sendAlms'),
                  child: Text("Iuran Sekarang")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("List Iuran", style: AppStyles.heading3BoldTextStyle),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/almsHistory');
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
              Consumer<AlmsProvider>(
                builder: (context, value, child) {
                  print("AlmsState: ${value.state}");

                  if ((value.state == AlmsState.initial &&
                          value.almss.isEmpty) ||
                      (value.state == AlmsState.loading &&
                          value.almss.isEmpty)) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  }

                  if (value.state == AlmsState.error) {
                    return Center(
                      child: TextButton(
                          onPressed: () =>
                              context.read<AlmsProvider>().refreshAlmss(),
                          child: Text("Retry"),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.redColor,
                              disabledBackgroundColor: AppColors.halfRedColor)),
                    );
                  }

                  if (value.state == AlmsState.loaded && value.almss.isEmpty) {
                    return Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: PaddingSizes.small),
                      child: ListView(
                        children: [Center(child: Text("Belum ada iuran"))],
                      ),
                    ));
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: PaddingSizes.small),
                      child: ListView.builder(
                        controller: _almsScrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: value.almss.length + 1,
                        itemBuilder: (context, index) {
                          if (index == value.almss.length) {
                            if (value.hasMoreData) {
                              value.fetchAlmss();
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }
                          return AlmsListTile(alms: value.almss[index]);
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

  // infaqListTile(Alms infaq) {
  //   DateTime date = DateTime.parse(infaq.updatedAt);
  //   DateTime localDate = date.toLocal();
  //   String formattedDate = DateFormat('dd MMM yyyy • HH:mm').format(localDate);
  //   print(formattedDate);

  //   return InkWell(
  //     onTap: () => Navigator.pushNamed(context, '/detailAlms', arguments: {
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
  //                 Text("Alms", style: AppStyles.heading3BoldTextStyle),
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
  //                     ColorByAlmsStatus.getColor(infaq.status)),
  //                 backgroundColor: MaterialStatePropertyAll(
  //                     ColorByAlmsStatus.getBackgroundColor(infaq.status)),
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
