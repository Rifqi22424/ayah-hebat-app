// File: lib/utils/share_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Menampilkan share sheet bawaan OS untuk membagikan teks.
void shareVideo(BuildContext context, String title, String videoUrl) {
  final String shareText = 'Tonton video ini: $title\n$videoUrl';

  // Share.share membutuhkan BuildContext untuk posisinya di iPad
  final box = context.findRenderObject() as RenderBox?;

  Share.share(
    shareText,
    subject: title, // Subjek untuk email
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
}

/// Menyalin link ke clipboard dan menampilkan SnackBar konfirmasi.
void copyLink(BuildContext context, String videoUrl) {
  Clipboard.setData(ClipboardData(text: videoUrl)).then((_) {
    // Menutup bottom sheet (jika masih ada) sebelum menampilkan SnackBar
    // Navigator.of(context).pop(); <-- Dihapus, karena pop sudah ada di pemanggil

    // Menampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link video disalin ke clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  });
}