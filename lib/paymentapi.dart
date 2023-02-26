import 'dart:convert';


import 'package:http/http.dart' as http;

Future<void> makepayment(
  String fid,
  String paydate,
  String accode,
  String memo,
  String amount,
  String Paymethod,
) async {
  final response = await http.post(
      Uri.parse('http://cloud.spaccsoftware.com/hanan_api/save_payment.php'),
      body: jsonEncode(<String, dynamic>{
        'fid': fid,
        'paydate': paydate,
        'accode': accode,
        'memo': memo,
        'amount': amount,
        'Paymethod': Paymethod
      }));
  if (response.statusCode == 200) {
    print(response.body);
  }
}
