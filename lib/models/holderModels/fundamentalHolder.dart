import 'package:flutter/material.dart';

import '/models/dataModels/foodModels/materialFundamentalModel.dart';

class FundamentalHolder {
  late TextEditingController editingController;
  late MaterialFundamentalModel fundamental;
  bool isMain = false;

  FundamentalHolder();

  FundamentalHolder.by(this.fundamental, this.isMain);
}
