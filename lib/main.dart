// import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
import 'package:coinmomo/stmng.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// csWflsUgRmKCD6lxX39_9v:APA91bFve5es4Hh8awBuyujglQY5pDKkOjaZfhk7fDcwrW7_aBdzQtFrkcfEvpRgdtIF3RLOjJ04QAgWAillTtwgUqFpYd-oGQ1L7GyWuCyKZUGzXCtKkLcbAcd_lfQt2B_EucpZFhS4
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

Future main() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, title: 'Giftoo', home: StateMan()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
// https://www.giftoo.in/
  String url = 'https://www.giftoo.in/';
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          // clearCache: true,
          //cacheEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          transparentBackground: true),
      android: AndroidInAppWebViewOptions(
        forceDark: AndroidForceDark.FORCE_DARK_AUTO,
        useHybridComposition: true,
        cacheMode: AndroidCacheMode.LOAD_NO_CACHE,
        // clearSessionCache: true
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  //String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  Future<void> backgroundHandler(RemoteMessage message) async {
    debugPrint(message.data.toString());
    debugPrint(message.notification!.title);
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.instance.getToken().then((value) {
      String? token = value;
      debugPrint('tOKKKKKennn $token');
    });
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  bool isLoading = false;
  @override
  void dispose() {
    super.dispose();
  }

  // Future<bool> browserBack(BuildContext context) async {
  //   print('activated');
  //   if (await webViewController!.canGoBack()) {
  //     // Scaffold.of(context).showSnackBar(
  //     //   const SnackBar(content: Text("Munching....")),
  //     // );
  //     print("onwill goback");

  //     webViewController!.goBack();
  //     return false;
  //   } else {
  //     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //     return Future.value(false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      // onWillPop: _onBack,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: AppBar(title: Text("Official InAppWebView website")),
          body: SafeArea(
              child: Stack(
            children: [
              // height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    isLoading = true;
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    debugPrint("url scheme ca,me ${uri.scheme + url}");
                    if (url.contains('m.facebook')) {
                      String p = 'http://m.me/Giftoo.in';
                      debugPrint("facebook");
                      //String.parse(url);
                      //pinterest//com.pinterest.EXTRA_DESCRIPTION
                      //instagram.com//com.instagram.android
                      //com.facebook.katana
                      if (await canLaunch(p)) {
                        // Launch the App
                        await launch(
                          p,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    } else if (await canLaunch(url)) {
                      // Launch the App
                      await launch(
                        url,
                        forceSafariVC: false,
                        forceWebView: false,
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                    /* if (url.contains('com.facebook')) {
                          String p = 'http://m.me/Giftoo.in';
                          print("facebook");
                          //String.parse(url);
                          //pinterest//com.pinterest.EXTRA_DESCRIPTION
                          //instagram.com//com.instagram.android
                          //com.facebook.katana
                          if (await canLaunch(p)) {
                            // Launch the App
                            await launch(
                              p,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        } else if (await canLaunch(url)) {
                          // Launch the App
                          await launch(
                            url,
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }*/
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                /*shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      if (![
                        "http",
                        "https",
                        "file",
                        "chrome",
                        "data",
                        "javascript",
                        "about"
                        // "intent"
                      ].contains(uri.scheme)) {
                        // if (await canLaunch(url)) {
                        // Launch the App
                        if (url.contains('instagram.com')) {
                          String p =
                              'https://www.instagram.com/_u/giftoo.in'; //String.parse(url);
                          //pinterest//com.pinterest.EXTRA_DESCRIPTION
                          //instagram.com//com.instagram.android
                          //com.facebook.katana
                          if (await canLaunch(p)) {
                            // Launch the App
                            await launch(
                              p,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        } else if (url.contains('com.facebook')) {
                          String p = 'http://m.me/Giftoo.in';
                          print("facebook");
                          //String.parse(url);
                          //pinterest//com.pinterest.EXTRA_DESCRIPTION
                          //instagram.com//com.instagram.android
                          //com.facebook.katana
                          if (await canLaunch(p)) {
                            // Launch the App
                            await launch(
                              p,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        } else if (url.contains('pinterest')) {
                          String p =
                              'http://in.pinterest.com/Giftoo.IN'; //String.parse(url);
                          //pinterest//com.pinterest.EXTRA_DESCRIPTION
                          //instagram.com//com.instagram.android
                          //com.facebook.katana
                          if (await canLaunch(p)) {
                            // Launch the App
                            await launch(
                              p,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        } else if (url.contains('twitter')) {
                          String p =
                              'https://twitter.com/GiftooIN'; //String.parse(url);
                          //pinterest//com.pinterest.EXTRA_DESCRIPTION
                          //instagram.com//com.instagram.android
                          //com.facebook.katana
                          if (await canLaunch(p)) {
                            // Launch the App
                            await launch(
                              p,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        } else if (url.contains('whatsapp')) {
                          String p =
                              'whatsapp://send?phone=+919322990002'; //String.parse(url);
                          //pinterest//com.pinterest.EXTRA_DESCRIPTION
                          //instagram.com//com.instagram.android
                          //com.facebook.katana
                          if (await canLaunch(p)) {
                            // Launch the App
                            await launch(
                              p,
                            );

                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        //}
                      }
                      return NavigationActionPolicy.ALLOW;
                    },*/
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  // setState(() {
                  this.progress = progress / 100;
                  //urlController.text = this.url;
                  if (progress > 0.80) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                  // });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  // setState(() {
                  //   this.url = url.toString();
                  //   urlController.text = this.url;
                  // });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint(consoleMessage.toString());
                },
              ),

              Center(
                  child: progress < 0.80
                      ? Container(
                          height: 80,
                          width: 130,
                          //color: Colors.white,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          // ignore: prefer_const_constructors
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const LoadingIndicator(
                              indicatorType: Indicator.ballScaleRippleMultiple,

                              /// Required, The loading type of the widget
                              colors: _kDefaultRainbowColors,

                              /// Optional, The color collections
                              strokeWidth: 2,

                              /// Optional, The stroke of the line, only applicable to widget which contains line
                              backgroundColor: Colors.white,

                              /// Optional, Background of the widget
                              // pathBackgroundColor: Colors.black

                              /// Optional, the stroke backgroundColor
                            ),
                          ),
                        )
                      : Container())
            ],
          ))),
      //),
    );
  }

  //!

  Future<bool> _onBack() async {
    bool? goBack;

    var value =
        await webViewController!.canGoBack(); // check webview can go back

    if (value) {
      webViewController!.goBack(); // perform webview back operation

      return false;
    } else {
      debugPrint("statement");
      SystemNavigator.pop();
      /* await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation ',
              style: TextStyle(color: Colors.purple)),

          // Are you sure?
          content: const Text('Do you want exit app ? '),

          // Do you want to go back?

          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);

                setState(() {
                  goBack = false;
                });
              },

              child: const Text('No'), // No
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  goBack = true;
                });
              },

              child: const Text('Yes'), // Yes
            ),
          ],
        ),
      );*/
      goBack = true;
      if (goBack) Navigator.pop(context); // If user press Yes pop the page
      return goBack;
    }
  }
}

const List<Color> _kDefaultRainbowColors = [
  // Colors.red,
  // Colors.orange,
  // Colors.yellow,
  //Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

 /* if (url.contains('instagram.com')) {
                      String p =
                          'https://www.instagram.com/_u/giftoo.in'; //String.parse(url);
                      //pinterest//com.pinterest.EXTRA_DESCRIPTION
                      //instagram.com//com.instagram.android
                      //com.facebook.katana
                      if (await canLaunch(p)) {
                        // Launch the App
                        await launch(
                          p,
                        );
                        // and cancel the request
                        return ShouldOverrideUrlLoadingAction.CANCEL;
                      }
                    } else if (url.contains('com.facebook')) {
                      String p = 'http://m.me/Giftoo.in'; //String.parse(url);
                      //pinterest//com.pinterest.EXTRA_DESCRIPTION
                      //instagram.com//com.instagram.android
                      //com.facebook.katana
                      if (await canLaunch(p)) {
                        // Launch the App
                        await launch(
                          p,
                        );
                        // and cancel the request
                        return ShouldOverrideUrlLoadingAction.CANCEL;
                      }
                    } else if (url.contains('pinterest')) {
                      String p =
                          'http://in.pinterest.com/Giftoo.IN'; //String.parse(url);
                      //pinterest//com.pinterest.EXTRA_DESCRIPTION
                      //instagram.com//com.instagram.android
                      //com.facebook.katana
                      if (await canLaunch(p)) {
                        // Launch the App
                        await launch(
                          p,
                        );
                        // and cancel the request
                        return ShouldOverrideUrlLoadingAction.CANCEL;
                      }
                    } else if (url.contains('twitter')) {
                      String p =
                          'https://twitter.com/GiftooIN'; //String.parse(url);
                      //pinterest//com.pinterest.EXTRA_DESCRIPTION
                      //instagram.com//com.instagram.android
                      //com.facebook.katana
                      if (await canLaunch(p)) {
                        // Launch the App
                        await launch(
                          p,
                        );
                        // and cancel the request
                        return ShouldOverrideUrlLoadingAction.CANCEL;
                      }
                    } else if (url.contains('whatsapp')) {
                      String p =
                          'whatsapp://send?phone=+919322990002'; //String.parse(url);
                      //pinterest//com.pinterest.EXTRA_DESCRIPTION
                      //instagram.com//com.instagram.android
                      //com.facebook.katana
                      if (await canLaunch(p)) {
                        // Launch the App
                        await launch(
                          p,
                        );*/