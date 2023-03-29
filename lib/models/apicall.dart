import 'dart:convert';

import 'package:spacc_office/models/salemodel.dart';

import '../License/urls.dart';
import 'package:http/http.dart' as http;

Future<Order> fetchSale( String ordnumber, String fid) async {
  var response = await http.post(Uri.parse(paymenturl), body: {
    'action': 'VIEW',
    'ordnumber': ordnumber,
    'fid': fid,
  });
  
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    final order = Order.fromJson(data['data']);
    return order;
  } else {
    throw Exception('Failed to fetch order data');
  }
}

