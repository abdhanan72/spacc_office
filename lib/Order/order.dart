import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
 String stringDate = '';

 @override
  void initState() {
    super.initState();
    stringDate = getCurrentTime();
  }
    String getCurrentTime() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedTime = formatter.format(now);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true,
       elevation: 20,
          title: const Text('Order Entry'),
      ),
      body:Column(
        children: [
          
        ],
      ),
    );
  }
}