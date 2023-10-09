import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cskmemp/app_config.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_flutter_android;
import 'package:image_picker/image_picker.dart' as image_picker;

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key, this.title, this.url, this.post})
      : super(key: key);
  final String? title;
  final String? url;
  final String? post;

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  var loadingPercentage = 0;
  late final WebViewController controller;
  final cookieManager =
      WebViewCookieManager(); // Create a WebViewCookieManager instance.

  // Future<void> _dummy(WebViewController controller) async {}
  // Future<void> _onSetCookie(WebViewController controller) async {
  //   var userno = AppConfig.globalUserNo;
  //   var fy = AppConfig.globalFy;
  //   await cookieManager.setCookie(
  //     WebViewCookie(name: 'userno', value: userno, domain: 'www.cskm.com'),
  //   );
  //   await cookieManager.setCookie(
  //     WebViewCookie(name: 'fy', value: fy, domain: 'www.cskm.com'),
  //   );
  //   controller.loadRequest(Uri.parse(widget.url!));

  //   if (!mounted) return;
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   const SnackBar(
  //   //     content: Text('Connected to SchoolExpert'),
  //   //   ),
  //   // );
  // }

  @override
  void initState() {
    super.initState();
    var userno = AppConfig.globalUserNo;
    var fy = AppConfig.globalFy;
    var usernoT = AppConfig.globalUserNoT;
    var fyT = AppConfig.globalFyT;
    cookieManager.setCookie(
      WebViewCookie(name: 'userno', value: userno, domain: 'www.cskm.com'),
    );
    cookieManager.setCookie(
      WebViewCookie(name: 'fy', value: fy, domain: 'www.cskm.com'),
    );
    cookieManager.setCookie(
      WebViewCookie(name: 'usernoT', value: usernoT, domain: 'www.cskm.com'),
    );
    cookieManager.setCookie(
      WebViewCookie(name: 'fyT', value: fyT, domain: 'www.cskm.com'),
    );
    //controller.loadRequest(Uri.parse(widget.url!));
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color.fromARGB(255, 255, 255, 255))
      ..loadRequest(Uri.parse(widget.url!))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ));
    initFilePicker();
  }

  initFilePicker() async {
    if (Platform.isAndroid) {
      final androidController = (controller.platform
          as webview_flutter_android.AndroidWebViewController);
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  Future<List<String>> _androidFilePicker(
      webview_flutter_android.FileSelectorParams params) async {
    if (params.acceptTypes.any((type) => type == 'image/*')) {
      final picker = image_picker.ImagePicker();
      final photo =
          await picker.pickImage(source: image_picker.ImageSource.camera);

      if (photo == null) {
        return [];
      }
      return [Uri.file(photo.path).toString()];
    } else if (params.acceptTypes.any((type) => type == 'video/*')) {
      final picker = image_picker.ImagePicker();
      final vidFile = await picker.pickVideo(
          source: ImageSource.camera, maxDuration: const Duration(seconds: 10));
      if (vidFile == null) {
        return [];
      }
      return [Uri.file(vidFile.path).toString()];
    } else {
      try {
        if (params.mode ==
            webview_flutter_android.FileSelectorMode.openMultiple) {
          final attachments =
              await FilePicker.platform.pickFiles(allowMultiple: true);
          if (attachments == null) return [];

          return attachments.files
              .where((element) => element.path != null)
              .map((e) => File(e.path!).uri.toString())
              .toList();
        } else {
          final attachment = await FilePicker.platform.pickFiles();
          if (attachment == null) return [];
          File file = File(attachment.files.single.path!);
          return [file.uri.toString()];
        }
      } catch (e) {
        return [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
    // return FutureBuilder(
    //   future: _dummy(controller),
    //   builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       return Scaffold(
    //         appBar: AppBar(
    //           title: Text(widget.title!),
    //         ),
    //         body:
    //             // Stack(
    //             //   children: [
    //             WebViewWidget(
    //           controller: controller,
    //         ),
    //         // if (loadingPercentage < 100)
    //         //   LinearProgressIndicator(
    //         //     value: loadingPercentage / 100.0,
    //         //   ),
    //         //   ],
    //         // ),
    //       );
    //     } else {
    //       return const Scaffold(
    //         body: Center(
    //           child: CircularProgressIndicator(),
    //         ),
    //       );
    //     }
    //   },
    // );
  }
}
