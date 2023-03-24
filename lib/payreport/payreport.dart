import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/payreport/paydetail.dart';

class PaymentReport extends StatefulWidget {
  const PaymentReport({super.key});

  @override
  State<PaymentReport> createState() => _PaymentReportState();
}

class _PaymentReportState extends State<PaymentReport> {
  final String url = 'http://cloud.spaccsoftware.com/hanan_api/payment/';
  

  Future<List<dynamic>> _fetchData() async {
    var response = await http.post(Uri.parse(url), body: {
      'action': 'LIST',
      'date1': fromdate.text,
      'date2': todate.text,
      'fid': fid,
    });
    var data = jsonDecode(response.body);
    return data['data'];
  }

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fid = prefs.getString('firm_id');
    return fid;
  }



  






  @override
  void initState() {
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    super.initState();
  }

  bool _isLoading = false;
  String? select;
  String? fid;
  TextEditingController fromdate = TextEditingController(),
      todate = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: mediaquery.height * 0.07,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: fromdate,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  labelText: 'From Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickdate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100));

                if (pickdate != null) {
                  String formateddate =
                      DateFormat("yyyy-MM-dd").format(pickdate);
                  setState(() {
                    fromdate.text = formateddate.toString();
                  });
                } else {}
              },
            ),
          ),
          SizedBox(height: mediaquery.height * 0.04),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: todate,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  labelText: 'To Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickeddate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100));

                if (pickeddate != null) {
                  String formatdate =
                      DateFormat("yyyy-MM-dd").format(pickeddate);
                  setState(() {
                    todate.text = formatdate.toString();
                  });
                } else {
                  print('Invalid date');
                }
              },
            ),
          ),
          SizedBox(
            height: mediaquery.height * 0.04,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
              },
              child: const Text('Get Report')),
          SizedBox(
            height: mediaquery.height * 0.04,
          ),
          if (_isLoading)
            FutureBuilder<List<dynamic>>(
              future: _fetchData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var item = snapshot.data[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentDetails(paynum:item['paynumber'] ,),
                                ));
                          },
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: mediaquery.width * 0.02,
                                right: mediaquery.width * 0.02,
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      thickness: mediaquery.height * 0.00125,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: mediaquery.height * 0.002),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('#${item['paynumber']}'),
                                        Text('Date:${item['paydate']}'),
                                      ],
                                    ),
                                    SizedBox(height: mediaquery.height * 0.02),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Paid to:${item['acname']}'),
                                        Text('Amount:${item['amount']}')
                                      ],
                                    )
                                  ])),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text("Not a valid date ");
                }
                return const CircularProgressIndicator();
              },
            ),
        ],
      ),
    );
  }
}
