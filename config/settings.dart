import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/encrypt_repo.dart';
import 'package:prestige_prenew_frontend/config/shared_pref.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:universal_html/html.dart";

import '../utils/aws_service/file_data_model.dart';

class Settings {
  static Settings? _settings;
  static SharedPreferences? preferences;

  static Future<Settings?> getInstance() async {
    if (_settings == null) {
      final secureStorage = Settings._();
      await secureStorage._init();
      _settings = secureStorage;
    }
    return _settings;
  }

  Settings._();

  Future _init() async {
    preferences = await SharedPreferences.getInstance();
    if (kIsWeb && (isUserLogin && DateTime.now().difference(logoutTime) > Duration(minutes: Config.sessionTimeOutMinutes))) {
      preferences?.clear();
    }
  }

  static String get authToken => getLocalString(SharedPref.token) ?? '';

  static set authToken(String value) => setLocalString(SharedPref.token, value);

  static DateTime get logoutTime => DateTime.parse(getLocalString(SharedPref.sessionLogout) ?? DateTime.now().toIso8601String());

  static set logoutTime(DateTime value) => setLocalString(SharedPref.sessionLogout, value.toIso8601String());

  static String get unqKey => getLocalString(SharedPref.unqKey) ?? "";

  static set unqKey(String value) => setLocalString(SharedPref.unqKey, value);

  static String get uid => getLocalString(SharedPref.uid) ?? "";

  static set uid(String value) => setLocalString(SharedPref.uid, value);

  static String get userName => getLocalString(SharedPref.userName) ?? "";

  static set userName(String value) => setLocalString(SharedPref.userName, value);

  static String get email => getLocalString(SharedPref.email) ?? "";

  static set email(String value) => setLocalString(SharedPref.email, value);

  // static String get profile => getLocalString(SharedPref.profile) ?? "";

  // static set profile(String value) => setLocalString(key, value)(SharedPref.profile, value);

  static FilesDataModel get profile => FilesDataModel.fromJson(jsonDecode(getLocalString(SharedPref.profile) ?? '{}'));

  static set profile(FilesDataModel value) => setLocalString(SharedPref.profile, jsonEncode(value.toJson()));

  static String get userRoleId => getLocalString(SharedPref.userroleid) ?? "";

  static set userRoleId(String value) => setLocalString(SharedPref.userroleid, value);

  static String get userRole => getLocalString(SharedPref.userrole) ?? "";

  static set userRole(String value) => setLocalString(SharedPref.userrole, value);

  static LoginDataModel get loginData => LoginDataModel.fromJson(jsonDecode(getLocalString(SharedPref.loginData) ?? '{}'));

  static set loginData(LoginDataModel value) => setLocalString(SharedPref.loginData, jsonEncode(value.toJson()));

  static String get adminEmail => getLocalString(SharedPref.adminEmail) ?? "";

  static set adminEmail(String value) => setLocalString(SharedPref.adminEmail, value);

  static String get adminPassword => getLocalString(SharedPref.adminPassword) ?? "";

  static set adminPassword(String value) => setLocalString(SharedPref.adminPassword, value);

  static bool get isUserLogin => getLocalBool(SharedPref.isUserLogin) ?? false;

  static set isUserLogin(bool value) => setLocalBool(SharedPref.isUserLogin, value);

  static bool get updatenotnow => getLocalBool(SharedPref.updatenotnow) ?? false;

  static set updatenotnow(bool value) => setLocalBool(SharedPref.updatenotnow, value);

  static bool get isMSLogin => getLocalBool(SharedPref.isMSLogin) ?? false;

  static set isMSLogin(bool value) => setLocalBool(SharedPref.isMSLogin, value);

  static Map get offlineDropdownDataList => jsonDecode(getLocalString(SharedPref.offlineDropdownDataList) ?? "{}");

  static set offlineDropdownDataList(Map value) => setLocalString(SharedPref.offlineDropdownDataList, jsonEncode(value));

  static Map get offlineFieldDataList {
    try {
      return jsonDecode(getLocalString(SharedPref.offlineFieldDataList) ?? "{}");
    } catch (e) {
      return {};
    }
  }

  static set offlineFieldDataList(Map value) => setLocalString(SharedPref.offlineFieldDataList, jsonEncode(value));

  static List get offlineTenantDataList {
    try {
      return jsonDecode(getLocalString(SharedPref.offlineTenantDataList) ?? "{}")['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static set offlineTenantDataList(List value) => setLocalString(SharedPref.offlineTenantDataList, jsonEncode({"data": value}));

  static String getLocalKey(String key) {
    return "flutter.$key";
  }

  static Future<void> setLocalString(String key, String value) async {
    if (Config.isPreferenceEncrypted) {
      value = EncryptRepo().encryptData(value);
    }
    preferences?.setString(key, value);
  }

  static void setLocalBool(String key, bool value) {
    preferences?.setBool(key, value);
  }

  static String? getLocalString(String key) {
    if (kIsWeb) {
      try {
        if (Config.isPreferenceEncrypted) {
          return EncryptRepo().decryptedData(jsonDecode(window.localStorage[getLocalKey(key)] ?? ''));
        } else {
          return jsonDecode(window.localStorage[getLocalKey(key)] ?? '');
        }
      } catch (e) {
        return null;
      }
    } else {
      if (Config.isPreferenceEncrypted) {
        return EncryptRepo().decryptedData(preferences?.getString(key) ?? '');
      } else {
        return preferences?.getString(key) ?? '';
      }
    }
  }

  static bool? getLocalBool(String key) {
    if (kIsWeb) {
      // try {
      return jsonDecode(window.localStorage[getLocalKey(key)] ?? "false");
      // } catch (e) {
      //   return null;
      // }
    } else {
      return preferences?.getBool(key);
    }
  }

  static void clearKey(String key) {
    preferences?.remove(key);
  }

  static void clear() {
    preferences?.clear();
  }
}
