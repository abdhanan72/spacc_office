import 'dart:convert';

import 'package:spacc_office/License/urls.dart';
import 'package:spacc_office/models/itemmodel.dart';
import 'package:http/http.dart' as http;
import 'order.dart';

Future<ItemList> fetchitem() async {
    final data = {'action': 'LIST', 'fid': firmId};

    final response = await http.post(Uri.parse(itemsurl), body: data);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      final itemmodel = ItemList.fromJson(responseJson);
      return itemmodel;
    } else {
      throw Exception('Failed to load data');
    }
  }