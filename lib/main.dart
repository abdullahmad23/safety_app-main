import 'dart:async';

import 'package:android_physical_buttons/android_physical_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_safety_main_app/Notificatio%20Services/background%20Service.dart';
import 'package:my_safety_main_app/Screen/home_sceen.dart';
import 'package:my_safety_main_app/utilities/alert.dart';
import 'package:my_safety_main_app/utilities/app_color.dart';
import 'package:my_safety_main_app/utilities/loding.dart';
import 'package:path/path.dart';
import 'Notificatio Services/notification.dart';
import 'Screen/block_screen.dart';
import 'Screen/tabs.dart';
import 'Services/auth.dart';
import 'Services/config.dart';
import 'login/welcome.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  print("BackGround");
}

checkAccount() async {
  if (FirebaseAuth.instance.currentUser != null) {
    var uid = await Auth.getUid();
    final ref = FirebaseFirestore.instance.collection("Users");
    var data = await ref.doc(uid).get();
    if (data.exists) {
      var doc = data.data();
      if (doc!["false_alert"] != null && doc["false_alert"] > 3) {
        isAccountBlocked = true;
      }
    }
  }
}

bool isAccountBlocked = false;
int volumeCount = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  BackGroundServices.initializeBackgroundService();
  await checkAccount();
  await _determinePosition();
  runApp(const MyApp());
}

bool isSent = false;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationSetting();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kScaffoldColor,
        elevatedButtonTheme: elevatedButtonThemeData,
        appBarTheme: appBarTheme,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? 'WelcomeScreen'
          : isAccountBlocked == false
              ? 'Home'
              : "BlockScreen",
      routes: {
        'WelcomeScreen': (context) => Welcome(),
        'Home': (context) => Tabs(
              page: 0,
            ),
        "BlockScreen": (context) => BlockScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}

void notificationSetting() {
  FirebaseMessaging.instance.getInitialMessage().then(
    (message) {
      print("FirebaseMessaging.instance.getInitialMessage");
      if (message != null) {
        print("New Notification");
        // if (message.data['_id'] != null) {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (context) => DemoScreen(
        //         id: message.data['_id'],
        //       ),
        //     ),
        //   );
        // }
      }
    },
  );

  // 2. This method only call when App in forground it mean app must be opened
  FirebaseMessaging.onMessage.listen(
    (message) {
      print("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print("message.data11 ${message.data}");
        LocalNotificationService.createanddisplaynotification(message);
      }
    },
  );

  // 3. This method only call when App in background and not terminated(not closed)
  FirebaseMessaging.onMessageOpenedApp.listen(
    (message) {
      print("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print("message.data22 ${message.data['_id']}");
      }
    },
  );
}

_determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 60),
  );
  Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen((Position position) async {
    Config.lat = position.latitude;
    Config.lng = position.longitude;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(Config.lat, Config.lng);
    await placemarkFromCoordinates(Config.lat, Config.lng);
    Config.address =
        "${placemarks[0].street}, ${placemarks[0].subAdministrativeArea} ${placemarks[0].subLocality} ${placemarks[0].locality} ${placemarks[0].administrativeArea} ${placemarks[0].postalCode}, ${placemarks[0].country}, ${placemarks[0].name}";
    await BackGroundServices.setLocation(Config.address);
  });
}
