// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/License/urls.dart';

import '../models/itemmodel.dart';

class OrderEntry extends StatefulWidget {
  final String customername;
  final String customercode;
  const OrderEntry(
      {super.key, required this.customercode, required this.customername});

  @override
  State<OrderEntry> createState() => _OrderEntryState();
}

TextEditingController itemcontroller = TextEditingController();
TextEditingController itemcontroller2 = TextEditingController();
TextEditingController ratecontroller = TextEditingController();
TextEditingController qtycontroller = TextEditingController();
String? firmId;
late double qtyint;
late double rateint;
late double amount;
String? searchQuery;
final FocusNode _focusNode = FocusNode();
late String itemcode;

class _OrderEntryState extends State<OrderEntry> {
  @override
  void initState() {
    super.initState();
    amount = 1;
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

  List<Map<String, String>> dataList = [];
  double getSumOfAmounts() {
    return dataList.fold(0, (total, item) => total + double.parse(item['amount']!));
  }
  Map<String, dynamic> data = {};

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff000080),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return box();
              });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.add),
            SizedBox(height: 4.0),
            Text("item"),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.customername,
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
            Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final item = dataList[index];
                 double sumed = dataList.fold(0, (total, item) => total + double.parse(item['amount']!));

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
                              item['itemname']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            SizedBox(
                              width: mediaquery.width * 0.1,
                            ),
                            Text("(${item["qty"]}X${item["rate"]})"),
                            SizedBox(
                              width: mediaquery.width * 0.2,
                            ),
                            Text(
                              item["amount"]!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: mediaquery.height * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Text(
                    
                    "Total Amount:${getSumOfAmounts().toString()}",style: TextStyle(
                      fontSize: mediaquery.width*0.06
                    ),),
            
                ],
                
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget box() {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01),
              child: TextFormField(
                controller: itemcontroller,
                decoration: InputDecoration(
                  labelText: 'Item',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                readOnly: true,
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          var mediaquery = MediaQuery.of(context);
                          return Column(children: [
                            SizedBox(
                              height: mediaquery.size.height * 0.06,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mediaquery.size.width * 0.1),
                              child: TextField(
                                autofocus: true,
                                controller: itemcontroller2,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color(0xff000080),
                                        width: mediaquery.size.width * 0.01,
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
                              child: FutureBuilder<ItemList>(
                                future: fetchitem(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<ItemList> snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data?.data;
                                    var filteredData = data!
                                        .where((item) => item.itemName
                                            .toLowerCase()
                                            .contains(
                                                searchQuery?.toLowerCase() ??
                                                    ''))
                                        .toList();

                                    return SizedBox(
                                      width: mediaquery.size.width * 0.8,
                                      child: ListView.builder(
                                        itemCount: filteredData.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final ItemListData datum =
                                              filteredData[index];
                                          return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    itemcontroller2.text =
                                                        datum.itemName;
                                                    itemcontroller.text =
                                                        datum.itemName;
                                                    itemcode = datum.itemCode;
                                                    ratecontroller.text =
                                                        datum.salesrate;
                                                    qtycontroller.text =
                                                        1.toString();

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
                                                            datum.itemName),
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
                                        height: mediaquery.size.height * 0.6,
                                        width: mediaquery.size.width * 0.9,
                                        child:
                                            Lottie.asset('assets/error.json'),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: SizedBox(
                                        height: mediaquery.size.height * 0.6,
                                        width: mediaquery.size.width * 0.9,
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
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01),
              child: TextFormField(
                controller: ratecontroller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Rate',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01),
              child: TextFormField(
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                controller: qtycontroller,
                decoration: InputDecoration(
                  labelText: 'Qty',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onTap: () {},
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            CupertinoButton.filled(
              child: const Text('Add to cart'),
              onPressed: () {
                setState(() {
                  qtyint = double.parse(qtycontroller.text);
                  rateint = double.parse(ratecontroller.text);
                  amount = qtyint * rateint;
                });
                dataList.add({
                  "itemname": itemcontroller.text,
                  "qty": qtycontroller.text,
                  "rate": ratecontroller.text,
                  "itemcode": itemcode,
                  "amount": amount.toString(),
                });
                print(dataList);
                setState(() {
                  itemcode = '';
                  ratecontroller.clear();
                  qtycontroller.clear();
                  itemcontroller.clear();
                  itemcontroller2.clear();
                  searchQuery = '';
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<ItemList> fetchitem() async {
    final data = {'action': 'LIST', 'fid': firmId};

    final response = await http.post(Uri.parse(itemsurl), body: data);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      final itemmodel = ItemList.fromJson(responseJson);
      return itemmodel;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
