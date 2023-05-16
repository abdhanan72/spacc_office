// To parse this JSON data, do
//
//     final itemModel = itemModelFromJson(jsonString);

import 'dart:convert';

ItemModel itemModelFromJson(String str) => ItemModel.fromJson(json.decode(str));

String itemModelToJson(ItemModel data) => json.encode(data.toJson());

class ItemModel {
  ItemModel({
    required this.responseCode,
    required this.responseDesc,
    required this.data,
  });

  int responseCode;
  String responseDesc;
  List<Datum> data;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        responseCode: json["response_code"],
        responseDesc: json["response_desc"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "response_desc": responseDesc,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
   
    required this.firmId,
    required this.headCode,
    required this.headName,
    required this.currentBalance,
     this.type,
  });
  int firmId;
  String headCode;
  String headName;
  String currentBalance;
  String? type;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
       
        firmId: json["firm_id"],
        headCode: json["head_code"],
        headName: json["head_name"],
        currentBalance: json["current_balance"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "firm_id": firmId,
        "head_code": headCode,
        "head_name": headName,
        "current_balance": currentBalance,
        "type": type,
      };
}
