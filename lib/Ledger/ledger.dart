import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/Ledger/ledgershow.dart';
import 'package:spacc_office/Payment/getheads.dart';

import '../models/headsmodel.dart';

class Ledgerreport extends StatefulWidget {
  const Ledgerreport({super.key});

  @override
  State<Ledgerreport> createState() => _LedgerreportState();
}

class _LedgerreportState extends State<Ledgerreport> {
  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fid = prefs.getString('firm_id');
    return fid;
  }

  late String balance;

  final TextEditingController from2controller = TextEditingController();
  late String fromcode;
  final TextEditingController fromcontroller = TextEditingController();
  String? searchQuery;
  final FocusNode _focusNode = FocusNode();
final _formKey = GlobalKey<FormState>();
  String? apidate1;
  String? apidate2;
  TextEditingController fromdate = TextEditingController(),
      todate = TextEditingController();

  String? fid;
  String formattedfor = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedshow = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  @override
  void initState() {
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    apidate1 = formattedfor;
    apidate2 = formattedfor;
    fromdate.text = formattedshow;
    todate.text = formattedshow;
    balance = '------';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: mediaquery.height * 0.04,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
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
                padding: EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
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
                      String setdate2 =
                          DateFormat("yyyy-MM-dd").format(pickeddate);
                      setState(() {
                        todate.text = formatdate.toString();
                        apidate2 = setdate2;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: mediaquery.height * 0.04),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'A/C Selection',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                  readOnly: true,
                  controller: fromcontroller,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Field  cannot be empty';
                    }
                    return null;
                  },
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Column(children: [
                              SizedBox(
                                height: mediaquery.height * 0.06,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: mediaquery.width * 0.1),
                                child: TextField(
                                  autofocus: true,
                                  controller: from2controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color(0xff000080),
                                          width: mediaquery.width * 0.01,
                                        ),
                                        borderRadius: BorderRadius.circular(20)),
                                    hintText: 'Search...',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder<ItemModel>(
                                  future: fetchdata(fid: fid.toString()),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<ItemModel> snapshot) {
                                    if (snapshot.hasData) {
                                      final data = snapshot.data?.data;
                                      var filteredData = data!
                                          .where((item) => item.headName
                                              .toLowerCase()
                                              .contains(
                                                  searchQuery?.toLowerCase() ??
                                                      ''))
                                          .toList();
      
                                      return SizedBox(
                                        width: mediaquery.width * 0.8,
                                        child: ListView.builder(
                                          itemCount: filteredData.length,
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            final Datum datum =
                                                filteredData[index];
                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      from2controller.text =
                                                          datum.headName;
                                                      fromcontroller.text =
                                                          datum.headName;
                                                      fromcode = datum.headCode;
      
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        _focusNode.unfocus();
                                                        balance =
                                                            datum.currentBalance;
                                                      });
                                                    },
                                                    child: Column(
                                                      children: [
                                                        const Divider(
                                                          thickness: 1,
                                                          color: Colors.black,
                                                        ),
                                                        ListTile(
                                                          title: Text(
                                                              datum.headName),
                                                          selectedTileColor:
                                                              const Color(
                                                                  0xff000080),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ]);
                                          },
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: SizedBox(
                                          height: mediaquery.height * 0.6,
                                          width: mediaquery.width * 0.9,
                                          child:
                                              Lottie.asset('assets/error.json'),
                                        ),
                                      );
                                    } else {
                                      return Center(
                                        child: SizedBox(
                                          height: mediaquery.height * 0.6,
                                          width: mediaquery.width * 0.9,
                                          child: Lottie.asset(
                                              'assets/99297-loading-files.json'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ]);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: mediaquery.height * 0.04),
              CupertinoButton.filled(
                child: const Text('Show Ledger'),
                onPressed: () {
                 if (_formKey.currentState!.validate()) {

                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LedgerReportShow(
                          customercode: fromcode,
                          customername: fromcontroller.text,
                          fid: fid!,
                          date1: apidate1!,
                          date2: apidate2!),
                    ));
                   
                 }
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
