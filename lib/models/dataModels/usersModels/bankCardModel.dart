import '/system/keys.dart';

class BankCardModel {
  int userId = 0;
  String cardNumber = '';
  bool isMain = false;
  Map? extra;

  BankCardModel();

  BankCardModel.fromMap(Map<String, dynamic>? map){
    if(map == null){
      return;
    }

    userId = map[Keys.userId];
    cardNumber = map['card_number'];
    isMain = map['is_main'];
    extra = map['extra'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map[Keys.userId] = userId;
    map['card_number'] = cardNumber;
    map['is_main'] = isMain;
    map['extra'] = extra;

    return map;
  }

  String? get expiryDate {
    if(extra == null){
      return null;
    }

    return extra!['expiry_date'];
  }

  String? get cvvCode {
    if(extra == null){
      return null;
    }

    return extra!['cvv'];
  }
}