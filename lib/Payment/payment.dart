import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/Payment/getheads.dart';
import 'package:spacc_office/models/headsmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:spacc_office/License/urls.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String? query;
  final TextEditingController amount = TextEditingController();
  late String balance;
  final TextEditingController date = TextEditingController();
  String? firmId;
 
  late String formattedDate;
  final TextEditingController from2controller = TextEditingController();
  final TextEditingController from3controller = TextEditingController();
  late String fromcode;
  final TextEditingController fromcontroller = TextEditingController();
  final TextEditingController memo = TextEditingController();
  String? searchQuery;
  late String tocode;
  final TextEditingController tocontroller = TextEditingController();
  final TextEditingController tocontroller2 = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String? apidate1;
  String formattedfor = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedshow = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    
    balance = '---';
    tocode = '';
    fromcode = '';
    apidate1 = formattedfor;
    date.text = formattedshow;
    getFirmId().then((value) {
      setState(() {
        firmId = value!;
      });
    });
    getusername().then((value) {
      setState(() {
        username=value!;
      });
    });
  }

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firmId = prefs.getString('firm_id');
    return firmId;
  }
  Future<String?> getusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('user_name');
    return username;
  }
 String? username;


  void showdialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Save?',
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
                
                _postPayment();
                fromcontroller.clear();
                from2controller.clear();
                tocontroller2.clear();
                amount.clear();
                memo.clear();
                setState(() {
                  balance = '';
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

   void _postPayment() async {
    

    final data = {
      'action': 'CREATE',
      'fid': firmId,
      'accode': fromcode,
      'paymethod': tocode,
      'paydate': apidate1,
      'memo': memo.text,
      'amount': amount.text,
      'username':username
    };

    final response = await http.post(Uri.parse(paymenturl), body: data);
    final result = jsonDecode(response.body);
    

    if (result["response_code"] == 27) {
      
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment successfully posted')));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result["response_desc"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 20,
          title: const Text('Payment Entry'),
        ),
        body: Form(
          key: _formKey,
          child: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mediaquery.size.height * 0.05,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: mediaquery.size.width * 0.1),
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
                          apidate1 = setdate1;
                        });
                      } else {}
                    },
                  ),
                ),
                SizedBox(
                  height: mediaquery.size.height * 0.03,
                ),
                SizedBox(
                  height: mediaquery.size.height * 0.01,
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaquery.size.width * 0.1),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Paid to',
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
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Column(children: [
                                  SizedBox(
                                    height: mediaquery.size.height * 0.06,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            mediaquery.size.width * 0.1),
                                    child: TextField(
                                      autofocus: true,
                                      controller: from2controller,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: const Color(0xff000080),
                                              width:
                                                  mediaquery.size.width * 0.01,
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
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final Datum datum =
                                                    filteredData[index];
                                                return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          from2controller.text =
                                                              datum.headName;
                                                          fromcontroller.text =
                                                              datum.headName;
                                                          fromcode =
                                                              datum.headCode;

                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            _focusNode
                                                                .unfocus();
                                                            balance = datum
                                                                .currentBalance;
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            const Divider(
                                                              thickness: 1,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            ListTile(
                                                              title: Text(datum
                                                                  .headName),
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
                                              width:
                                                  mediaquery.size.width * 0.9,
                                              child: Lottie.asset(
                                                  'assets/error.json'),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: SizedBox(
                                              height:
                                                  mediaquery.size.height * 0.6,
                                              width:
                                                  mediaquery.size.width * 0.9,
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
                  "Current Balance:Rs$balance",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: mediaquery.size.height * 0.04,
                ),
                SizedBox(
                  height: mediaquery.size.height * 0.01,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: mediaquery.size.width * 0.1),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field  cannot be empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Paid From',
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
                                        query = value;
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
                                                    query?.toLowerCase() ?? ''))
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
                                                mediaquery.size.height * 0.9,
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
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field  cannot be empty';
                      }
                      return null;
                    },
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Amount',
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
                  child: TextFormField(
                    controller: memo,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    decoration: InputDecoration(
                        labelText: 'Memo',
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
                          if (_formKey.currentState!.validate()) {
                            showdialog();
                          }
                        },
                        child: const Text('Save')))
              ],
            ),
          )),
        ));
  }
}
