import 'package:flutter/cupertino.dart';

class UserFilterDataModel with ChangeNotifier {
  Map<String, dynamic>? filterData;
  UserFilterDataModel({this.filterData});

  Map<String, dynamic>? get userFilterData => filterData;

  set userFilterData(Map<String, dynamic>? value) {
    filterData = value;
    notifyListeners();
  }
}
