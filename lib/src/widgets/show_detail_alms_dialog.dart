import 'package:ayahhebat/src/models/entity/alms_model.dart';
import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../utils/color_by_alms_status.dart';

void _showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        "Gagal memuat gambar",
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.whiteColor, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDetailAlmsDialog(
    {required BuildContext context,
    required Future<DetailAlms> Function() fetchDetailAlms}) {
  return showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<DetailAlms>(
        future: fetchDetailAlms(),
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
                          showDetailAlmsDialog(
                              context: context,
                              fetchDetailAlms: fetchDetailAlms);
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

          DetailAlms detailAlms = snapshot.data!;
          DateTime date = DateTime.parse(detailAlms.updatedAt);
          DateTime localDate = date.toLocal();
          String formattedDate =
              DateFormat('dd MMM yyyy • HH:mm').format(localDate);
          print(detailAlms.status);

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
                      Text("Detail Iuran", style: AppStyles.heading2TextStyle),
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
                                Text("Jumlah Iuran",
                                    style: AppStyles.hintTextStyle),
                                TextButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100))),
                                    foregroundColor: MaterialStatePropertyAll(
                                        ColorByAlmsStatus.getColor(
                                            detailAlms.status)),
                                    backgroundColor: MaterialStatePropertyAll(
                                        ColorByAlmsStatus.getBackgroundColor(
                                            detailAlms.status)),
                                  ),
                                  child: Text(
                                    detailAlms.status.capitalize(),
                                  ),
                                ),
                              ],
                            ),
                            Text("Rp. ${formatNumber(detailAlms.amount)}",
                                style: AppStyles.heading1TextStyle),
                            SizedBox(height: PaddingSizes.small),
                            Text(formattedDate, style: AppStyles.hintTextStyle),
                          ],
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: PaddingSizes.medium),
                  Text("ID Iuran", style: AppStyles.labelTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  Text(detailAlms.id, style: AppStyles.hintTextStyle),
                  SizedBox(height: PaddingSizes.small),
                  Text("Type Iuran", style: AppStyles.labelTextStyle),
                  SizedBox(height: PaddingSizes.doubleExtraSmall),
                  Text(detailAlms.almsType, style: AppStyles.hintTextStyle),
                  if (detailAlms.message != null) ...[
                    SizedBox(height: PaddingSizes.small),
                    Text("Pesan", style: AppStyles.labelTextStyle),
                    SizedBox(height: PaddingSizes.doubleExtraSmall),
                    Text(detailAlms.message!, style: AppStyles.hintTextStyle),
                  ],
                  if (detailAlms.evidenceImageUrl != null) ...[
                    SizedBox(height: PaddingSizes.small),
                    Text("Bukti Transfer", style: AppStyles.labelTextStyle),
                    SizedBox(height: PaddingSizes.doubleExtraSmall),
                    InkWell(
                      onTap: () => _showFullImage(context,
                          "$serverPath/uploads/${detailAlms.evidenceImageUrl!}"),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(PaddingSizes.small),
                            child: Image.network(
                              "$serverPath/uploads/${detailAlms.evidenceImageUrl!}",
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: AppColors.grey,
                                  child: Center(
                                    child: Text("Gagal memuat gambar",
                                        style: AppStyles.hintTextStyle),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: PaddingSizes.small,
                            right: PaddingSizes.small,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(PaddingSizes.small),
                              child: Icon(
                                Icons.fullscreen,
                                color: AppColors.whiteColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
