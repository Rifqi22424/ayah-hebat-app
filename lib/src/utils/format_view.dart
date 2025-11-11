import 'package:intl/intl.dart';

String formatViews(int viewCount) {
  if (viewCount >= 1000000) {
    double result = viewCount / 1000000;
    String formatted = NumberFormat('0.#', 'id_ID').format(result);
    return '$formatted jt x ditonton';
  } else if (viewCount >= 1000) {
    double result = viewCount / 1000;
    String formatted = NumberFormat('0.#', 'id_ID').format(result);
    return '$formatted rb x ditonton';
  } else {
    return '$viewCount x ditonton';
  }
}
