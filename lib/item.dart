
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 20,
          title: const Text('Receipt Entry'),
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
                padding: EdgeInsets.only(right: mediaquery.size.width * 0.4),
                child: const Text(
                  'Received From',
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
      builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          SizedBox(
            height: mediaquery.size.height * 0.04,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mediaquery.size.width * 0.1),
            child: TextField(
              controller: from2controller,
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
            child: FutureBuilder<ItemModel>(
              future: fetchdata(fid: firmId.toString()),
              builder: (BuildContext context,
                  AsyncSnapshot<ItemModel> snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data?.data;
                  var filteredData = data!
                      .where((item) => item.headName
                          .toLowerCase()
                          .contains(searchQuery?.toLowerCase() ?? ''))
                      .toList();

                  return SizedBox(
                    width: mediaquery.size.width * 0.8,
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Datum datum = filteredData[index];
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  from2controller.text = datum.headName;
                                  fromcontroller.text = datum.headName;
                                  fromcode = datum.headCode;
                                  print(fromcode);
                                  Navigator.pop(context);
                                  setState(() {
                                    _focusNode.unfocus();
                                    balance = datum.currentBalance;
                                  });
                                },
                                child: Column(
                                  children: [
                                    const Divider(
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                    ListTile(
                                      title: Text(datum.headName),
                                      selectedTileColor: const Color(0xff000080),
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
                      child: Lottie.network(
                          'https://assets9.lottiefiles.com/packages/lf20_1PD1tpvlop.json'),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xff000080)),
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
                padding: EdgeInsets.only(right: mediaquery.size.width * 0.5),
                child: const Text(
                  'Paying to',
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
      builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          SizedBox(
            height: mediaquery.size.height * 0.04,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mediaquery.size.width * 0.1),
            child: TextField(
              controller: tocontroller2,
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
                          .contains(Query?.toLowerCase() ?? ''))
                      .toList();

                  return SizedBox(
                    width: mediaquery.size.width * 0.8,
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Datum datum = filteredData[index];
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  tocontroller.text = datum.headName;
                                  tocontroller2.text = datum.headName;
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
                                      title: Text(datum.headName),
                                      selectedTileColor: const Color(0xff000080),
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
                      child: Lottie.network(
                          'https://assets9.lottiefiles.com/packages/lf20_1PD1tpvlop.json'),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xff000080)),
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
              SizedBox(height: mediaquery.size.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaquery.size.width * 0.19),
                child: ElevatedButton(onPressed: () {}, child: const Text('Save')),
              )
            ],
          ),
        )));
  }
}
