import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spacc_office/License/urls.dart';

import '../models/headsmodel.dart';





Future<ItemModel> fetchdata(
    {required String fid,
    }) async {
  final response = await http.get(Uri.parse(
      '$headsurl?fid=$fid'));

  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final itemmodel = ItemModel.fromJson(responseJson);
    return itemmodel;
  } else {
    throw Exception('Failed to load data');
  }
}
