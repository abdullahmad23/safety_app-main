import 'dart:async';
import 'dart:ui';
import 'package:android_physical_buttons/android_physical_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/auth.dart';
import '../Services/config.dart';
import '../utilities/alert.dart';

class BackGroundServices {
  static String? _latestHardwareButtonEvent;
  static int powerButtonPressCount = 0;
  static int lastPowerButtonPressTimestamp = 0;
  static bool sent = true;

  static Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance serviceInstance) async {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(milliseconds: 2900), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {}
        AndroidPhysicalButtons.listen((key) {
          _latestHardwareButtonEvent = key.toString();
          if (key.name == 'power') {
            handlePowerButtonPress();
          } else {
            debugPrint(key.name);
          }
        });
        service.invoke('update');
      }
    });
  }

  static void handlePowerButtonPress() {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

// Check if the time since the last press is within 3 seconds
    if (currentTimestamp - lastPowerButtonPressTimestamp <= 3000) {
      powerButtonPressCount++;
      debugPrint('Counting ... $powerButtonPressCount');

// Check if 5 consecutive presses have occurred
      if (powerButtonPressCount >= 3 && sent) {
        sendMessage();
        powerButtonPressCount = 0; // Reset count after sending SOS
      }
    } else {
// _locationDto = null;
      powerButtonPressCount = 1; // Reset count if the time gap is too long
      sent = true;
    }

    lastPowerButtonPressTimestamp = currentTimestamp;
  }

  static sendMessage() async {
    sent = false;
    Config.userData = await Auth.getUser();
    if (Config.userData != null) {
      Config.address = await await getLocation();
      await Firebase.initializeApp();
      Config.userData = await Auth.getUser();
      await Config.fetchFriend();
      var uid = await Auth.getUid();
      var now = DateTime.now();
      final ref = FirebaseFirestore.instance.collection("Notifications");
      try {
        Config.friendIds.add({"_id": uid});
        for (var item in Config.friendIds) {
          await ref.doc(item["_id"]).collection("NotificationList").add({
            "time": now,
            "text": "Emergency Alert",
            "type": "text",
            "sendBy": Config.userData["name"],
            "_id": uid,
            "location": Config.address,
            "isAlertTrue": true,
            "sentByID": uid,
            "isRead": false,
          });
        }
        Config.friendIds.removeLast();
        Config.callOnFcmApiSendPushNotifications(
            "Your friend may need your help. Please help him");
        Alert.showAlert("Alert Send Successfully");
        sent = true;
      } catch (e) {
        sent = true;
        print(e);
      }
    }
  }

  static Future<dynamic> getLocation() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.getString("location");
  }

  static Future<dynamic> setLocation(loc) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.setString("location", loc).toString();
  }
}
