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

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firmId = await prefs.getString('firm_id');
    return firmId;
  }

  @override
  void initState() {
    super.initState();
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
            child: Column(children: [
      SizedBox(
        height: mediaquery.size.height * 0.01,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: mediaquery.size.width * 0.1),
        child: TextField(
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
      SizedBox(height: mediaquery.size.height * 0.05),
      FutureBuilder<ItemModel>(
          future: fetchdata(fid: firmId.toString()),
          builder: (BuildContext context, AsyncSnapshot<ItemModel> snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data?.data;
              var filteredData = data!
                  .where((item) => item.headName
                      .toLowerCase()
                      .contains(searchQuery?.toLowerCase() ?? ''))
                  .toList();
                  
              return Expanded(
                child: ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Datum datum = filteredData[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                     ListTile(
                      title: Text(datum.headName),
                      subtitle: Text(datum.currentBalance),
                      selectedTileColor: Color(0xff000080),
                     )
                      ]
                    );
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
                  child: CircularProgressIndicator(
                color: Color(0xff000080),
              ));
            }
          })
    ])));
  }
}
