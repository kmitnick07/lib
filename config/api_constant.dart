import 'package:flutter/foundation.dart';

BuildFor buildFor = BuildFor.dev;

class ApiConstant {
  static String baseUrl = kDebugMode ? LocalUrl.melvin8082 : LocalUrl.melvin ?? deployUrl;

  static String deployUrl = buildFor.isDev
      ? 'https://devapi.prenew.in/v1'
      : buildFor.isUat
          ? "https://uatapi.prenew.in/v1"
          : "https://api.prenew.in/v1";

  static String getAccTokenUrl = '$baseUrl/getaccesstoken';
  static String login = '$baseUrl/login';
  static String employeeLogin = '$baseUrl/employee/login';
  static String forgetPassword = '$baseUrl/forgotpasswordrequest';
  static String resetPassword = '$baseUrl/resetpassword';
  static String appVersion = '$baseUrl/appversion';
  static String loginData = '$baseUrl/logindata';
  static String logOut = '$baseUrl/logout';
  static String appInit = '$baseUrl/appinit';
}

class HeaderConstant {
  static const String apiKey = "Prenew_98F2B6E0-240A-457B-853A-A0079862315F";
  static const String issuer = 'website';
}

class LocalUrl {
  static String vatsal = "http://192.168.1.40:8081/v1";
  static String melvin = "http://192.168.1.32:8081/v1";
  static String melvin8082 = "http://192.168.1.32:8082/v1";
  static String ishan = "http://192.168.1.33:8081/v1";
  static String ishan8082 = "http://192.168.1.33:8082/v1";
}

enum BuildFor {
  dev,
  uat,
  prod,
  ;

  bool get isDev => this == BuildFor.dev;

  bool get isUat => this == BuildFor.uat;

  bool get isProd => this == BuildFor.prod;
}
