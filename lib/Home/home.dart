import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/Ledger/ledger.dart';
import 'package:spacc_office/Order/print.dart';
import 'package:spacc_office/Receipt/receipt.dart';
import 'package:spacc_office/ReceiptReport/receiptrepo.dart';
import 'package:spacc_office/ordereport/orderreport.dart';
import 'package:spacc_office/payreport/payreport.dart';
import '../Login/login.dart';
import '../Order/selectcusomer.dart';
import '../Payment/payment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

String? username;
String? fullname;

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

  Future<String?> getfname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    late String? fullname = prefs.getString('fullname');
    return fullname;
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);

    Future<void> clearData() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    void showdialog() {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Logout',
                style: TextStyle(
                    fontSize: mediaquery.size.height * 0.03,
                    fontWeight: FontWeight.bold)),
            content: Column(
              children: [
                Lottie.asset('assets/90919-logout.json',
                    height: mediaquery.size.height * 0.1),
                const Text(
                  'Are you sure you want to logout?',
                )
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  clearData();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Login()));
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

    return Scaffold(
      floatingActionButton: IconButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Print(),
              )),
          icon: const Icon(Icons.print)),
        body: SafeArea(
            child: Padding(
      padding: EdgeInsets.only(top: mediaquery.size.height * 0.07),
      child: Column(
        children: [
          const Text(
            "HELLO",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xff000080)),
          ),
          SizedBox(
            height: mediaquery.size.height * 0.03,
          ),
          if (fullname != null)
            Text(
              fullname!,
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff000080)),
            ),
          SizedBox(
            height: mediaquery.size.height * 0.08,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Payment(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/receipt.png', text: 'Payment Entry')),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerSelect(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/checklist.png', text: 'Order Entry')),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiptEntry(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/bill.png', text: 'Receipt Entry'))
            ],
          ),
          SizedBox(
            height: mediaquery.size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentReport(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/report.png', text: 'Payment Report')),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiptReport(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/recreport.png',
                      text: 'Receipt Report')),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderReport(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/orderreport.png',
                      text: 'Order Report')),
            ],
          ),
          SizedBox(
            height: mediaquery.size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Ledgerreport(),
                      )),
                  child: const Menuitem(
                      imagePath: 'assets/accounting-book.png',
                      text: 'Ledger Report')),
              GestureDetector(
                  onTap: () {
                    showdialog();
                  },
                  child: const Menuitem(
                      imagePath: 'assets/logout.png', text: 'Logout')),
            ],
          )
        ],
      ),
    )));
  }
}

class Menuitem extends StatelessWidget {
  const Menuitem({
    super.key,
    required this.imagePath,
    required this.text,
  });

  final String imagePath;
  final String text;

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
