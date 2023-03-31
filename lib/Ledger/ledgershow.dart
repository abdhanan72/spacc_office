import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:spacc_office/License/urls.dart';

class LedgerReportShow extends StatefulWidget {
  final String customercode;
  final String customername;
  final String fid;
  final String date1;
  final String date2;
  const LedgerReportShow(
      {super.key,
      required this.customercode,
      required this.customername,
      required this.fid,
      required this.date1,
      required this.date2});

  @override
  State<LedgerReportShow> createState() => _LedgerReportShowState();
}

class _LedgerReportShowState extends State<LedgerReportShow> {
  List<dynamic> _data = [];

  Future<List<dynamic>> fetchledger() async {
    var response = await http.post(Uri.parse(ledgerurl), body: {
      'date1': widget.date1,
      'date2': widget.date2,
      'fid': widget.fid,
      'head_code': widget.customercode
    });
    var data = jsonDecode(response.body);
    return data['data'];
  }

  @override
  void initState() {
    super.initState();
    fetchledger().then((data) {
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: mediaquery.height * 0.02,
            ),
            Text(
              '${widget.customername}\'S LEDGER',
              style: TextStyle(
                  color: Colors.teal,
                  fontSize: mediaquery.width * 0.07,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: mediaquery.height * 0.02,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final ledg = _data[index];
                  final isdebit = double.parse(ledg['debit']) != 0.000;
                  final iscredit = double.parse(ledg['credit']) != 0.000;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Divider(thickness: 1, color: Colors.black),
                      SizedBox(height: mediaquery.height * 0.01),
                      Row(
                        children: [
                          SizedBox(
                            width: mediaquery.width * 0.01,
                          ),
                          Expanded(
                            child: Text(ledg['description'],style:const TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          SizedBox(
                            width: mediaquery.width * 0.02,
                          ),
                          Text(
                            isdebit ? "${ledg['debit']} Dr" : "",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: mediaquery.width * 0.02,
                          ),
                          Text(
                            iscredit ? "${ledg['credit']} Cr" : "",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: mediaquery.width * 0.02,
                          ),
                          Expanded(
                            child: Text(
                              ledg['balance'],
                              textAlign: TextAlign.right,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: mediaquery.width * 0.01,
                          ),
                        ],
                      ),
                      SizedBox(height: mediaquery.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: mediaquery.width * 0.01),
                          Expanded(child: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(ledg['date'])))),

                         
                        ],
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                         SizedBox(width: mediaquery.width * 0.01),
                          Expanded(child: Text(ledg['ttype'])),
                      ],)
                    ],
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
