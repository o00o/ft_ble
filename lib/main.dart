import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart'; // use ble

FlutterBlue flutterBlue = FlutterBlue.instance;
// final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
List<BluetoothDevice> devicesList = [];

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
  StreamController<List<BluetoothDevice>> controller =
      new StreamController<List<BluetoothDevice>>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  // void _showScanningStatus() {
  //   // setState(() {
  //   //   _counter++;
  //   // });
  //   //แทนที่จะใช้ setState ก็เซ็ตค่าผ่าน StreamController แทน
  //   controller.add(_counter++);
  // }

  void _scanBle() {
    // Start scanning
    devicesList.clear();
    print('start --> _scanBle');
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      var i = 0;
      for (ScanResult r in results) {
        // r is each result of ble scanning
        print(
            'found device --> ${r.device.id}, ${r.device.name}, rssi: ${r.rssi}');

        if (!devicesList.contains(r.device)) {
          // tested on 20210807: can check and save only new device as expect
          devicesList.add(r.device);
          print(
              'NEW device --> add the device index$i: ${r.device.id}, ${devicesList[i].name}, rssi: ${r.rssi}');
          print(
              ' - devicesList = ${devicesList}\n - r.device    = ${r.device}');
          i = i + 1;
        } else {
          print(
              'same device --> \n - devicesList = ${devicesList}\n - r.device    = ${r.device}');
        }
      }
      print('scan complete --> found ${devicesList.length}');
      for (var device in devicesList) {
        print(' - ${device.id}, ${device.name}');
      }
    });

    print(subscription);
    print('end --> _scanBle');
  }

  void _stopBle() {
    // Stop scanning
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<List<BluetoothDevice>>(
                stream: controller.stream,
                // initialData:0 ,
                builder: (context, snapshot) {
                  // return Text(
                  //   '${snapshot.data}',
                  //   style: Theme.of(context).textTheme.headline4,
                  // );
                  return Column(
                    children: snapshot.data!
                        .map(
                          (d) => Card(
                            child: ListTile(
                              title: Text(
                                d.id.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(d.name),
                              trailing: ElevatedButton(
                                // connect ble device button
                                child: Text(
                                  'Connect',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  // todo: process to connect ble device
                                },
                              ),
                            ),
                            color: Colors.grey.shade200,
                            margin: EdgeInsets.all(5),
                          ),
                        )
                        .toList(),
                  );
                })
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (context, snapshot) {
          controller.add(devicesList);
          if (snapshot.data!) {
            return FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _stopBle,
              tooltip: 'scanning..',
              child: Icon(
                Icons.stop,
                color: Colors.red,
              ),
            );
          } else {
            return FloatingActionButton(
              onPressed: _scanBle,
              tooltip: 'ready to scan',
              child: Icon(Icons.search),
            );
          }
        },
      ),
    );
  }
}
