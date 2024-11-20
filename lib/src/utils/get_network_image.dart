import 'package:ayahhebat/main.dart';

class GetNetworkImage {
  static String getBooks(String imageUrl) {
    return "$serverPath/uploads/books/$imageUrl";
  }

  static String getUploads(String imageUrl) {
    return "$serverPath/uploads/$imageUrl";
  }
}
