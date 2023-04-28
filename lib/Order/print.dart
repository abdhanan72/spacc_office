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
    String receipt = "------------------------------------------------\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(33) +
        String.fromCharCode(24);
    receipt += "              Hindustan Foods\n";
     receipt += String.fromCharCode(27) +
        String.fromCharCode(33) +
        String.fromCharCode(0);
    receipt += "              123 Main St.\n";
    receipt += "             City, State ZIP\n";
    receipt += "           Tel: (555) 555-5555\n";
    receipt += "      Date: ${DateTime.now().toString()}\n";
    receipt += "------------------------------------------------\n";
    receipt += "ITEM                QTY    RATE    AMOUNT\n";
    receipt += "------------------------------------------------\n";

    double total = 0.0;
    for (var item in widget.apimap) {
      String itemName = item['itemname']!;
      int qty = int.tryParse(item['qty']!) ?? 0;
      double rate = double.tryParse(item['rate']!) ?? 0.0;
      double amount = qty * rate;
      total += amount;
      String amountString = amount.toStringAsFixed(2);
      int itemPadding = 18;
      int remainingWidth = 32 - itemPadding;
      String qtyString = qty.toString().padLeft(3);
      String rateString = rate.toStringAsFixed(2).padLeft(6);
      String line =
          itemName.substring(0, remainingWidth).padRight(itemPadding) +
              qtyString +
              ' ' * 4 +
              rateString +
              ' ' * 6 +
              amountString;
      receipt += line + '\n';
      if (itemName.length > remainingWidth) {
        for (int i = remainingWidth; i < itemName.length; i += remainingWidth) {
          int endIndex = i + remainingWidth;
          if (endIndex > itemName.length) {
            endIndex = itemName.length;
          }
          line = itemName.substring(i, endIndex).padRight(itemPadding) +
              ' ' * (3 + 6 + 3) +
              ' ' * (amountString.length - 1) +
              '\n';
          receipt += line;
        }
      }
    }

    receipt += "------------------------------------------------\n";
    receipt +=
        "                 Total:${total.toStringAsFixed(2).padLeft(9)}\n";
    receipt += "------------------------------------------------\n";
    receipt += "        Thank you for your business!\n";
    // receipt += "------------------------------------------------\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(74) +
        String.fromCharCode(110);

    // Send the receipt to the printer
    Uint8List bytes = Uint8List.fromList(utf8.encode(receipt));
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
