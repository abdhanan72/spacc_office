import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPayment extends StatefulWidget {
  final int paynum;
  final String paydate;
  const EditPayment({super.key, required this.paynum, required this.paydate});

  @override
  State<EditPayment> createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  TextEditingController datecontroller = TextEditingController();

  Future<String?> getFirmId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fid = prefs.getString('firm_id');
    return fid;
  }

  String? fid;
  @override
  void initState() {
    
    getFirmId().then((value) {
      setState(() {
        fid = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: mediaquery.size.height * 0.05,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: mediaquery.size.width * 0.1),
              child: TextFormField(
                controller: datecontroller,
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
                        DateFormat("yyyy-MM-dd").format(pickdate);
                    setState(() {
                      datecontroller.text = formateddate.toString();
                    });
                  } else {}
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
