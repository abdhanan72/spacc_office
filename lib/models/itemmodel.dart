import 'dart:convert';

ItemList itemListFromJson(String str) => ItemList.fromJson(json.decode(str));

String itemListToJson(ItemList data) => json.encode(data.toJson());

class ItemList {
  ItemList({
    required this.responseCode,
    required this.responseDesc,
    required this.data,
  });

  final int responseCode;
  final String responseDesc;
  final List<ItemListData> data;

  factory ItemList.fromJson(Map<String, dynamic> json) => ItemList(
        responseCode: json["response_code"],
        responseDesc: json["response_desc"],
        data: List<ItemListData>.from(
            json["data"].map((x) => ItemListData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "response_desc": responseDesc,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ItemListData {
  ItemListData(
     {
    required this.itemCode,
    required this.itemName,
    required this.salesrate
  });

  final String itemCode;
  final String itemName;
  final String salesrate;

  factory ItemListData.fromJson(Map<String, dynamic> json) => ItemListData(             
        
        itemCode: json["item_code"],
        itemName: json["item_name"],
        salesrate:json["sale_rate"],
      );

  Map<String, dynamic> toJson() =>
      {"item_code": itemCode, "item_name": itemName, "sale_rate": salesrate};
}
