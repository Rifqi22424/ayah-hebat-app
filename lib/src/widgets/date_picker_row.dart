import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class DatePickerRow extends StatelessWidget {
  // final BuildContext context;
  final String title;
  final DateTime? minDate;
  final DateTime? date;
  final void Function(DateTime) onDatePicked;

  const DatePickerRow({
    Key? key,
    // required this.context,
    required this.title,
    this.minDate,
    required this.date,
    required this.onDatePicked,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context, String title, DateTime? date,
      void Function(DateTime) onDatePicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? minDate,
      firstDate: minDate ?? DateTime.now(), // Gunakan minDate jika tersedia
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor, // header background color
              onPrimary: AppColors.whiteColor, // header text color
              onSurface: AppColors.textColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != date) {
      onDatePicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.hintTextStyle),
        InkWell(
          onTap: () {
            _selectDate(context, title, date, onDatePicked);
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: ListTile(
              title: Text(
                date == null
                    ? 'Pilih tanggal'
                    : '${date!.day}/${date!.month}/${date!.year}',
                style: AppStyles.labelTextStyle,
              ),
              trailing:
                  Image.asset('images/calendar.png', width: 24, height: 24),
            ),
          ),
        )
      ],
    );
  }
}
