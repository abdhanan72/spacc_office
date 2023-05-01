import 'package:bluetooth_print/bluetooth_print_model.dart' as thr;
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Print extends StatefulWidget {
  
  const Print({super.key,});

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
   SharedPreferences? prefs;

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<thr.BluetoothDevice> devices = [];
  String devicemsg = "";
  thr.BluetoothDevice? selectedDevice;


   @override
  void initState() {
    initPrefs();
    super.initState();

    // check for default printer on app start
    checkDefaultPrinter();

    // start scanning for devices
    bluetoothPrint.startScan(timeout: const Duration(seconds: 60));
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

      // check for default printer on new device found
      checkDefaultPrinter();
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> checkDefaultPrinter() async {
    String? defaultPrinterAddress = prefs?.getString('defaultPrinter');
    if (defaultPrinterAddress != null && devices.isNotEmpty) {
      thr.BluetoothDevice defaultPrinter = devices.firstWhere(
        (device) => device.address == defaultPrinterAddress,
        orElse: () => devices.first,
      );
      setState(() {
        selectedDevice = defaultPrinter;
      });
    }
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
                final device = devices[index];
                return ListTile(
                  onTap: () async {
                    final selected = devices[index];
                    setState(() {
                      selectedDevice = selected;
                    });

                    // save the selected device as the default printer in shared preferences
                    await prefs?.setString('defaultPrinter', selected.address!);
                  },
                  leading: const Icon(Icons.print),
                  title: Text(devices[index].name!),
                  subtitle: Text(devices[index].address!),
                  tileColor: selectedDevice != null &&
                          selectedDevice!.address == device.address
                      ? Colors.blue[100]
                      : null,
                );
              },
            ),
    );
  }
}
