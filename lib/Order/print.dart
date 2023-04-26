import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';

class Print extends StatefulWidget {
  final List<Map<String, String>> apimap;
  const Print({super.key, required this.apimap});

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> devices = [];
  String devicemsg = "";
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
                    startprint(devices[index]);
                  },
                  leading: const Icon(Icons.print),
                  title: Text(devices[index].name!),
                  subtitle: Text(devices[index].address!),
                );
              },
            ),
    );
  }

  Future<void> startprint(BluetoothDevice device) async {
    if (device.address != null) {
      await bluetoothPrint.connect(device);
      List<LineText> list = [];
      Map<String, dynamic> config = Map();

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "Hindustan Foods\n",
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
    }
  }
}
