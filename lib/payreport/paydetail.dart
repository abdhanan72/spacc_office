import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/payreport/payreport.dart';

class PaymentDetails extends StatefulWidget {
  final int paynum;
  const PaymentDetails({super.key, required this.paynum});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  final String url = 'http://cloud.spaccsoftware.com/hanan_api/payment/';

  Future<List<dynamic>> viewpayment() async {
    var response = await http.post(Uri.parse(url), body: {
      'action': 'VIEW',
      'fid': fid,
      'paynumber': widget.paynum.toString()
    });
    var data = jsonDecode(response.body);
    return data['data'];
  }

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fid = prefs.getString('firm_id');
    return fid;
  }

  String? fid;
  @override
  void initState() {
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: viewpayment(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              var item = snapshot.data[0];
              if (snapshot.hasData) {
                TextEditingController datecontroller =
                    TextEditingController(text: item['paydate']);
                TextEditingController paidtocontroller =
                    TextEditingController(text: item['acname']);
                TextEditingController paymethodcontroller =
                    TextEditingController(text: item['pmname']);
                TextEditingController amountcontroller =
                    TextEditingController(text: item['amount']);
                TextEditingController memocontroller =
                    TextEditingController(text: item['memo']);

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
                                    labelText: 'Paid to',
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
                                    labelText: 'Payment Method',
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
                            ElevatedButton(
                                onPressed: () {
                                  showdialog();
                                },
                                child: const Text('DELETE'))
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                ScaffoldMessenger(child: Text(snapshot.error.toString()));
              }
              else{
                Center(child: SizedBox(height: mediaquery.height*0.6,
                width: mediaquery.width*0.7,
                  
                  child: Lottie.asset('assets/85023-no-data.json')));
              }
              
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }

  void deletePayment() async {
  var response = await http.post(Uri.parse(url), body: {
    'action': 'DELETE',
    'fid': fid,
    'paynumber': widget.paynum.toString()
  });
  var jsonResponse = jsonDecode(response.body);
  var responseDesc = jsonResponse['response_desc'];

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(responseDesc),
      duration: Duration(seconds: 2),
    ),
  );
}


    void showdialog() {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('DELETE',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size. height * 0.03,
                    fontWeight: FontWeight.bold)),
            content: Column(
              children: [
                Lottie.asset('assets/100053-delete-bin.json',
                    height: MediaQuery.of(context).size. height * 0.2),
                const Text(
                  'Are you sure you want to Delete this payment?',
                )
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context, true);
                 deletePayment();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const PaymentReport()));
                },
                child: const Text('Yes'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              )
            ],
          );
        },
      );
    }






}
