import 'package:ayahhebat/src/models/entity/infaq_model.dart';
import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../utils/color_by_infaq_status.dart';
import 'button_builder.dart';

Future<void> showDetailInfaqDialog(
    {required BuildContext context,
    required Future<DetailInfaq> Function() fetchDetailInfaq}) {
  return showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<DetailInfaq>(
        future: fetchDetailInfaq(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PaddingSizes.medium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PaddingSizes.medium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: PaddingSizes.medium),
                    Text("Loading...")
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PaddingSizes.medium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PaddingSizes.medium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Failed to load data"),
                    Text(snapshot.error.toString()),
                    SizedBox(height: PaddingSizes.medium),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDetailInfaqDialog(
                              context: context,
                              fetchDetailInfaq: fetchDetailInfaq);
                        },
                        child: Text("Retry"))
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PaddingSizes.medium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PaddingSizes.medium),
                child: Text("No Data Available"),
              ),
            );
          }

          DetailInfaq detailInfaq = snapshot.data!;
          DateTime date = DateTime.parse(detailInfaq.updatedAt);
          DateTime localDate = date.toLocal();
          String formattedDate =
              DateFormat('dd MMM yyyy • HH:mm').format(localDate);
          print(detailInfaq.status);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PaddingSizes.medium),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PaddingSizes.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Detail Infaq", style: AppStyles.heading2TextStyle),
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(PaddingSizes.medium),
                          color: AppColors.grey,
                        ),
                        padding: EdgeInsets.all(PaddingSizes.medium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Jumlah Infaq",
                                    style: AppStyles.hintTextStyle),
                                TextButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100))),
                                    foregroundColor: MaterialStatePropertyAll(
                                        ColorByInfaqStatus.getColor(
                                            detailInfaq.status)),
                                    backgroundColor: MaterialStatePropertyAll(
                                        ColorByInfaqStatus.getBackgroundColor(
                                            detailInfaq.status)),
                                  ),
                                  child: Text(
                                    detailInfaq.status.capitalize(),
                                  ),
                                ),
                              ],
                            ),
                            Text("Rp. ${formatNumber(detailInfaq.amount)}",
                                style: AppStyles.heading1TextStyle),
                            SizedBox(height: PaddingSizes.small),
                            Text(formattedDate, style: AppStyles.hintTextStyle),
                          ],
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: PaddingSizes.medium),
                  Text("Order Id", style: AppStyles.labelTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  Text(detailInfaq.orderId, style: AppStyles.hintTextStyle),
                  SizedBox(height: PaddingSizes.small),
                  if (detailInfaq.paymentType != null)
                    Text("Type Pembayaran", style: AppStyles.labelTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  if (detailInfaq.paymentType != null)
                    Text(detailInfaq.paymentType!,
                        style: AppStyles.hintTextStyle),
                  SizedBox(height: PaddingSizes.small),
                  Text("Type Infaq", style: AppStyles.labelTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  Text(detailInfaq.infaqType, style: AppStyles.hintTextStyle),
                  SizedBox(height: PaddingSizes.medium),
                  if (detailInfaq.status == "pending")
                    ButtonBuilder(
                        onPressed: () => Navigator.pushNamed(
                                context, '/payMethodInfaq',
                                arguments: {
                                  "redirectUrl": detailInfaq.redirectUrl,
                                }),
                        child: Text("Bayar")),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
