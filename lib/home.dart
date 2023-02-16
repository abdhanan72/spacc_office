import 'package:flutter/material.dart';
import 'package:spacc_office/receipt.dart';

import 'item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaquery= MediaQuery.of(context);
    return  Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.only(top: mediaquery.size.height*0.2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  [
              GestureDetector(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => const Item(),)),
                child: const Menuitem(imagePath: 'assets/cubes.png', text: 'Item Find')),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Receipt(),)),
                child: const Menuitem(imagePath: 'assets/receipt.png', text: 'Receipt Entry')),
            ],
          ),
        )
      )
    );
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
          style: TextStyle(fontSize: mediaquery.size.height * 0.020,
          fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
