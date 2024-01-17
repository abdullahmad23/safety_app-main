

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';

class Config{

  static dynamic userData;
  static double lat = 0.000;
  static double lng = 0.000;
  static String address = "";
  static String link = "";
  static List friendIds = [];
  static List fcm = [];


  static fetchFriend()async{
    Config.friendIds = [];
    Config.fcm = [];

    var uid = await Auth.getUid();
    final  ref = FirebaseFirestore.instance.collection("Contacts");
    final  user = FirebaseFirestore.instance.collection("Users");

    try{
      QuerySnapshot data   = await ref.doc(uid).collection("contactList").get();
      if (data.size != 0){
        for (var item in data.docs) {
          var document = item.data();
          Config.friendIds.add(document);
        }
      }
      print("___________");
      print(friendIds);

      for (var item in Config.friendIds) {
       var data = await user.doc(item["_id"].toString().replaceAll(" ", "")).get();
       if(data.exists) {
         fcm.add(data.get("fcm"));
       }
      }
    print(fcm);
    }catch(e){
      print(e);
    }
  }


  static Future<bool> callOnFcmApiSendPushNotifications(var body) async {

    String postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "registration_ids" : Config.fcm,
      "collapse_key" : "type_a",
      "notification" : {
        "title": "${Config.userData["name"]}",
        "body" : body,
      }
    };

    var headers = {
      'content-type': 'application/json',
      'Authorization': "key=AAAA8Yhdij0:APA91bHdvOiVH1DbvOMIq0sFaXaKGmjtassXU7HPfj-mcHpmj06R-8-6lqnKIyFVCvpzMAcLEZ718K4-_FUqo79YEqct6EMrd2taPP1Z7Nle88F9K16187oYfcT7_h_2RRdjOBajwmTF"// 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(response.body);
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }

}