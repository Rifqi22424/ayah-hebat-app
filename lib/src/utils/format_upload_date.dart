String formatUploadDate(DateTime date) {
  final difference = DateTime.now().difference(date);

  if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks minggu yang lalu';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} hari yang lalu';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} jam yang lalu';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} menit yang lalu';
  } else {
    return 'Baru saja';
  }
}
