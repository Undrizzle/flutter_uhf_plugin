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

  //读取标签数据（不指定UII）
  static Future<String> readData({String accessPwd, String bank, String ptr, String cnt}) async {
    return await _channel.invokeMethod('readData', {
      "accessPwd": accessPwd,
      "bank": bank,
      "ptr": ptr,
      "cnt": cnt
    });
  }

  static Future<String> readDataWithQT({String accessPwd, String bank, String ptr, String cnt}) async {
    return await _channel.invokeMethod('readDataWithQT', {
      "accessPwd": accessPwd,
      "bank": bank,
      "ptr": ptr,
      "cnt": cnt
    });
  }
}
