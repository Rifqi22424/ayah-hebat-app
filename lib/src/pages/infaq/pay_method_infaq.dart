// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:file_saver/file_saver.dart';

// class PayMethodInfaqPage extends StatefulWidget {
//   final String redirectUrl;
//   const PayMethodInfaqPage({super.key, required this.redirectUrl});

//   @override
//   State<PayMethodInfaqPage> createState() => _WebViewAppState();
// }

// class _WebViewAppState extends State<PayMethodInfaqPage> {
//   int loadingPercentage = 0;
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     print(widget.redirectUrl);
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(NavigationDelegate(
//         onProgress: (progress) {
//           setState(() {
//             loadingPercentage = progress;
//           });
//         },
//         onPageStarted: (url) {
//           setState(() {
//             loadingPercentage = 0;
//           });
//         },
//         onPageFinished: (url) {
//           setState(() {
//             loadingPercentage = 100;
//           });
//         },
//         onNavigationRequest: (request) {
//           final host = Uri.parse(request.url).toString();
//           print("host: " + host);
//           if (host.contains('gojek://') ||
//               host.contains('shopeeid://') ||
//               host.contains('//wsa.wallet.airpay.co.id/') ||
//               // This is handle for sandbox Simulator
//               host.contains('/gopay/partner/') ||
//               host.contains('/shopeepay/') ||
//               host.contains('/pdf')) {
//             _launchInExternalBrowser(Uri.parse(request.url));
//             return NavigationDecision.prevent;
//           }
//           if (host.startsWith('blob:')) {
//             print("Blob URL: $host");
//             _fetchBlobData(request.url);
//             return NavigationDecision.prevent;
//           }
//           print("Host: $host");
//           if (host.contains('example.com') ||
//               host.contains('Webpage not available')) {
//             print("Error: $host");
//             Navigator.pop(context);
//             return NavigationDecision.prevent;
//           }
//           return NavigationDecision.navigate;
//         },
//       ))
//       ..addJavaScriptChannel(
//         'BlobDataChannel',
//         onMessageReceived: (message) async {
//           try {
//             final decodedBytes = base64Decode(message.message);
//             await FileSaver.instance.saveAs(
//               name: 'qris_${DateTime.now().millisecondsSinceEpoch}',
//               ext: 'png',
//               mimeType: MimeType.png,
//               bytes: decodedBytes,
//             );

//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('File downloaded successfully')),
//               );
//             }
//           } catch (e) {
//             print('Error saving file: $e');
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Error downloading file')),
//               );
//             }
//           }
//         },
//       )
//       ..loadRequest(Uri.parse(widget.redirectUrl));
//   }

//   Future<void> _launchInExternalBrowser(Uri url) async {
//     if (!await launchUrl(
//       url,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw 'Could not launch $url';
//     }
//   }

//   void _fetchBlobData(String blobUrl) async {
//     final script = '''
//     (async function() {
//       try {
//         console.log("Starting blob fetch from:", '$blobUrl');

//         // Try to get the blob directly from the document
//         const blobElement = document.querySelector('a[href="$blobUrl"]');
//         if (blobElement) {
//           console.log("Found blob element:", blobElement);
//           const response = await fetch(blobElement.href);
//           const blob = await response.blob();
//           const reader = new FileReader();
//           reader.onloadend = () => BlobDataChannel.postMessage(reader.result.split(',')[1]);
//           reader.readAsDataURL(blob);
//           return;
//         }

//         // If direct access fails, try to get it through XHR
//         const xhr = new XMLHttpRequest();
//         xhr.open('GET', '$blobUrl', true);
//         xhr.responseType = 'blob';

//         xhr.onload = function() {
//           if (this.status === 200) {
//             const reader = new FileReader();
//             reader.onloadend = function() {
//               BlobDataChannel.postMessage(this.result.split(',')[1]);
//             };
//             reader.readAsDataURL(this.response);
//           } else {
//             console.error("XHR failed with status:", this.status);
//           }
//         };

//         xhr.onerror = function() {
//           console.error("XHR failed");
//         };

//         xhr.send();
//       } catch (error) {
//         console.error("Blob fetch error:", error);

//         // Last resort: try to capture the download event
//         const link = document.createElement('a');
//         link.href = '$blobUrl';
//         link.download = 'download';
//         document.body.appendChild(link);
//         link.click();
//         document.body.removeChild(link);
//       }
//     })();
//     ''';

//     try {
//       await _controller.runJavaScript(script);
//     } catch (e) {
//       print('JavaScript execution error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           alignment: AlignmentDirectional.topCenter,
//           children: [
//             Container(
//               margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
//               child: WebViewWidget(controller: _controller),
//             ),
//             Container(
//               margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
//               height: 30,
//               width: 60,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0A2852),
//                 ),
//                 child: const Text('Exit', style: TextStyle(fontSize: 10)),
//               ),
//             ),
//             if (loadingPercentage < 100)
//               LinearProgressIndicator(
//                 value: loadingPercentage / 100.0,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:file_saver/file_saver.dart';

// class PayMethodInfaqPage extends StatefulWidget {
//   final String redirectUrl;
//   const PayMethodInfaqPage({super.key, required this.redirectUrl});

//   @override
//   State<PayMethodInfaqPage> createState() => _WebViewAppState();
// }

// class _WebViewAppState extends State<PayMethodInfaqPage> {
//   int loadingPercentage = 0;
//   late WebViewController _controller;

//   @override
//   initState() {
//     super.initState();
//     if (Platform.isAndroid) WebView.platform = AndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final url = widget.redirectUrl;
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           alignment: AlignmentDirectional.topCenter,
//           children: [
//             Container(
//               margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
//               child: WebView(
//                 initialUrl: url,
//                 onPageStarted: (url) {
//                   setState(() {
//                     loadingPercentage = 0;
//                   });
//                 },
//                 onProgress: (progress) {
//                   setState(() {
//                     loadingPercentage = progress;
//                   });
//                 },
//                 onPageFinished: (url) {
//                   setState(() {
//                     loadingPercentage = 100;
//                   });
//                 },
//                 javascriptMode: JavascriptMode.unrestricted,
//                 gestureRecognizers: Set()
//                   ..add(Factory<OneSequenceGestureRecognizer>(
//                       () => EagerGestureRecognizer())),
//                 onWebViewCreated: (WebViewController webViewController) {
//                   _controller = webViewController;
//                 },
//                 javascriptChannels: <JavascriptChannel>{
//                   _blobDataChannel(context),
//                 },
//                 gestureNavigationEnabled: true,
//                 allowsInlineMediaPlayback: true,
//                 initialMediaPlaybackPolicy:
//                     AutoMediaPlaybackPolicy.always_allow,
//                 navigationDelegate: (NavigationRequest request) {
//                   final host = Uri.parse(request.url).toString();
//                   if (host.contains('gojek://') ||
//                       host.contains('shopeeid://') ||
//                       host.contains('//wsa.wallet.airpay.co.id/') ||
//                       // This is handle for sandbox Simulator
//                       host.contains('/gopay/partner/') ||
//                       host.contains('/shopeepay/') ||
//                       host.contains('/pdf')) {
//                     _launchInExternalBrowser(Uri.parse(request.url));
//                     return NavigationDecision.prevent;
//                   }
//                   if (host.startsWith('blob:')) {
//                     print("Blob URL: $host");
//                     // _convertBlobToPdf(request.url);
//                     _fetchBlobData(request.url);
//                     return NavigationDecision.prevent;
//                   }
//                   print("Host: $host");
//                   if (host.contains('example.com') ||
//                       host.contains('Webpage not available') ||
//                       host.contains('dhrqldvp-3000.asse.devtunnels.ms') ||
//                       host.contains('backend.ayahhebat.mangcoding')) {
//                     print("Error: $host");
//                     Navigator.pop(context); // Go back to the previous screen
//                     return NavigationDecision.prevent;
//                   }

//                   return NavigationDecision.navigate;
//                 },
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
//               height: 30,
//               width: 60,
//               child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF0A2852),
//                   ),
//                   child: const Text('Exit', style: TextStyle(fontSize: 10))),
//             ),
//             if (loadingPercentage < 100)
//               LinearProgressIndicator(
//                 value: loadingPercentage / 100.0,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _launchInExternalBrowser(Uri url) async {
//     if (!await launchUrl(
//       url,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw 'Could not launch $url';
//     }
//   }

//   JavascriptChannel _blobDataChannel(BuildContext context) {
//     return JavascriptChannel(
//       name: 'BlobDataChannel',
//       onMessageReceived: (JavascriptMessage message) async {
//         try {
//           final decodedBytes = base64Decode(message.message);
//           final directory = await getApplicationDocumentsDirectory();
//           final path = directory.path;

//           // Save and open the file using FileSaver
//           await FileSaver.instance.saveAs(
//             name: 'qris_${DateTime.now().millisecondsSinceEpoch}',
//             ext: 'png', // or 'pdf' depending on the content type
//             mimeType: MimeType.png, // or MimeType.pdf
//             bytes: decodedBytes,
//           );

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('File downloaded successfully')),
//           );
//         } catch (e) {
//           print('Error saving file: $e');
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Error downloading file')),
//           );
//         }
//       },
//     );
//   }

//   void _fetchBlobData(String blobUrl) async {
//     final script = '''
//     (async function() {
//       try {
//         // Get the original response from the blob URL
//         console.log("Fetching blob data from URL:", '$blobUrl');
//         const response = await fetch('$blobUrl');
//         if (!response.ok) {
//           console.log('Network response was not ok:', response.status);
//           throw new Error('Network response was not ok: ' + response.status);
//         }

//         console.log('Response:', response);

//         // Get the blob data
//         const blob = await response.blob();
//         console.log('Blob type:', blob.type);
//         console.log('Blob size:', blob.size);

//         // Create a FileReader to convert blob to base64
//         const reader = new FileReader();
//         reader.onloadend = function() {
//           try {
//             const base64data = reader.result.split(',')[1];
//             BlobDataChannel.postMessage(base64data);
//           } catch (e) {
//             console.error('Error in reader.onloadend:', e);
//           }
//         };
//         reader.onerror = function() {
//           console.error('FileReader error:', reader.error);
//         };
//         reader.readAsDataURL(blob);
//       } catch (error) {
//         console.error("Blob fetch error:", error);
//       }
//     })();
//   ''';

//     await _controller.runJavascript(script);
//   }
// }

// ignore_for_file: avoid_print

import 'dart:convert';
// import 'dart:io'; // <-- Sudah tidak perlu untuk 'Platform.isAndroid'
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:path_provider/path_provider.dart'; // <-- Tidak terpakai di _blobDataChannel
import 'package:file_saver/file_saver.dart';

class PayMethodInfaqPage extends StatefulWidget {
  final String redirectUrl;
  const PayMethodInfaqPage({super.key, required this.redirectUrl});

  @override
  State<PayMethodInfaqPage> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<PayMethodInfaqPage> {
  int loadingPercentage = 0;

  // --- UBAH ---
  // Controller sekarang di-final dan diinisialisasi di initState
  late final WebViewController _controller;

  @override
  initState() {
    super.initState();

    // --- UBAH ---
    // Hapus: if (Platform.isAndroid) WebView.platform = AndroidWebView();

    // Inisialisasi dan konfigurasi controller di sini
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // dari javascriptMode

      // Media playback option removed: use platform defaults or configure per-platform if needed.
      // --- UBAH ---
      // Gabungkan semua delegate navigasi di sini
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          // Ini adalah logic dari 'navigationDelegate' lama Anda
          onNavigationRequest: (NavigationRequest request) {
            final host = Uri.parse(request.url).toString();
            if (host.contains('gojek://') ||
                host.contains('shopeeid://') ||
                host.contains('//wsa.wallet.airpay.co.id/') ||
                // This is handle for sandbox Simulator
                host.contains('/gopay/partner/') ||
                host.contains('/shopeepay/') ||
                host.contains('/pdf')) {
              _launchInExternalBrowser(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            if (host.startsWith('blob:')) {
              print("Blob URL: $host");
              _fetchBlobData(request.url);
              return NavigationDecision.prevent;
            }
            print("Host: $host");
            if (host.contains('example.com') ||
                host.contains('Webpage not available') ||
                host.contains('dhrqldvp-3000.asse.devtunnels.ms') ||
                host.contains('backend.ayahhebat.mangcoding')) {
              print("Error: $host");
              Navigator.pop(context); // Go back to the previous screen
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )

      // --- UBAH ---
      // Pindahkan logic dari _blobDataChannel ke .addJavaScriptChannel
      ..addJavaScriptChannel(
        'BlobDataChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final decodedBytes = base64Decode(message.message);

            // Logic dari _blobDataChannel lama Anda
            await FileSaver.instance.saveAs(
              name: 'qris_${DateTime.now().millisecondsSinceEpoch}',
              mimeType: MimeType.png, // or MimeType.pdf
              bytes: decodedBytes, fileExtension: 'png',
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File downloaded successfully')),
            );
          } catch (e) {
            print('Error saving file: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error downloading file')),
            );
          }
        },
      )

      // --- UBAH ---
      // Muat URL menggunakan controller
      ..loadRequest(Uri.parse(widget.redirectUrl)); // dari initialUrl
  }

  @override
  Widget build(BuildContext context) {
    // Hapus: final url = widget.redirectUrl; (sudah di initState)
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),

              // --- UBAH ---
              // Ganti WebView(...) menjadi WebViewWidget(controller: _controller)
              child: WebViewWidget(
                controller: _controller,
                // gestureRecognizers tetap sama
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer()),
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              height: 30,
              width: 60,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2852),
                  ),
                  child: const Text('Exit', style: TextStyle(fontSize: 10))),
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ),
      ),
    );
  }

  // --- TANPA PERUBAHAN ---
  Future<void> _launchInExternalBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  // --- HAPUS FUNGSI INI ---
  // JavascriptChannel _blobDataChannel(BuildContext context) { ... }
  // Logic-nya sudah dipindah ke initState di atas

  // --- UBAH ---
  void _fetchBlobData(String blobUrl) async {
    final script = '''
    (async function() {
      try {
        // ... (Script JS Anda tidak perlu diubah) ...
        const response = await fetch('$blobUrl');
        // ...
        const blob = await response.blob();
        // ...
        const reader = new FileReader();
        reader.onloadend = function() {
          try {
            const base64data = reader.result.split(',')[1];
            BlobDataChannel.postMessage(base64data);
          } catch (e) {
            console.error('Error in reader.onloadend:', e);
          }
        };
        // ...
        reader.readAsDataURL(blob);
      } catch (error) {
        console.error("Blob fetch error:", error);
      }
    })();
  ''';

    // Ganti .runJavascript(script) menjadi .runJavaScript(script) (huruf 'S' besar)
    await _controller.runJavaScript(script);
  }
}
