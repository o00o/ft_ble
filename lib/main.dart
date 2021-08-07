import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart'; // use ble

FlutterBlue flutterBlue = FlutterBlue.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BLE Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  StreamController<int> controller = new StreamController<int>();

  @override
  void initState() {
    super.initState();
    controller.add(_counter);
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  void _incrementCounter() {
    // setState(() {
    //   _counter++;
    // });
    //แทนที่จะใช้ setState ก็เซ็ตค่าผ่าน StreamController แทน
    controller.add(_counter++);
  }

  void _scanBle() {
    // Start scanning
    print('start: scanning ble');
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

  // Stop scanning
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            StreamBuilder(
                stream: controller.stream,
                // initialData:0 ,
                builder: (context, snapshot) {
                  return  Text(
                        '${snapshot.data}',
                        style: Theme.of(context).textTheme.headline4,
                      );
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _incrementCounter,
        onPressed: _scanBle,
        tooltip: 'Increment',
        child: Icon(Icons.search),
      ),
    );
  }
}
