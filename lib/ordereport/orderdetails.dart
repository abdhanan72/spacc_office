import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spacc_office/License/urls.dart';

class OrderDetails extends StatefulWidget {
  final int ordnumber;
  final String custnumber;
  final String custname;
  final String totalamount;
  final String fid;
  const OrderDetails(
      {super.key,
      required this.ordnumber,
      required this.custnumber,
      required this.custname,
      required this.totalamount,
      required this.fid});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? custnumber;
  String? custname;
  String? totalamount;
  Map<String, dynamic> orderData = {};
  List<dynamic> itemdata = [];
  Future<void> fetchOrderDetails() async {
    final body = {
      'action': 'VIEW',
      'ordnumber': widget.ordnumber.toString(),
      'fid': widget.fid
    };
    final response = await http.post(Uri.parse(orderurl), body: body);

    if (response.statusCode == 200) {
      setState(() {
        orderData = jsonDecode(response.body)['data'];
        itemdata = orderData['itemdata'];
      });
    } else {
      throw Exception('Failed to fetch order');
    }
  }

  String? firmId;
  @override
  void initState() {
    fetchOrderDetails();
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
            Text(
              'Customer Name: ${orderData['cust_name']}',
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itemdata.length,
                itemBuilder: (context, index) {
                  final item = itemdata[index];
                  return ListTile(
                    title:Text('itemcode:${item['item_code']}') ,
                    subtitle:
                        Text('Qty: ${item['qty']} - Rate: ${item['rate']}'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
