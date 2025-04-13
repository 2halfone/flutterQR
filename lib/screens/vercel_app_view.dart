import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VercelAppView extends StatefulWidget {
  const VercelAppView({Key? key}) : super(key: key);

  @override
  State<VercelAppView> createState() => _VercelAppViewState();
}

class _VercelAppViewState extends State<VercelAppView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Mostra un indicatore di caricamento
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(
        Uri.parse('https://qr-generator-eight-tau.vercel.app/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Customizer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}