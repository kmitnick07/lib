import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/controller/splash_controller.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

import '../components/prenew_logo.dart';
import '../config/settings.dart';
import '../controller/layout_templete_controller.dart';
import '../routes/route_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Get.rootDelegate.history.clear();
    Settings.isUserLogin ? navigateTo(RouteNames.kDashboard) : navigateTo(RouteNames.kLoginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorTheme.kWhite,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: FittedBox(
            child: PrenewLogo(
              size: 250,
              showName: true,
            ),
          ),
        ),
      ),
    );
  }
}
