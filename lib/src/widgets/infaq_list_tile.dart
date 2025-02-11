import 'package:ayahhebat/src/utils/string_extension.dart';
import 'package:ayahhebat/src/widgets/show_detail_infaq_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/infaq_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../models/entity/infaq_model.dart';
import '../utils/color_by_infaq_status.dart';
import '../utils/format_number.dart';

class InfaqListTile extends StatelessWidget {
  final Infaq infaq;
  const InfaqListTile({super.key, required this.infaq});

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(infaq.updatedAt);
    DateTime localDate = date.toLocal();
    String formattedDate = DateFormat('dd MMM yyyy • HH:mm').format(localDate);
    print(formattedDate);
    InfaqApi infaqService = InfaqApi();

    return InkWell(
      onTap: () => showDetailInfaqDialog(context: context, fetchDetailInfaq: () => infaqService.fetchDetailInfaq(id: infaq.id)),
      // Navigator.pushNamed(context, '/detailInfaq', arguments: {
      //   'id': infaq.id,
      // }
      // ),
      child: Column(
        children: [
          SizedBox(height: PaddingSizes.small),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkGrey)),
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.monetization_on_outlined)),
              ),
              SizedBox(width: PaddingSizes.small),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: PaddingSizes.small),
                  Text("Infaq", style: AppStyles.heading3BoldTextStyle),
                  // SizedBox(height: PaddingSizes.small),
                  SizedBox(height: PaddingSizes.extrasmall),
                  Text("Rp. ${formatNumber(infaq.amount)}",
                      style: AppStyles.hintTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  Row(
                    children: [
                      // Text(
                      //     "${localDate.day} ${IndonesiaMonth.getMonthName(localDate.month)} ${localDate.year}"),
                      // Text("${localDate.hour}:${localDate.minute}"),
                      Text(formattedDate, style: AppStyles.hintTextStyle),
                    ],
                  ),
                ],
              )),
              TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
                  foregroundColor: MaterialStatePropertyAll(
                      ColorByInfaqStatus.getColor(infaq.status)),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorByInfaqStatus.getBackgroundColor(infaq.status)),
                ),
                child: Text(
                  infaq.status.capitalize(),
                ),
              ),
            ],
          ),
          SizedBox(height: PaddingSizes.small),
          Divider(
            color: AppColors.grey,
            height: 2,
          ),
        ],
      ),
    );
  }
}
