import 'package:intl/intl.dart';

formatNumber(int number) {
  return NumberFormat.decimalPattern('id').format(number);
}

formatStringToNumber(String value) {
  return NumberFormat.decimalPattern('id')
      .format(int.tryParse(value.replaceAll('.', '')) ?? 0);
}
