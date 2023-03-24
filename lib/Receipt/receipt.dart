import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptEntry extends StatefulWidget {
  const ReceiptEntry({super.key});

  @override
  State<ReceiptEntry> createState() => _ReceiptEntryState();
}

class _ReceiptEntryState extends State<ReceiptEntry> {
  String? userName;
 

  @override
  void initState() {
    getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });

    super.initState();
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('user_name');
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Entry'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [

          if(userName!=null)
          Center(child: Text(userName!))

        ],
      )
      
      
    );
  }
}
