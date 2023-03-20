import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/itemodel.dart';





Future<ItemModel> fetchdata(
    {required String fid,
    }) async {
  final response = await http.get(Uri.parse(
      'http://cloud.spaccsoftware.com/hanan_api/test/get_heads_list.php?fid=$fid'));

  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final itemmodel = ItemModel.fromJson(responseJson);
    return itemmodel;
  } else {
    throw Exception('Failed to load data');
  }
}
