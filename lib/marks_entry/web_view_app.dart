import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cskmemp/app_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_flutter_android;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path/path.dart' as path;

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key, this.title, this.url, this.post})
      : super(key: key);
  final String? title;
  final String? url;
  final String? post;

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> with TickerProviderStateMixin {
  var loadingPercentage = 0;
  late final WebViewController controller;
  var errorLoading = "";
  String? pdfFlePath;
  bool _isPdfFile = false;
  bool _isPdfLoading = false;

  final cookieManager =
      WebViewCookieManager(); // Create a WebViewCookieManager instance.

  Future<String> downloadAndSavePdf(String pdfUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    // extract file name from pdfUrl
    String filename = path.basename(pdfUrl);
    final file = File('${directory.path}/${filename}.pdf');
    if (await file.exists()) {
      return file.path;
    }
    final response = await http.get(Uri.parse(pdfUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  void loadPdf(String pdfUrl) async {
    pdfFlePath = await downloadAndSavePdf(pdfUrl);
    setState(() {
      _isPdfFile = true;
      _isPdfLoading = false;
    });
  }

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
        onNavigationRequest: (request) {
          //print(request.url);
          // if the url ends with jpg, png, jpeg, gif, bmp, tiff, svg, webp, ico display the image
          if (request.url.endsWith('.jpg') ||
              request.url.endsWith('.png') ||
              request.url.endsWith('.jpeg') ||
              request.url.endsWith('.gif') ||
              request.url.endsWith('.bmp') ||
              request.url.endsWith('.tiff') ||
              request.url.endsWith('.svg') ||
              request.url.endsWith('.webp') ||
              request.url.endsWith('.ico')) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Image.network(request.url),
                );
              },
            );
            return NavigationDecision.prevent;
          } else if (request.url.endsWith('.pdf')) {
            setState(() {
              _isPdfLoading = true;
              loadPdf(request.url);
            });
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
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
        onWebResourceError: (WebResourceError error) {
          //show error on the screen
          setState(() {
            errorLoading = error.description;
          });
        },
      ));

    initFilePicker();

    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 500),
    // )..addListener(() {
    //     setState(() {});
    //   });
    // _colorTween = _animationController.drive(
    //   ColorTween(
    //     begin: Colors.yellow,
    //     end: Colors.blue,
    //   ),
    // );
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
          /*actions: <Widget>[
            NavigationControls(webViewController: controller),
          ],*/
        ),
        body: errorLoading == ""
            ? _isPdfLoading
                ?
                // show circular progress while pdf is loading with text "Downloading pdf file..."
                Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.red.shade900,
                          strokeWidth: 10.0,
                          //minHeight: 8.0,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Downloading pdf file... \nPlease Wait...',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isPdfFile
                    ? pdfFlePath != null
                        ? Center(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: SfPdfViewer.file(File(pdfFlePath!)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              "Error loading pdf file",
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                    : Stack(
                        children: [
                          WebViewWidget(
                            controller: controller,
                          ),
                          if (loadingPercentage < 100)
                            Center(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 50.0,
                                        right: 50.0,
                                      ),
                                      child: LinearProgressIndicator(
                                        value: loadingPercentage / 100.0,
                                        backgroundColor: Colors.grey.shade600,
                                        color: Colors.red.shade900,
                                        //strokeWidth: 10.0,
                                        minHeight: 8.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    Text(
                                      'Loading: $loadingPercentage%',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Colors.green,
                                          strokeWidth: 3,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Please Wait...',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //error icon
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade900,
                        size: 200.0,
                      ),
                      Text(
                        //errorLoading,
                        "There was an error loading this page",
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Please go back and open this page again.",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "If the problem persists, please check your internet connectivity or else retry after some time.",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ));
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

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}
