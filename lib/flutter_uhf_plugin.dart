import 'dart:async';

import 'package:flutter/services.dart';

class FlutterUhfPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_uhf_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //初始化UHF模块
  static Future<bool> initUHF() async {
    return await _channel.invokeMethod('initUHF');
  }

  //关闭UHF模块
  static Future<bool> freeUHF() async {
    return await _channel.invokeMethod('freeUHF');
  }

  //单步识别标签
  static Future<String> readSingleTag() async {
    return await _channel.invokeMethod('readSignleTag');
  }
}
