import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/models/itemodel.dart';
import 'package:http/http.dart' as http;
import 'package:spacc_office/payreport/paydetail.dart';
import 'package:spacc_office/payreport/payreport.dart';

import '../Payment/getheads.dart';

class EditPayment extends StatefulWidget {
  final int paynum;
  final String paidto;
  final String paymentMethod;
  final String amount;
  final String memo;
  final String paydate;
  final String fromcode;
  final String tocode;
  const EditPayment(
      {super.key,
      required this.paynum,
      required this.paidto,
      required this.paymentMethod,
      required this.amount,
      required this.memo,
      required this.paydate, required this.fromcode, required this.tocode});

  @override
  State<EditPayment> createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  TextEditingController paidtocontroller = TextEditingController();
  TextEditingController paidtocontroller2 = TextEditingController();
  TextEditingController paymethodcontroller = TextEditingController();
  TextEditingController paymethodcontroller2 = TextEditingController();
  TextEditingController amountcontroller = TextEditingController();
  TextEditingController memocontroller = TextEditingController();
  TextEditingController datecontroller = TextEditingController();
  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fid = prefs.getString('firm_id');
    return fid;
  }

  String? fid;
  
  String? Query;
  String? searchQuery;
   String? tocode;
   String? fromcode;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    fromcode = widget.fromcode;
    tocode=widget.tocode;
    paidtocontroller.text = widget.paidto;
    paymethodcontroller.text = widget.paymentMethod;
    amountcontroller.text = widget.amount;
    memocontroller.text = widget.memo;
    datecontroller.text = widget.paydate;
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:IconButton(onPressed: () {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PaymentReport(),));
       }, icon:  Icon(Icons.arrow_back_ios_new)),
        title: const Text('EditPayment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: mediaquery.height * 0.05),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
                  child: TextFormField(
                      autofocus: false,
                      readOnly: true,
                      controller: datecontroller,
                      decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
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
                            datecontroller.text = formateddate.toString();
                          });
                        } else {}
                      }),
                ),
                SizedBox(
                  height: mediaquery.height * 0.04,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Paid to',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    readOnly: true,
                    controller: paidtocontroller,
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
                                    controller: paidtocontroller2,
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
                                                        paidtocontroller.text =
                                                            datum.headName;
                                                        paidtocontroller2.text =
                                                            datum.headName;
                                                        fromcode = datum.headCode;
      
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
                SizedBox(
                  height: mediaquery.height * 0.04,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: mediaquery.width * 0.1),
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    readOnly: true,
                    controller: paymethodcontroller,
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
                                  height: mediaquery.height * 0.05,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: mediaquery.width * 0.1),
                                  child: TextField(
                                    autofocus: true,
                                    controller: paymethodcontroller2,
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
                                        Query = value;
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
                                                    Query?.toLowerCase() ?? ''))
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
                                                        paymethodcontroller.text =
                                                            datum.headName;
                                                        paymethodcontroller2
                                                                .text =
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
                                            height: mediaquery.height * 0.6,
                                            width: mediaquery.width * 0.9,
                                            child:
                                                Lottie.asset('assets/error.json'),
                                          ),
                                        );
                                      } else {
                                        return Center(
                                          child: SizedBox(
                                            height: mediaquery.height * 0.9,
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
                    height: mediaquery.height * 0.04,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaquery.width * 0.1),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Field  cannot be empty';
                        }
                        return null;
                      },
                      controller: amountcontroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  ),
                  SizedBox(
                    height: mediaquery.height * 0.04,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaquery.width * 0.1),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Field  cannot be empty';
                        }
                        return null;
                      },
                      controller: memocontroller,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: 'Memo',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  ),
                  SizedBox(
                    height: mediaquery.height * 0.04,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: mediaquery.height*0.05,
                        width: mediaquery.width*0.3,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                ),
                          onPressed: () {
                          editpayment();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentReport()));
                          
                        }, child: const Text('Edit')),
                      ),
                      SizedBox(
                         height: mediaquery.height*0.05,
                        width: mediaquery.width*0.3,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                ),
                          onPressed: () {
                          showdialog();
                          print(widget.paynum.toString());
                          print(fid);
                        
                          
                        }, child: const Text('Delete')),
                      ),
                    ],
                  )
      
      
              ],
            ),
          ),
        ),
      ),
    );











    
  }


void editpayment() async {
    const url = 'http://cloud.spaccsoftware.com/hanan_api/payment/';

    final data = {
      'action': 'EDIT',
      'fid': fid,
      'accode': fromcode,
      'paymethod': tocode,
      'paydate': datecontroller.text,
      'memo': memocontroller.text,
      'amount': amountcontroller.text,
      'paynumber':widget.paynum.toString(),
    };

    final response = await http.post(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment Edit Succesfull')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to post payment. Error ${response.statusCode}: ${response.reasonPhrase}')));
    }
  }

  void deletePayment() async {

const url = 'http://cloud.spaccsoftware.com/hanan_api/payment/';


    var response = await http.post(Uri.parse(url), body: {
      'action': 'DELETE',
      'fid': fid,
      'paynumber': widget.paynum.toString()
    });
    var jsonResponse = jsonDecode(response.body);
    var responseDesc = jsonResponse['response_desc'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(responseDesc),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showdialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('DELETE',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              Lottie.asset('assets/100053-delete-bin.json',
                  height: MediaQuery.of(context).size.height * 0.2),
              const Text(
                'Are you sure you want to Delete this payment?',
              )
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                
                deletePayment();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentReport()));
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
