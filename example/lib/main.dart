import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_uhf_plugin/flutter_uhf_plugin.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _uhfData = { 'tid': '', 'rssi': ''};
  FocusNode _focusNode = FocusNode();


  AudioCache audioCache = AudioCache();

  @override
  void initState() {
    super.initState();
    FlutterUhfPlugin.initUHF();
    loadFile();
  }

  @override
  void dispose() {
    FlutterUhfPlugin.freeUHF();
    audioCache.clearCache();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> loadFile() async {
    await audioCache.load('audios/barcodebeep.ogg');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> readRFID() async {
    var uhfData;
    bool result = false;

    try {
      result = await FlutterUhfPlugin.startInventoryTag();
      if (result) {
        try {
          await for (uhfData in FlutterUhfPlugin.continuousRead()) {
            print(uhfData);

            if (uhfData != null) {
              audioCache.play("audios/barcodebeep.ogg", mode: PlayerMode.LOW_LATENCY);
              setState(() {
                _uhfData['tid'] = uhfData['tid'];
                _uhfData['rssi'] = uhfData['rssi'];
              });
            }
          }
        } on PlatformException {
          showToast("get tid error");
        }
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
      audioCache.play("audios/barcodebeep.ogg");
    } on PlatformException {
      showToast('read single error');
    }
  }

  Future<void> stop() async {
    try {
      await FlutterUhfPlugin.stopInventory();
      showToast('stop success');
    } on PlatformException {
      showToast('stop error');
    }
  }

  void _handleKeydown(RawKeyEvent event) {
    print("come to key event");
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      print(rawKeyEventDataAndroid.keyCode);
      if (rawKeyEventDataAndroid.keyCode == 139 || rawKeyEventDataAndroid.keyCode == 280) {
        readRFID();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    return OKToast(
          child: MaterialApp(
            home:
            Scaffold(
              appBar: AppBar(
                title: const Text('Plugin example app'),
              ),
              body: new RawKeyboardListener(
                focusNode: _focusNode,
                onKey: (RawKeyEvent event){
                  print("come to key event");
                },
                child: Column(
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
    );
  }
}
