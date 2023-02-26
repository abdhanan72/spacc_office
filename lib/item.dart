import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/home.dart';
import 'package:spacc_office/models/itemodel.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'itemapi.dart';

class Item extends StatefulWidget {
  const Item({super.key});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  String? firmId;
  String? searchQuery;
  String? Query;

  final TextEditingController fromcontroller = TextEditingController();
  final TextEditingController from2controller = TextEditingController();
  final TextEditingController from3controller = TextEditingController();
  final TextEditingController tocontroller = TextEditingController();
  final TextEditingController tocontroller2 = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController memo = TextEditingController();
  final TextEditingController amount = TextEditingController();

  bool _showList = false;
  final FocusNode _focusNode = FocusNode();
  late String balance;
  late String tocode;
  late String fromcode;
  late String formattedDate;
  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firmId = await prefs.getString('firm_id');
    return firmId;
  }

  @override
  void initState() {
    super.initState();
    balance = '---';
    tocode = '';
    fromcode = '';
    getFirmId().then((value) {
      setState(() {
        firmId = value!;
        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        date.text = formattedDate;
      });
    });
  }

  void _postPayment() async {
    const url = 'http://cloud.spaccsoftware.com/hanan_api/save_payment.php';

    final data = {
      'fid': firmId,
      'accode': fromcode,
      'paymethod': tocode,
      'paydate': date.text,
      'memo': memo.text,
      'amount': amount.text
    };

    final response = await http.post(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment successfully posted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to post payment. Error ${response.statusCode}: ${response.reasonPhrase}')));
    }
  }

  void showdialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Logout',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              Lottie.asset('assets/105198-attention.json',
                  height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                'Are you sure you want to Save the payment?',
              )
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Item(),
                    ));
                _postPayment();
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

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 20,
          title: const Text('Payment Entry'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
            },
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: mediaquery.size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaquery.size.width * 0.1),
                child: TextField(
                  controller: date,
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
                          DateFormat("yyyy-MM-dd").format(pickdate);
                      setState(() {
                        date.text = formateddate.toString();
                      });
                    } else {}
                  },
                ),
              ),
              SizedBox(
                height: mediaquery.size.height * 0.03,
              ),
              Padding(
                padding: EdgeInsets.only(right: mediaquery.size.width * 0.6),
                child: const Text(
                  'Paid to',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: mediaquery.size.height * 0.01,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: mediaquery.size.width * 0.1),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    readOnly: true,
                    controller: fromcontroller,
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
                                  height: mediaquery.size.height * 0.06,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: mediaquery.size.width * 0.1),
                                  child: TextField(
                                    autofocus: true,
                                    controller: from2controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: const Color(0xff000080),
                                            width: mediaquery.size.width * 0.01,
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
                                          width: mediaquery.size.width * 0.8,
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
                                                        from2controller.text =
                                                            datum.headName;
                                                        fromcontroller.text =
                                                            datum.headName;
                                                        fromcode =
                                                            datum.headCode;
                                                        print(fromcode);
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          _focusNode.unfocus();
                                                          balance = datum
                                                              .currentBalance;
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
                                            height:
                                                mediaquery.size.height * 0.6,
                                            width: mediaquery.size.width * 0.9,
                                            child: Lottie.asset(
                                                'assets/error.json'),
                                          ),
                                        );
                                      } else {
                                        return Center(
                                          child: SizedBox(
                                            height:
                                                mediaquery.size.height * 0.6,
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
              ),
              SizedBox(
                height: mediaquery.size.height * 0.01,
              ),
              Text(
                "Current Balance:${balance}Rs",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: mediaquery.size.height * 0.04,
              ),
              Padding(
                padding: EdgeInsets.only(right: mediaquery.size.width * 0.4),
                child: const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: mediaquery.size.height * 0.01,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaquery.size.width * 0.1),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                  readOnly: true,
                  controller: tocontroller,
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
                                height: mediaquery.size.height * 0.05,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: mediaquery.size.width * 0.1),
                                child: TextField(
                                  autofocus: true,
                                  controller: tocontroller2,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color(0xff000080),
                                          width: mediaquery.size.width * 0.01,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    hintText: 'Search...',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      Query = value;
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
                                              .contains(
                                                  Query?.toLowerCase() ?? ''))
                                          .toList();

                                      return SizedBox(
                                        width: mediaquery.size.width * 0.8,
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
                                                      tocontroller.text =
                                                          datum.headName;
                                                      tocontroller2.text =
                                                          datum.headName;
                                                      tocode = datum.headCode;
                                                      print(tocode);
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
                                          height: mediaquery.size.height * 0.6,
                                          width: mediaquery.size.width * 0.9,
                                          child:
                                              Lottie.asset('assets/error.json'),
                                        ),
                                      );
                                    } else {
                                      return Center(
                                        child: SizedBox(
                                          height: mediaquery.size.height * 0.9,
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
                height: mediaquery.size.height * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaquery.size.width * 0.1),
                child: TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: 'Amount',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
              SizedBox(
                height: mediaquery.size.height * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaquery.size.width * 0.1),
                child: TextField(
                  controller: memo,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  decoration: InputDecoration(
                      hintText: 'Memo',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
              SizedBox(height: mediaquery.size.height * 0.04),
              SizedBox(
                  width: mediaquery.size.width * 0.4,
                  height: mediaquery.size.height * 0.05,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      onPressed: () {
                        print(firmId);
                        print(date.text);
                        print(fromcode);
                        print(tocode);
                        print(amount.text);
                        print(memo.text);

                        showdialog();
                      },
                      child: const Text('Save')))
            ],
          ),
        )));
  }
}
