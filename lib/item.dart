import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/models/itemodel.dart';
import 'package:lottie/lottie.dart';

import 'itemapi.dart';

class Item extends StatefulWidget {
  const Item({super.key});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  String? firmId;
  String? searchQuery;
  final TextEditingController fromcontroller = TextEditingController();
  final TextEditingController from2controller = TextEditingController();
  final TextEditingController from3controller = TextEditingController();
  final TextEditingController tocontroller = TextEditingController();
  final TextEditingController tocontroller2 = TextEditingController();

  bool _showList = false;
  final FocusNode _focusNode = FocusNode();
  late String balance;
  late String tocode;
  late String fromcode;
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        SizedBox(
          height: mediaquery.size.height * 0.04,
        ),
        const Text('Received From'),
        SizedBox(
          height: mediaquery.size.height * 0.01,
        ),
        Center(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: mediaquery.size.width * 0.1),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
              readOnly: true,
              controller: fromcontroller,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(children: [
                      SizedBox(
                        height: mediaquery.size.height * 0.04,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: mediaquery.size.width * 0.1),
                        child: TextField(
                          focusNode: _focusNode,
                          onTap: () {
                            setState(() {
                              // _showList = true;
                            });
                          },
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
                      // if (_showList)
                      FutureBuilder<ItemModel>(
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

                            return Expanded(
                              child: SizedBox(
                                width: mediaquery.size.width * 0.8,
                                child: ListView.builder(
                                  itemCount: filteredData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Datum datum = filteredData[index];
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
                                              print(fromcode);

                                              Navigator.pop(context);
                                              setState(() {
                                                _focusNode.unfocus();
                                                _showList = false;
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
                                                  selectedTileColor:
                                                      const Color(0xff000080),
                                                ),
                                              ],
                                            ),
                                          )
                                        ]);
                                  },
                                ),
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
                              child: CircularProgressIndicator(
                                  color: Color(0xff000080)),
                            );
                          }
                        },
                      )
                    ]);
                  },
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: mediaquery.size.height * 0.01,
        ),
        Text("Current Balance:${balance}Rs",),
        SizedBox(
          height: mediaquery.size.height * 0.04,
        ),
        const Text('Paying to'),
        SizedBox(
          height: mediaquery.size.height * 0.01,
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: mediaquery.size.width * 0.1),
          child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20))),
            readOnly: true,
            controller: tocontroller,
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(children: [
                    SizedBox(
                      height: mediaquery.size.height * 0.04,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaquery.size.width * 0.1),
                      child: TextField(
                        focusNode: _focusNode,
                        onTap: () {
                          setState(() {
                            // _showList = true;
                          });
                        },
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
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    // if (_showList)
                    FutureBuilder<ItemModel>(
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

                          return Expanded(
                            child: SizedBox(
                              width: mediaquery.size.width * 0.8,
                              child: ListView.builder(
                                itemCount: filteredData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Datum datum = filteredData[index];
                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              _showList = false;
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
                                                selectedTileColor:
                                                    const Color(0xff000080),
                                              ),
                                            ],
                                          ),
                                        )
                                      ]);
                                },
                              ),
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
                            child: CircularProgressIndicator(
                                color: Color(0xff000080)),
                          );
                        }
                      },
                    )
                  ]);
                },
              );
            },
          ),
        ),
      ],
    )));
  }
}
