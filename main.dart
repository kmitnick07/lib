import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/scroll_behaviour.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/firebase_options.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/theme_data.dart';
import 'package:prestige_prenew_frontend/view/layout_template_view.dart';
import 'package:prestige_prenew_frontend/view/splash_screen.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_strategy/url_strategy.dart';
import 'config/api_provider.dart';
import 'config/helper/NotificationHandler.dart';
import 'config/helper/offline_data.dart';
import 'global_screen_bindings.dart';
import 'routes/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
Future<void> myBackgroundHandler(RemoteMessage message) async {
  // NotificationHandler notificationHandler = NotificationHandler();
  // notificationHandler.onNotificationClickListener(message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  NotificationHandler notificationHandler = NotificationHandler();
  FirebaseMessaging.onBackgroundMessage(myBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(notificationHandler.onMessageOpenApp);
  FirebaseMessaging.onMessage.listen(notificationHandler.onMessage);
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      notificationHandler.onMessageOpenApp(message);
    }
  });
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black, statusBarColor: Colors.black));
  // await DisposableImages.init(enableWebCache: false);
  await FastCachedImageConfig.init();
  await Settings.getInstance();
  setPathUrlStrategy();

  html.window.onPopState.listen((event) {
    Get.rootDelegate.history.removeLast();
  });
  if (!kIsWeb) {
    getConnectivity();
  }
  // runApp(const DisposableImages(MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'PRENEW',
      theme: Style.themeData(context),
      debugShowCheckedModeBanner: false,
      initialBinding: GlobalScreenBindings(),
      getPages: RouteGenerator.generate(),
      unknownRoute: GetPage(name: RouteNames.kSplashScreenRoute, transition: navigationTransaction, page: () => const SplashScreen()),
      builder: (context, child) => LayoutTemplateView(child: child!),
      scrollBehavior: MyCustomScrollBehavior().copyWith(overscroll: false),
    );
  }
}
