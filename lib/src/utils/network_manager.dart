// import 'dart:async';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';

// class NetworkManager {
//   static final NetworkManager _instance = NetworkManager._internal();
//   factory NetworkManager() => _instance;

//   NetworkManager._internal();

//   StreamSubscription? _subscription;
//   late BuildContext _context;
//   bool _isDialogShowing = false;

//   void initialize(BuildContext context) {
//     _context = context;

//     _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
//       bool isConnected = await _isInternetAvailable();

//       if (!isConnected) {
//         _showNoInternetDialog();
//       } else {
//         _hideDialog(); // Sembunyikan jika jaringan kembali
//       }
//     });
//   }

//   Future<bool> _isInternetAvailable() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }

//   void _showNoInternetDialog() {
//     if (_isDialogShowing) return;

//     _isDialogShowing = true;
//     showDialog(
//       context: _context,
//       barrierDismissible: false, // Tidak bisa ditutup dengan klik di luar
//       builder: (context) => AlertDialog(
//         title: const Text("Jaringan Tidak Stabil!"),
//         content: const Text("Silakan periksa koneksi internet Anda."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _isDialogShowing = false;
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _hideDialog() {
//     if (_isDialogShowing) {
//       Navigator.of(_context, rootNavigator: true).pop();
//       _isDialogShowing = false;
//     }
//   }

//   void dispose() {
//     _subscription?.cancel();
//   }
// }
