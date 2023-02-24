import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/receipt.dart';

import 'item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<String?> getfname() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? fullname = await prefs.getString('fullname');
  return fullname;
}

late String fullname;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    getfname().then((value) {
      setState(() {
        fullname = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
        body: SafeArea(
            child: Padding(
              padding:  EdgeInsets.only(top: mediaquery.size.height*0.07),
              child: Column(
                children: [
                  Text("Hello",style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff000080)),),
                
                SizedBox(height: mediaquery.size.height*0.03,),
                  Text("$fullname",style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff000080)),),
                  
                  SizedBox(height:mediaquery.size.height*0.08,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      
                      GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Item(),
                                  )),
                              child: const Menuitem(
                                  imagePath: 'assets/receipt.png', text: 'Receipt Entry')),
                      GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Receipt(),
                                  )),
                              child: const Menuitem(
                                  imagePath: 'assets/cubes.png', text: 'item Find')),
                    ],
                  ),
                ],
              ),
            )));
  }
}

class Menuitem extends StatelessWidget {
  final String imagePath;
  final String text;

  const Menuitem({
    super.key,
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: mediaquery.size.height * 0.1,
            width: mediaquery.size.width * 0.22,
            child: Image.asset(imagePath)),
        SizedBox(
          height: mediaquery.size.height * 0.01,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: mediaquery.size.height * 0.020,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
