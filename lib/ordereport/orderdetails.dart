import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:spacc_office/License/urls.dart';
import 'package:spacc_office/ordereport/orderreport.dart';

import '../models/itemmodel.dart';

class OrderDetails extends StatefulWidget {
  final int ordnumber;
  final String custnumber;
  final String custname;
  final String totalamount;
  final String fid;
  final String orddate;
  const OrderDetails(
      {super.key,
      required this.ordnumber,
      required this.custnumber,
      required this.custname,
      required this.totalamount,
      required this.fid,
      required this.orddate});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? custnumber;
  String? custname;
  String? totalamount;
  final FocusNode _focusNode = FocusNode();
  Map<String, dynamic> orderData = {};
  List<dynamic> itemdata = [];
  List<Map<String, String>> apimap = [];

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
          children: [
            SizedBox(
              height: mediaquery.height * .02,
            ),
            Text(
              widget.custname,
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
                            GestureDetector(
                              onTap: () {
                                _showDialog(item);
                              },
                              child: Padding(
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
                      child: const Text('Add to cart'),
                      onPressed: () {
                       
                       if (apimap.isNotEmpty) {
                          editorder();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OrderReport(),));
                      Navigator.pop(context);
                       } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('No changes made')));
                         
                       }
                      },
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

  void _showDialog(Map<String, dynamic> item) {
    final qtyController = TextEditingController(text: item['qty']);
    TextEditingController itemcontroller2 = TextEditingController();
    final itemCodeController = TextEditingController(text: item['item_code']);
    final itemNameController = TextEditingController(text: item['item_name']);
    final rateController = TextEditingController(text: item['rate']);
    String? searchQuery;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
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
                                                    itemNameController.text =
                                                        datum.itemName;
                                                    itemCodeController.text =
                                                        datum.itemCode;
                                                    rateController.text =
                                                        datum.salesrate;
                                                    qtyController.text =
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
                controller: itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                ),
              ),
              TextField(
                controller: itemCodeController,
                decoration: const InputDecoration(
                  labelText: 'Item Code',
                ),
              ),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
              ),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item['qty'] = qtyController.text;
                  item['item_code'] = itemCodeController.text;
                  item['item_name'] = itemNameController.text;
                  item['rate'] = rateController.text;
                  item['amount'] =
                      (double.parse(item['qty']) * double.parse(item['rate']))
                          .toString();
                for (var item in itemdata) {
    Map<String, String> apiData = {
      'qty': item['qty'].toString(),
      'rate': item['rate'].toString(),
      'item_code': item['item_code']!,
    };
    apimap.add(apiData);
  }
                  
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editorder() async {
    final response = await http.post(
      Uri.parse(orderurl),
      body: {
        'orddate': widget.orddate,
        'action': 'EDIT',
        'memo': '',
        'fid': widget.fid,
        'amount': getSumOfAmounts().toString(),
        'custcode': widget.custnumber,
        'itemdata': jsonEncode(apimap),
        'ordnumber': widget.ordnumber.toString()
      },
    );
    final result = jsonDecode(response.body);

    if (result["response_code"] == 27) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order Placed')));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["response_desc"])));
    }
  }

  Future<ItemList> fetchitem() async {
    final data = {'action': 'LIST', 'fid': widget.fid};

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
