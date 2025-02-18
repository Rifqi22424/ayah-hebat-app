import 'dart:convert';
import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/utils/string_extension.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';

class ResultInfaqPage extends StatefulWidget {
  final RemoteMessage message;

  const ResultInfaqPage({Key? key, required this.message}) : super(key: key);

  @override
  State<ResultInfaqPage> createState() => _ResultInfaqPageState();
}

String parseDateToString({dynamic date}) {
  // dynamic date = DateTime.now(); // Coba dengan DateTime langsung

  DateTime parsedDate;
  String timezoneAbbreviation = "WIB"; // Default ke WIB

  if (date is String) {
    // Ambil hanya bagian tanggal & waktu, tanpa GMT dan zona waktu
    RegExp regex = RegExp(r'GMT[^\)]+\(([^)]+)\)');
    Match? match = regex.firstMatch(date);
    String? timezone = match?.group(1); // Ambil teks dalam tanda kurung

    String cleanedDate = date.replaceAll(regex, '').trim();

    // Parsing tanggal ke DateTime
    parsedDate = DateFormat('EEE MMM d yyyy HH:mm:ss').parse(cleanedDate);

    // Mapping untuk mengubah nama zona waktu
    Map<String, String> timezoneMapping = {
      "Western Indonesia Time": "WIB",
      "Central Indonesia Time": "WITA",
      "Eastern Indonesia Time": "WIT"
    };

    // Ganti dengan singkatan jika ada dalam mapping
    timezoneAbbreviation = timezoneMapping[timezone] ?? timezone ?? "WIB";
  } else if (date is DateTime) {
    // Jika sudah berupa DateTime, langsung gunakan
    parsedDate = date;
  } else {
    throw ArgumentError("Format tanggal tidak valid");
  }

  // Format tanggal dan waktu
  String formattedDate =
      DateFormat('EEEE, d MMMM y HH:mm:ss', 'id_ID').format(parsedDate);

  // Gabungkan hasil
  String result = "$formattedDate $timezoneAbbreviation";

  print(result);
  return result;
}

String imagePathByStatus(String status) {
  switch (status) {
    case "pending":
      return 'images/question.png';
    case "success":
      return 'images/approved.png';
    case "failed":
      return 'images/cancel.png';
    default:
      return 'images/question.png';
  }
}

String buttonTextByStatus(String status) {
  if (status == "pending") {
    return "Bayar Sekarang";
  } else {
    return "Kembali ke Halaman Utama";   
  }
}

Future<void> Function() onPressedBackButton(
    BuildContext context, String status, String redirectUrl) {
  return () async {
    if (status == "pending") {
      Navigator.pushNamed(context, '/payMethodInfaq', arguments: {
        "redirectUrl": redirectUrl,
      });
    } else {
      // Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, '/home');
    }
  };
}

class _ResultInfaqPageState extends State<ResultInfaqPage> {
  Map<String, dynamic> payload = {};

  @override
  Widget build(BuildContext context) {
    final data = widget.message;
    // for background and terminated state
    if (data.notification != null) {
      payload = data.data;
    }
    // for foreground state
    if (data.notification == null && data.data.isNotEmpty) {
      payload = jsonDecode(data.data['payload']);
    }

    // return Scaffold(
    //   appBar: AppBarBuilder(title: ""),
    //   body: Center(
    //     child: Column(
    //       children: [
    //         Text(payload.toString()),
    //         Text(payload['status'])
    //       ],
    //     ),
    //   ),
    // );
    // DateFormat dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
    // String date = dateFormat
    //     .format(DateTime.parse(payload["updatedAt"] ?? DateTime.now()));

    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: EdgeInsets.only(
        left: PaddingSizes.medium,
        right: PaddingSizes.medium,
        bottom: PaddingSizes.medium,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: PaddingSizes.extraLarge),
                Image.asset(
                  imagePathByStatus(payload['status']),
                  width: 126,
                  height: 126,
                ),
                SizedBox(height: PaddingSizes.large),
                Text(
                  payload['title'] ?? "",
                  textAlign: TextAlign.center,
                  style: AppStyles.heading1TextStyle,
                ),
                SizedBox(height: PaddingSizes.small),
                Text(payload['body'] ?? "",
                    textAlign: TextAlign.center,
                    style: AppStyles.hintTextStyle),
                SizedBox(height: PaddingSizes.medium),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkGrey),
                    borderRadius: BorderRadius.circular(
                      PaddingSizes.medium,
                    ),
                  ),
                  padding: EdgeInsets.all(PaddingSizes.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Detail Transaction",
                          style: AppStyles.labelBoldTextStyle),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                            "Transaction ID",
                            style: AppStyles.hintTextStyle,
                          )),
                          Expanded(
                              child: Text(
                                  payload["id"] ??
                                      "Exception was thrownException thrownException",
                                  textAlign: TextAlign.end,
                                  style: AppStyles.labelTextStyle)),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text("Tanggal",
                                  style: AppStyles.hintTextStyle)),
                          Expanded(
                              child: Text(
                                  parseDateToString(
                                      date: payload["updatedAt"] ??
                                          DateTime.now()),
                                  textAlign: TextAlign.end,
                                  style: AppStyles.labelTextStyle)),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("Type Infaq",
                                style: AppStyles.hintTextStyle),
                          ),
                          Expanded(
                              child: Text(
                                  payload["allocationType"] ??
                                      "Exception was thrownException thrownException was thrown",
                                  textAlign: TextAlign.end,
                                  style: AppStyles.labelTextStyle)),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("Type Pembayaran",
                                style: AppStyles.hintTextStyle),
                          ),
                          Expanded(
                              child: Text(
                                  payload["paymentType"] ??
                                      "Exception was thrownException thrownException was thrown",
                                  textAlign: TextAlign.end,
                                  style: AppStyles.labelTextStyle)),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child:
                                Text("Status", style: AppStyles.hintTextStyle),
                          ),
                          Expanded(
                              child: Text(
                                  (payload["status"] ??
                                          "Exception was thrownException thrownException was thrown")
                                      .toString()
                                      .capitalize(),
                                  textAlign: TextAlign.end,
                                  style: AppStyles.labelTextStyle)),
                        ],
                      ),
                      SizedBox(height: PaddingSizes.extraLarge),
                      Divider(height: 2, color: AppColors.darkGrey),
                      SizedBox(height: PaddingSizes.small),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // children: [Expanded(child: Text("Total")), Expanded(child: Text("1200000"))],
                        children: [
                          Expanded(
                              child: Text("Total",
                                  style: AppStyles.hintTextStyle)),
                          Expanded(
                              child: Text(
                                  formatNumber(int.tryParse(
                                              payload["amount"] ?? "0") ??
                                          0)
                                      .toString(),
                                  textAlign: TextAlign.end,
                                  style: AppStyles.labelTextStyle))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ButtonBuilder(
              onPressed: onPressedBackButton(context, payload['status'] ?? "",
                  payload['redirectUrl'] ?? ""),
              child: Text(buttonTextByStatus(payload['status'] ?? "")))
        ],
      ),
    )));
  }
}
