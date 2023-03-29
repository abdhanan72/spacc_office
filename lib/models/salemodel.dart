class Order {
  String firmId;
  String ordNumber;
  String ordDate;
  String salesmanCode;
  String custNumber;
  String custName;
  String totalAmount;
  String memo;
  String createdLmdts;
  String createdUser;
  List<Item> itemData;

  Order({
    required this.firmId,
    required this.ordNumber,
    required this.ordDate,
    required this.salesmanCode,
    required this.custNumber,
    required this.custName,
    required this.totalAmount,
    required this.memo,
    required this.createdLmdts,
    required this.createdUser,
    required this.itemData,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemList = json['itemdata'] as List;
    List<Item> items =
        itemList.map((i) => Item.fromJson(i)).toList();

    return Order(
      firmId: json['firm_id'],
      ordNumber: json['ordnumber'],
      ordDate: json['orddate'],
      salesmanCode: json['salesmancode'],
      custNumber: json['cust_number'],
      custName: json['cust_name'],
      totalAmount: json['totalamount'],
      memo: json['memo'],
      createdLmdts: json['created_lmdts'],
      createdUser: json['created_user'],
      itemData: items,
    );
  }
}

class Item {
  String itemCode;
  String qty;
  String rate;

  Item({
    required this.itemCode,
    required this.qty,
    required this.rate,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['item_code'],
      qty: json['qty'],
      rate: json['rate'],
    );
  }
}
