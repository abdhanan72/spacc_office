import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptEntry extends StatefulWidget {
  const ReceiptEntry({super.key});

  @override
  State<ReceiptEntry> createState() => _ReceiptEntryState();
}

class _ReceiptEntryState extends State<ReceiptEntry> {
  String? username;

  Future<String?> getusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username;
  }

  @override
  void initState() async {
    getusername().then((value) {
      setState(() {
        username = value!;
      });
    });
    print(username);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Entry'),
      ),
      body: Center(child: Text('Sn')),
    );
  }
}
