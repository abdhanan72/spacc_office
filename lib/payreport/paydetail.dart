import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder(
            future: viewpayment(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                TextEditingController datecontroller = TextEditingController();

                return Expanded(
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      var item = snapshot.data[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: datecontroller,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                          Text(item['paydate'])
                        ],
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                ScaffoldMessenger(child: Text(snapshot.error.toString()));
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
