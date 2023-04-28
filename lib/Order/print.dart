import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_print/bluetooth_print_model.dart' as thr;
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:spacc_office/Order/order.dart';

class Print extends StatefulWidget {
  final List<Map<String, String>> apimap;
  const Print({super.key, required this.apimap});

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<thr.BluetoothDevice> devices = [];
  String devicemsg = "";
  thr.BluetoothDevice? selectedDevice;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => initprinter());
    super.initState();
  }

  Future<void> initprinter() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 2));
    if (!mounted) return;

    bluetoothPrint.scanResults.listen((val) {
      if (!mounted) return;
      setState(() {
        devices = val;
      });
      if (devices.isEmpty) {
        setState(() {
          devicemsg = "No Devices";
        });
      }
    });
  }

  Future<void> printData() async {
    if (selectedDevice == null) return;

    BluetoothConnection connection;
    try {
      connection = await BluetoothConnection.toAddress(selectedDevice!.address);
      print("Connected to printer.");
    } catch (ex) {
      print("Error connecting to printer: $ex");
      return;
    }

    // Send "Hello World" to the printer
    String text = "Hello World this is a test print from my flutter APP\n";
    Uint8List bytes = Uint8List.fromList(utf8.encode(text));
    connection.output.add(bytes);
    await connection.output.allSent;

    // Close the connection
    await connection.close();
    print("Connection closed.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Printer'),
      ),
      body: devices.isEmpty
          ? Center(
              child: Text(devicemsg),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      selectedDevice = devices[index];
                    });
                    printData();
                  },
                  leading: const Icon(Icons.print),
                  title: Text(devices[index].name!),
                  subtitle: Text(devices[index].address!),
                );
              },
            ),
    );
  }
}
