import 'dart:async';
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
  static Future<bool> startInventoryTag() async {
    return await _channel.invokeMethod('startInventoryTag');
  }

  //循环读取标签数据
  static Stream<dynamic> continuousRead() {
    return _eventChannel.receiveBroadcastStream();
  }

  //停止识别
  static Future<bool> stopInventory() async {
    return await _channel.invokeMethod('stopInventory');
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
}
