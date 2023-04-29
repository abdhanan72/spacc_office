// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/License/urls.dart';

import '../models/itemmodel.dart';

class OrderEntry extends StatefulWidget {
  final String customername;
  final String customercode;
  final String orderdate;
  const OrderEntry(
      {super.key,
      required this.customercode,
      required this.customername,
      required this.orderdate});

  @override
  State<OrderEntry> createState() => _OrderEntryState();
}

TextEditingController itemcontroller = TextEditingController();
TextEditingController itemcontroller2 = TextEditingController();
TextEditingController ratecontroller = TextEditingController();
TextEditingController qtycontroller = TextEditingController();
String? firmId;
List<Map<String, String>> apimap = [];
late double qtyint;
late double rateint;
late double amount;
String? searchQuery;
final FocusNode _focusNode = FocusNode();
late String itemcode;
String? custcode;
String? orderdate;

class _OrderEntryState extends State<OrderEntry> {
  @override
  void initState() {
    getDefaultPrinterAddress();
    super.initState();
    orderdate = widget.orderdate;
    custcode = widget.customercode;
    amount = 1;
    getFirmId().then((value) {
      setState(() {
        firmId = value!;
      });
    });
  }

  Future<String> getDefaultPrinterAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? defaultPrinterAddress = prefs.getString('defaultPrinter');
    return defaultPrinterAddress ?? 'No default printer selected';
  }

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firmId = prefs.getString('firm_id');
    return firmId;
  }

  List<Map<String, String>> dataList = [];
  List<Map<String, String>> itemData = [];
  double getSumOfAmounts() {
    return dataList.fold(
        0, (total, item) => total + double.parse(item['amount']!));
  }

  List<Map<String, String>> data = [];

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: IconButton(
          onPressed: () {
            printData();
            // dataList.clear();
          },
          icon: const Icon(Icons.print)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: mediaquery.height * .02,
            ),
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
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text('REMOVE',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                    fontWeight: FontWeight.bold)),
                            content: Column(
                              children: [
                                Lottie.asset('assets/100053-delete-bin.json',
                                    height: MediaQuery.of(context).size.height *
                                        0.2),
                                const Text(
                                  'Are you sure you want to remove this item?',
                                )
                              ],
                            ),
                            actions: [
                              MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    dataList.removeAt(index);
                                    Navigator.pop(context);
                                  });
                                  print(dataList);
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
                    },
                    child: Column(
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
                                item["amount"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
                      child: const Text('ADD ITEMS'),
                      onPressed: () {
                        print(dataList);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return box();
                            });
                      },
                    ),
                    SizedBox(
                      height: mediaquery.height * 0.01,
                    ),
                    CupertinoButton.filled(
                      child: const Text('PLACE ORDER'),
                      onPressed: () {
                        if (dataList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No items found')));
                        } else {
                          for (var item in dataList) {
                            Map<String, String> apiData = {
                              'qty': item['qty'].toString(),
                              'rate': item['rate'].toString(),
                              'item_code': item['item_code']!,
                            };
                            apimap.add(apiData);
                          }
                          print(apimap);
                          showdialog();
                        }
                      },
                    )
                  ],
                ),
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
                  "item_code": itemcode,
                  "amount": amount.toString(),
                });
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

  Future<void> sendPostRequest() async {
    final response = await http.post(
      Uri.parse(orderurl),
      body: {
        'orddate': orderdate,
        'action': 'CREATE',
        'memo': '',
        'fid': firmId,
        'amount': getSumOfAmounts().toString(),
        'custcode': custcode,
        'itemdata': jsonEncode(apimap),
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

  Future<void> printData() async {
    String printerAddress = await getDefaultPrinterAddress();
    if (printerAddress == 'No default printer selected') {
      return;
    }

    BluetoothConnection connection;
    try {
      connection = await BluetoothConnection.toAddress(printerAddress);
      print("Connected to printer.");
    } catch (ex) {
      print("Error connecting to printer: $ex");
      return;
    }

    // Send "Hello World" to the printer
    String receipt = "------------------------------------------------\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(33) +
        String.fromCharCode(24);
    receipt += "                 Hindustan Foods\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(33) +
        String.fromCharCode(0);
    receipt += "                  123 Main St.\n";
    receipt += "                 City, State ZIP\n";
    receipt += "               Tel: (555) 555-5555\n";
    receipt += "         Date: ${DateTime.now().toString()}\n";
    receipt += "------------------------------------------------\n";
    receipt += "ITEM                QTY    RATE           AMOUNT\n";
    receipt += "------------------------------------------------\n";

    double total = 0.0;
    for (var item in dataList) {
      String itemName = item['itemname']!;
      int qty = int.tryParse(item['qty']!) ?? 0;
      double rate = double.tryParse(item['rate']!) ?? 0.0;
      double amount = qty * rate;
      total += amount;
      String amountString = amount.toStringAsFixed(2);
      int itemPadding = 18;
      int remainingWidth = 32 - itemPadding;
      String qtyString = qty.toString().padLeft(3);
      String rateString = rate.toStringAsFixed(2).padLeft(6);
      String line =
          itemName.substring(0, remainingWidth).padRight(itemPadding) +
              qtyString +
              ' ' * 4 +
              rateString +
              ' ' * 9 +
              amountString;
      receipt += '$line\n';
      if (itemName.length > remainingWidth) {
        for (int i = remainingWidth; i < itemName.length; i += remainingWidth) {
          int endIndex = i + remainingWidth;
          if (endIndex > itemName.length) {
            endIndex = itemName.length;
          }
          line = '${itemName.substring(i, endIndex).padRight(itemPadding)}${' ' * (3 + 6 + 3)}${' ' * (amountString.length - 1)}\n';
          receipt += line;
        }
      }
      receipt += String.fromCharCode(27) +
          String.fromCharCode(74) +
          String.fromCharCode(50);
    }

    receipt += "------------------------------------------------\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(33) +
        String.fromCharCode(24);
    receipt +=
        "                 Total: ${total.toStringAsFixed(2).padLeft(9)}\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(33) +
        String.fromCharCode(0);
    receipt += "------------------------------------------------\n";
    receipt += "        Thank you for your business!\n";
    // receipt += "------------------------------------------------\n";
    receipt += String.fromCharCode(27) +
        String.fromCharCode(74) +
        String.fromCharCode(110);

    // Send the receipt to the printer
    Uint8List bytes = Uint8List.fromList(utf8.encode(receipt));
    connection.output.add(bytes);
    await connection.output.allSent;

    // Close the connection
    await connection.close();
    print("Connection closed.");
  }

  void showdialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Confirm?',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              Lottie.asset('assets/105198-attention.json',
                  height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                'Are you sure you want to place the order?',
              )
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                sendPostRequest();
                setState(() {
                  dataList.clear();
                  itemData.clear();
                  apimap.clear();
                });
                Navigator.pop(context);
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
