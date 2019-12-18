import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_uhf_plugin/flutter_uhf_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _uhfData = ['0', '0', '0'];

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
    List uhfData;
    bool result = false;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await FlutterUhfPlugin.startInventoryTag(flag: 1, initQ: 3);
      if (result) {
        uhfData = await FlutterUhfPlugin.continuousRead();
      }
      result = await FlutterUhfPlugin.stopInventory();
    } on PlatformException catch (err){
      uhfData[0] = err;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _uhfData = uhfData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Center(
              child: Text('UHF tid: ${_uhfData[0]}\n'),
            ),
            Center(
              child: Text('UHF EPC: ${_uhfData[1]}\n'),
            ),
            Center(
              child: Text('UHF RSSI: ${_uhfData[2]}\n'),
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
    );
  }
}
