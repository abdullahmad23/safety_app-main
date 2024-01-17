import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loading {
  static void showLoading(String loading)  {
    EasyLoading.show(status: '$loading...');
  }

  static void closeLoading(){
    EasyLoading.dismiss();
  }
}