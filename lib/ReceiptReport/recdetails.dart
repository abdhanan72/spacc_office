import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/License/urls.dart';
import 'package:spacc_office/ReceiptReport/editreceipt.dart';

class ReceiptDetails extends StatefulWidget {
  final int recnumber;
  final String fid;
  const ReceiptDetails({super.key, required this.recnumber, required this.fid});

  @override
  State<ReceiptDetails> createState() => _ReceiptDetailsState();
}

class _ReceiptDetailsState extends State<ReceiptDetails> {
  Future<List<dynamic>> viewReceipt() async {
    var response = await http.post(Uri.parse(receipturl), body: {
      'action': 'VIEW',
      'fid': widget.fid,
      'recnumber': widget.recnumber.toString()
    });
    var data = jsonDecode(response.body);
    return data['data'];
  }

  String? date;
  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fid = prefs.getString('firm_id');
    return fid;
  }

  String? fromcode;
  String? tocode;

  @override
  void initState() {
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    super.initState();
  }

  String? fid;

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: viewReceipt(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var item = snapshot.data[0];
                TextEditingController paidtocontroller =
                    TextEditingController(text: item['acname']);
                TextEditingController paymethodcontroller =
                    TextEditingController(text: item['pmname']);
                TextEditingController amountcontroller =
                    TextEditingController(text: item['amount']);
                TextEditingController memocontroller =
                    TextEditingController(text: item['memo']);
                String dt = item['paydate'];

                final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ssZ');
                DateTime dateTime = dateFormat.parse(dt);
                String formattedshow =
                    DateFormat('dd-MMM-yyyy').format(dateTime);
                String formattedfor = DateFormat('yyyy-MM-dd').format(dateTime);

                TextEditingController datecontroller =
                    TextEditingController(text: formattedshow);
                fromcode = item['accode'];
                tocode = item['paymethod'];

                return Expanded(
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(top: mediaquery.height * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mediaquery.width * 0.1),
                              child: TextFormField(
                                autofocus: false,
                                readOnly: true,
                                controller: datecontroller,
                                decoration: InputDecoration(
                                    labelText: 'Date',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: mediaquery.height * 0.04,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mediaquery.width * 0.1),
                              child: TextFormField(
                                autofocus: false,
                                readOnly: true,
                                controller: paidtocontroller,
                                decoration: InputDecoration(
                                    labelText: 'Received from',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: mediaquery.height * 0.04,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mediaquery.width * 0.1),
                              child: TextFormField(
                                autofocus: false,
                                readOnly: true,
                                controller: paymethodcontroller,
                                decoration: InputDecoration(
                                    labelText: 'Received to',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: mediaquery.height * 0.04,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mediaquery.width * 0.1),
                              child: TextFormField(
                                autofocus: false,
                                readOnly: true,
                                controller: amountcontroller,
                                decoration: InputDecoration(
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: mediaquery.height * 0.04,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mediaquery.width * 0.1),
                              child: TextFormField(
                                maxLines: 3,
                                autofocus: false,
                                readOnly: true,
                                controller: memocontroller,
                                decoration: InputDecoration(
                                    labelText: 'Memo',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: mediaquery.height * 0.04,
                            ),
                            SizedBox(
                              height: mediaquery.height * 0.05,
                              width: mediaquery.width * 0.3,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditReceipt(
                                              recnumber: widget.recnumber,
                                              paidto: paidtocontroller.text,
                                              paymentMethod:
                                                  paymethodcontroller.text,
                                              amount: amountcontroller.text,
                                              memo: memocontroller.text,
                                              recdate: formattedfor,
                                              fromcode: fromcode!,
                                              tocode: tocode!),
                                        ));
                                  },
                                  child: const Text('Edit/Delete')),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                ScaffoldMessenger(child: Text(snapshot.error.toString()));
              } else {
                Center(
                    child: SizedBox(
                        height: mediaquery.height * 0.6,
                        width: mediaquery.width * 0.7,
                        child: Lottie.asset('assets/85023-no-data.json')));
              }

              return const Center(child: LinearProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
