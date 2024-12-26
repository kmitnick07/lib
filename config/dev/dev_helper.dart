import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

void devPrint(Object? object) {
  if (kDebugMode) {
  print('$object');
  }
}

void devLog(Object? object) {
  log('$object');
}

jsonPrint(var object, {var tag}) {
  var encoder = const JsonEncoder.withIndent("     ");
  try {
    devPrint('${tag ?? "--->"} : ${encoder.convert(object)}');
  } catch (e) {
    devPrint('${tag ?? "--->"} :$object');
  }
}

void jsonLog(var object, {var tag}) {
  var encoder = const JsonEncoder.withIndent("     ");
  try {
    devLog('$tag : ${encoder.convert(object)}');
  } catch (e) {
    devLog('$tag :$object');
  }
}
