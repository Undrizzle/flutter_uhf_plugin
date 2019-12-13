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
  String _uhfTid = 'Unknown';
  String _uhfData = 'UnKnown';
  String _uhfDataQT = 'Unknown';

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
    String uhfTid;
    String uhfData;
    String uhfDataQT;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      uhfTid = await FlutterUhfPlugin.readSingleTag();
      uhfData = await FlutterUhfPlugin.readData(accessPwd: "00000000", bank: "UII", ptr: "1", cnt: "7");
      uhfDataQT = await FlutterUhfPlugin.readDataWithQT(accessPwd: "00000000", bank: "UII", ptr: "0", cnt: "4");
    } on PlatformException {
      uhfTid = 'Failed to read uhf tid';
      uhfData = 'Failed to read uhf data';
      uhfDataQT = 'Failed to read uhf data QT';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _uhfTid = uhfTid;
      _uhfData = uhfData;
      _uhfDataQT = uhfDataQT;
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
              child: Text('UHF EPC: $_uhfTid\n'),
            ),
            Center(
              child: Text('UHF DATA: $_uhfData\n'),
            ),
            Center(
              child: Text('UHF DATA QT: $_uhfDataQT\n'),
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
