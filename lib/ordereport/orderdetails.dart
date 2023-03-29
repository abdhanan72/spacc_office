import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../License/urls.dart';

class OrderDetails extends StatefulWidget {
  final int ordnumber;
  final String custnumber;
  final String custname;
  final String totalamount;
  const OrderDetails(
      {super.key,
      required this.ordnumber,
      required this.custnumber,
      required this.custname,
      required this.totalamount});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? custnumber;
  String? custname;
  String? totalamount;
  Future<List<dynamic>> datacall() async { 
  var response = await http.post(Uri.parse(orderurl), body: {
    'action': 'VIEW',
    'fid': firmId,
    'ordnumber': widget.ordnumber,
  });
  var data = jsonDecode(response.body);
  List<dynamic> itemData = data['data']['itemdata'];
  return itemData;
}


  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firmId = prefs.getString('firm_id');
    return firmId;
  }

  String? firmId;

  @override
  void initState() {
    getFirmId().then((value) {
      setState(() {
        firmId = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: mediaquery.height * .02,
            ),
            Text(
              widget.custname,
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: mediaquery.height * 0.02,
            ),
            SizedBox(
              height: mediaquery.height * 0.08,
              child: Container(
                color: Colors.blueGrey,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: mediaquery.width * 0.04,
                      right: mediaquery.width * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Item',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Amount',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: mediaquery.height * 0.01,
            ),
            FutureBuilder<List<dynamic>>(
              future: datacall(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                
                if (snapshot.hasData) {
      List<dynamic> itemData = snapshot.data!;
      return ListView.builder(
        itemCount: itemData.length,
        itemBuilder: (context, index) {
          final item = itemData[index];
          return ListTile(
            title: Text(item['item_code']),
            subtitle: Text('Qty: ${item['qty']}, Rate: ${item['rate']}'),
          );
        },
      );
    }else if(snapshot.hasError){
                  const Center(child: CircularProgressIndicator());
                }

                return const LinearProgressIndicator();
              },
            )
          ],
        ),
      ),
    );
  }
}
