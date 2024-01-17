
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth{

  static Future<String> getUid()async{
    var uid =  FirebaseAuth.instance.currentUser!.uid;
    return uid;
  }

  static Future<bool> savePassword(var data)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("password", data);
    return true;
  }

  static Future<dynamic> getPassword()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("password");
  }
  static Future<bool> saveUser(var data)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("user", jsonEncode(data));
    return true;
  }

  static Future<dynamic> getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return jsonDecode(pref.getString("user").toString());
  }


}