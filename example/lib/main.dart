import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_uhf_plugin/flutter_uhf_plugin.dart';
import 'package:oktoast/oktoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _uhfData = { 'tid': '', 'rssi': ''};
  FocusNode _focusNode = FocusNode();
  //Timer _timer;

  @override
  void initState() {
    super.initState();
    FlutterUhfPlugin.initUHF();
  }

  @override
  void dispose() {
    FlutterUhfPlugin.freeUHF();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> readRFID() async {
    //var uhfData = new UhfBufferData('1', '1', '1');
    //UhfBufferData uhfData;
    bool result = false;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await FlutterUhfPlugin.startInventoryTag(flag: 0, initQ: 0);
      if (result) {
        /*_timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          try {
            uhfData = await FlutterUhfPlugin.continuousRead();
          } on PlatformException catch (err) {
            showToast(err.toString());
          }

          if (uhfData != null) {
            setState(() {
              _uhfData['tid'] = uhfData.tid;
              _uhfData['rssi'] = uhfData.rssi;
            });
          }
        });*/
      }
    } on PlatformException catch (err){
      showToast(err.toString());
    }
  }

  Future<void> readSingle() async {
    String tid;
    try {
      tid = await FlutterUhfPlugin.readSingleTag();
      setState(() {
        _uhfData['tid'] = tid;
      });
    } on PlatformException catch (err) {
      showToast(err.toString());
    }
  }

  Future<void> stop() async {
    try {
      await FlutterUhfPlugin.stopInventory();
      //_timer.cancel();
      //_timer = null;
      showToast('stop success');
    } on PlatformException catch (err){
      showToast(err.toString());
    }
  }

  void _handleKeydown(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      print(rawKeyEventDataAndroid.keyCode);
      if (rawKeyEventDataAndroid.keyCode == 139 || rawKeyEventDataAndroid.keyCode == 280) {
        readRFID();
      }
    }
  }

/*
  Future<void> isolateContinuousRead() async {
    final response = ReceivePort();
    await Isolate.spawn(continuousRead, response.sendPort);
    final sendPort = await response.first;
    final answer = ReceivePort();
    sendPort.send([answer.sendPort]);
  }

  void continuousRead(SendPort port) {
    final rPort = ReceivePort();
    port.send(rPort.sendPort);
    rPort.listen((message) {
      final send = message[0] as SendPort;
      send.send(getTIDandEPC);
    });
  }

  Future<void> getTIDandEPC(bool isLoop) async {
    UhfBufferData uhfData;
    try {
      uhfData = await FlutterUhfPlugin.continuousRead();
    } on PlatformException {
      showToast("get TID and EPC error");
    }

    if (uhfData != null) {
      setState(() {
        _uhfData['tid'] = uhfData.tid;
        _uhfData['rssi'] = uhfData.rssi;
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: new RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeydown,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Plugin example app'),
              ),
              body: Column(
                children: <Widget>[
                  Center(
                    child: Text('UHF tid: ${_uhfData['tid']}\n'),
                  ),
                  Center(
                    child: Text('UHF RSSI: ${_uhfData['rssi']}\n'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: FlatButton(
                      onPressed: () {
                        readSingle();
                      },
                      child: Text('单歩'),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: FlatButton(
                      onPressed: () {
                        stop();
                      },
                      child: Text('stop'),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  readRFID();
                },
                tooltip: 'Read RFID',
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
    );
  }
}
