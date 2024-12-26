// ignore_for_file: depend_on_referenced_packages, file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

import '../../controller/notification/notification_list_controller.dart';
import '../../style/theme_const.dart';
import '../settings.dart';

BuildContext? GL_CONTEXT;

class NotificationHandler {
  // BottomNavigationBarController controller_bottom =
  //     Get.put(BottomNavigationBarController());

  // CategoryDetailController cnt_categoryDetail =
  //     Get.put(CategoryDetailController());

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel androidNotificationChannel =
      const AndroidNotificationChannel('high_importance_channel', 'Sarthak Notification', description: "This is notification channel", importance: Importance.max);

  NotificationHandler() {
    createChannelOnDevice();
    requestPermission();
    _initNotification();
    initMethodForIos();
  }

  NotificationHandler.instance();

  initMethodForIos() async {
    MethodChannel channel = const MethodChannel("com.instanceit.magicretesarthak");
    channel.setMethodCallHandler((call) async {
      if (call.method == "com.notification.ios") {
        print("----${call.arguments['body']}");
      }
    });
  }

  createChannelOnDevice() async {
    if (!kIsWeb) {
      if (Platform.isAndroid)
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidNotificationChannel);
    }
  }

  requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      devPrint("---notification permission granted-----");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      devPrint("----notification permission provisional----");
    } else {
      devPrint("----notification permission denied----");
    }
  }

  onMessageOpenApp(RemoteMessage message) async {
    devPrint("------------------------------------notification permissionp--------------------------------------");
    devPrint(message.data.toString());
    onNotificationClickListener(message.data);
  }

  onMessage(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;

    if (!kIsWeb) if (Platform.isIOS) {
      if (message.notification!.apple!.imageUrl != null && message.notification!.apple!.imageUrl != "") {
        String url = message.notification!.apple!.imageUrl!;
        devPrint("url-----$url");
        showBigNotification(message.notification!, data, url);
      } else {
        showNotification(message.notification!, data);
      }
    } else if (!kIsWeb) if (Platform.isAndroid) {
      if (message.notification!.android!.imageUrl != null && message.notification!.android!.imageUrl != "") {
        String url = data['id'] ?? "";
        devPrint("------image $url");
        showBigNotification(message.notification!, data, url);
      } else {
        showNotification(message.notification!, data);
      }
    }
  }

  _initNotification() async {
    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String payload = notificationResponse.payload ?? "";
    Map<String, dynamic> data = jsonDecode(payload);
    onNotificationClickListener(data);
  }

  showNotification(RemoteNotification notification, Map<String, dynamic> playload) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      "high_importance_channel",
      "Sarthak Notification",
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
      color: ColorTheme.kBlack, // App open
    );

    DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(playload),
    );
  }

  showBigNotification(RemoteNotification notification, Map<String, dynamic> playload, String url) async {
    ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(bigPicture, contentTitle: notification.title, summaryText: notification.body);

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails("high_importance_channel", "Sarthak Notification",
        importance: Importance.max, priority: Priority.high, icon: "@mipmap/ic_launcher", color: ColorTheme.kBlack, styleInformation: bigPictureStyleInformation);

    DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails();

    if (url != "") {
      final String bigPicturePath = await DownloadFile(url);
      devPrint(bigPicturePath);
      iosNotificationDetails = DarwinNotificationDetails(attachments: <DarwinNotificationAttachment>[DarwinNotificationAttachment(bigPicturePath)]);
    }

    NotificationDetails notificationDetails = NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(notification.hashCode, notification.title, notification.body, notificationDetails, payload: jsonEncode(playload));
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    dio.Options options = dio.Options(responseType: dio.ResponseType.bytes);
    dio.Dio d = dio.Dio();
    dio.Response response = await d.getUri(Uri.parse(url), options: options);
    return response.data;
  }

  Future<String> DownloadFile(String AppPrinturl) async {
    Dio dio = new Dio();
    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path;
    final name = p.basename(AppPrinturl);
    devPrint(name);
    devPrint(AppPrinturl);
    var response = await dio.download(AppPrinturl, '$appDocPath/$name');
    if (response.statusCode == 200) {
      return '$appDocPath/$name';
    } else {
      return "";
    }
  }

  onNotificationClickListener(
    Map<String, dynamic> data, {
    bool notformdata = false,
    int clickflgevent = 0,
  }) async {
    print("${data}object1111111");
    if (Settings.isUserLogin) {
      Future.delayed(const Duration(seconds: 1)).then((value) {
        onTapNotification(pagename: data['pagename']);
      });
    }
  }
}
