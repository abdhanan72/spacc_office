import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/Order/order.dart';
import 'package:spacc_office/models/headsmodel.dart';

import '../Payment/getheads.dart';

class CustomerSelect extends StatefulWidget {
  const CustomerSelect({super.key});

  @override
  State<CustomerSelect> createState() => _CustomerSelectState();
}

class _CustomerSelectState extends State<CustomerSelect> {
  final TextEditingController customer2controller = TextEditingController();
  final TextEditingController date = TextEditingController();
  late String customercode;
  String? searchQuery;
  final FocusNode _focusNode = FocusNode();
  String? firmId;
  String? balance;
  String formattedfor = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedshow = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  String? orderdate;
  final TextEditingController customercontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    date.text = formattedshow;
    orderdate = formattedfor;
    balance = '-------';
    customercode = '';
    getFirmId().then((value) {
      setState(() {
        firmId = value!;
      });
    });
  }

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firmId = prefs.getString('firm_id');
    return firmId;
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: mediaquery.height * 0.05),
            child: Column(
              children: [
                const Center(
                    child: Text(
                  'Select Customer',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                )),
                SizedBox(
                  height: mediaquery.height * 0.02,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Customer',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    readOnly: true,
                    controller: customercontroller,
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
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(children: [
                                SizedBox(
                                  height: mediaquery.height * 0.06,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: mediaquery.width * 0.1),
                                  child: TextField(
                                    autofocus: true,
                                    controller: customer2controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: const Color(0xff000080),
                                            width: mediaquery.width * 0.01,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
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
                                    future: fetchdata(fid: firmId.toString()),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<ItemModel> snapshot) {
                                      if (snapshot.hasData) {
                                        final data = snapshot.data?.data;
                                        var filteredData = data!
                                            .where((item) => item.headName
                                                .toLowerCase()
                                                .contains(searchQuery
                                                        ?.toLowerCase() ??
                                                    ''))
                                            .toList();

                                        return SizedBox(
                                          width: mediaquery.width * 0.8,
                                          child: ListView.builder(
                                            itemCount: filteredData.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final Datum datum =
                                                  filteredData[index];
                                              return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        customer2controller
                                                                .text =
                                                            datum.headName;
                                                        customercontroller
                                                                .text =
                                                            datum.headName;
                                                        customercode =
                                                            datum.headCode;
                                                        balance = datum
                                                            .currentBalance;

                                                        Navigator.pop(context);
                                                        setState(() {
                                                          _focusNode.unfocus();
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
                                            child: Lottie.asset(
                                                'assets/error.json'),
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
                SizedBox(
                  height: mediaquery.height * 0.02,
                ),
                Text(
                  "Current balance:${balance!}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: mediaquery.height * 0.02,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
                  child: TextFormField(
                    controller: date,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field 1 cannot be empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
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

                        String setdate1 =
                            DateFormat("yyyy-MM-dd").format(pickdate);
                        setState(() {
                          date.text = formateddate.toString();
                          orderdate = setdate1;
                        });
                      } else {}
                    },
                  ),
                ),
                SizedBox(
                  height: mediaquery.height * 0.02,
                ),
                CupertinoButton.filled(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderEntry(
                                orderdate: orderdate!,
                                customercode: customercode,
                                customername: customercontroller.text,
                              ),
                            ));
                      }
                    },
                    child: const Text('NEXT')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
