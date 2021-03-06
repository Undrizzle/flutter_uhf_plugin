import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class FlutterUhfPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_uhf_plugin');
  static const EventChannel _eventChannel = const EventChannel('tidStream');

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
    return await _channel.invokeMethod('readSingleTag');
  }

  //循环识别标签
  static Future<bool> startInventoryTag({int flag, int initQ}) async {
    return await _channel.invokeMethod('startInventoryTag', {
      "flag": flag,
      "initQ": initQ
    });
  }

  //循环读取标签数据
  static Stream<dynamic> continuousRead() {
    return _eventChannel.receiveBroadcastStream();
  }

  //停止循环识别
  static Future<bool> stopInventory() async {
    return await _channel.invokeMethod('stopInventory');
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

  //读取标签数据（不指定UII），用于R2000 QT标签
  static Future<String> readDataWithQT({String accessPwd, String bank, String ptr, String cnt}) async {
    return await _channel.invokeMethod('readDataWithQT', {
      "accessPwd": accessPwd,
      "bank": bank,
      "ptr": ptr,
      "cnt": cnt
    });
  }

  //读取模块的工作模式
  static Future<int> getFrequencyMode() async {
    return await _channel.invokeMethod('getFrequencyMode');
  }

  //设置模块的工作模式
  static Future<bool> setFrequencyMode(int mode) async {
    return await _channel.invokeMethod('setFrequencyMode', {
      "mode": mode
    });
  }

  //读取模块的功率
  static Future<int> getPower() async {
    return await _channel.invokeMethod('getPower');
  }

  //设置模块的功率
  static Future<bool> setPower(int power) async {
    return await _channel.invokeMethod('setPower', {
      'power': power
    });
  }

  //获取占空比，仅适用于R2000模块
  static Future<Int32List> getPwm() async {
    return await _channel.invokeMethod('getPwm');
  }

  /*
    设置占空比，仅适用于R2000模块
    params: workTime(0~255ms), waitTime(0~255ms)
   */
  static Future<bool> setPwm({int workTime, int waitTime}) async {
    return await _channel.invokeMethod('setPwm', {
      'workTime': workTime,
      'waitTime': waitTime,
    });
  }
}
