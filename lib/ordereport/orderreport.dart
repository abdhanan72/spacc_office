import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/License/urls.dart';
import 'package:spacc_office/ordereport/orderdetails.dart';

class OrderReport extends StatefulWidget {
  const OrderReport({super.key});

  @override
  State<OrderReport> createState() => _OrderReportState();
}

class _OrderReportState extends State<OrderReport> {
  Future<List<dynamic>> _fetchData() async {
    var response = await http.post(Uri.parse(orderurl), body: {
      'action': 'LIST',
      'date1': apidate1,
      'date2': apidate2,
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

  String? apidate1;
  String? apidate2;
  String? date;
  String formattedfor = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedshow = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  @override
  void initState() {
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    date = '';
    apidate1 = formattedfor;
    apidate2 = formattedfor;
    fromdate.text = formattedshow;
    todate.text = formattedshow;
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
                      DateFormat("dd-MMM-yyyy").format(pickdate);

                  String setdate1 = DateFormat("yyyy-MM-dd").format(pickdate);
                  setState(() {
                    fromdate.text = formateddate.toString();
                    apidate1 = setdate1;
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
                      DateFormat("dd-MMM-yyyy").format(pickeddate);
                  String setdate2 = DateFormat("yyyy-MM-dd").format(pickeddate);
                  setState(() {
                    todate.text = formatdate.toString();
                    apidate2 = setdate2;
                  });
                }
              },
            ),
          ),
          SizedBox(
            height: mediaquery.height * 0.02,
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
                        var dt = snapshot.data[index]['orddate'];
                        DateTime dateTime = DateTime.parse(dt);
                        String formattedString =
                            DateFormat('dd-MM-yyyy').format(dateTime);

                        return InkWell(
                          onTap: () {
                            
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetails(
                                    
                                      custname: item['cust_name'],
                                      custnumber: item['cust_number'],
                                      totalamount: item['totalamount'],
                                      ordnumber: item['ordnumber']),
                                ));
                          },
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: mediaquery.width * 0.02,
                                right: mediaquery.width * 0.02,
                              ),
                              child: SizedBox(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        thickness: mediaquery.height * 0.00125,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                          height: mediaquery.height * 0.003),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: '#: ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${item['ordnumber']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: 'Date: ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: formattedString,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: mediaquery.height * 0.03),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text('Customer:'),
                                          Text('Amount:')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['cust_name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee,
                                                size: mediaquery.height * 0.02,
                                              ),
                                              Text(
                                                item['totalamount'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ]),
                              )),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text("Not a valid date ");
                }
                return const LinearProgressIndicator();
              },
            ),
        ],
      ),
    );
  }
}