import 'package:ayahhebat/src/utils/string_extension.dart';
import 'package:ayahhebat/src/widgets/show_detail_alms_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/alms_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../models/entity/alms_model.dart';
import '../utils/color_by_alms_status.dart';
import '../utils/format_number.dart';

class AlmsListTile extends StatelessWidget {
  final Alms alms;
  const AlmsListTile({super.key, required this.alms});

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(alms.updatedAt);
    DateTime localDate = date.toLocal();
    String formattedDate = DateFormat('dd MMM yyyy • HH:mm').format(localDate);
    print(formattedDate);
    AlmsApi almsService = AlmsApi();

    return InkWell(
      onTap: () => showDetailAlmsDialog(
          context: context,
          fetchDetailAlms: () => almsService.fetchDetailAlms(id: alms.id)),
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
                  Text("Iuran", style: AppStyles.heading3BoldTextStyle),
                  SizedBox(height: PaddingSizes.extrasmall),
                  Text("Rp. ${formatNumber(alms.amount)}",
                      style: AppStyles.hintTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  Row(
                    children: [
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
                      ColorByAlmsStatus.getColor(alms.status)),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorByAlmsStatus.getBackgroundColor(alms.status)),
                ),
                child: Text(
                  alms.status.capitalize(),
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
