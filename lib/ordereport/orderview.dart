import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spacc_office/ordereport/orderdetails.dart';
import '../License/urls.dart';

class OrderView extends StatefulWidget {
  final int ordnumber;
  final String custnumber;
  final String custname;
  final String totalamount;
  final String fid;
  final String orddate;
  const OrderView(
      {super.key,
      required this.ordnumber,
      required this.custnumber,
      required this.custname,
      required this.totalamount,
      required this.fid,
      required this.orddate});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
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
        // ignore: avoid_function_literals_in_foreach_calls
        itemdata.forEach((item) {
          item.addAll({
            'amount': (double.parse(item['qty']) * double.parse(item['rate']))
                .toString()
          });
        });
      });
    } else {
      throw Exception('Failed to fetch order');
    }
  }

  double getSumOfAmounts() {
    return itemdata.fold(
        0, (total, item) => total + double.parse(item['amount']!));
  }

  String? firmId;
  @override
  void initState() {
    fetchOrderDetails();
    super.initState();
    fetchOrderDetails().then((_) {
      setState(() {
        // ignore: avoid_function_literals_in_foreach_calls
        itemdata.forEach((item) {
          item.addAll({
            "amount": (double.parse(item["qty"]) * double.parse(item["rate"]))
                .toString()
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [SizedBox(
              height: mediaquery.height * 0.02,
            ),
            Text(widget.custname,style: TextStyle(color: Colors.teal,fontSize: mediaquery.width*0.09,fontWeight: FontWeight.bold),),
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
            itemdata.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: itemdata.length,
                      itemBuilder: (context, index) {
                        final item = itemdata[index];

                        return Column(
                          children: [
                            const Divider(
                              thickness: 2,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: mediaquery.width * 0.02,
                                  right: mediaquery.width * 0.01),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    item['item_name']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                                  SizedBox(
                                    width: mediaquery.width * 0.1,
                                  ),
                                  Text("(${item["qty"]}X${item["rate"]})"),
                                  SizedBox(
                                    width: mediaquery.width * 0.2,
                                  ),
                                  Text(
                                    item["amount"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const LinearProgressIndicator(),
            SizedBox(
              height: mediaquery.height * 0.2,
              width: mediaquery.width,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.amber),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total Amount:${getSumOfAmounts().toString()}",
                      style: TextStyle(fontSize: mediaquery.width * 0.06),
                    ),
                    SizedBox(
                      height: mediaquery.height * 0.01,
                    ),
                    CupertinoButton.filled(
                      child: const Text('Edit/Save'),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                  ordnumber: widget.ordnumber,
                                  custnumber: widget.custnumber,
                                  custname: widget.custname,
                                  totalamount: widget.totalamount,
                                  fid: widget.fid,
                                  orddate: widget.orddate),
                            ));
                      },
                    ),
                    SizedBox(
                      height: mediaquery.height * 0.01,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
