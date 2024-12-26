import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

class EncryptRepo {
  static const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  final key = Key.fromUtf8('cfVkxa846Z7XL8BeY2NW6UI23BjLA2J8');

  String encryptData(data) {
    String returnString = '';
    try {
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      String ivString = getRandomString(16);
      final iv = IV.fromUtf8(ivString);
      final encrypted = encrypter.encrypt(data, iv: iv);
      returnString = "${encrypted.base64}.$ivString";
    } catch (e) {
      if (kDebugMode) {
        devPrint("Error:-$e");
      }
    }
    return returnString;
  }

  String decryptedData(String data) {
    String returnString = '';

    try {
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      String ivString = data.split(".").last;
      final iv = IV.fromUtf8(ivString);
      final decrypted = encrypter.decrypt(Encrypted.from64(data.split(".").first), iv: iv);
      returnString = decrypted;
    } catch (e) {
      return jsonEncode(data);
    }
    return returnString;
  }
}
