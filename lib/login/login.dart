// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:lottie/lottie.dart';
import 'package:my_safety_main_app/Screen/block_screen.dart';
import 'package:my_safety_main_app/Services/config.dart';
import 'package:my_safety_main_app/login/register.dart';
import 'package:my_safety_main_app/utilities/alert.dart';

import '../Screen/home_sceen.dart';
import '../Screen/tabs.dart';
import '../Services/auth.dart';
import '../main.dart';
import '../utilities/app_color.dart';
import '../utilities/loding.dart';
import 'forgetpassword.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordSee = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceTokenToSendNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * .25,
                  width: MediaQuery.of(context).size.width * .60,
                  child:  ClipRRect(
                      borderRadius: BorderRadius.circular(150.0),
                      child: Lottie.asset("assets/animation/safety.json",))
                  ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Start with singing",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                ),
              ),
              Form(
                  key: formkey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: TextFormField(
                          controller: emailController,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'example@gmail.com',
                            labelStyle: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500),
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: kPrimaryColor,
                            ),
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'Required*'),
                            EmailValidator(errorText: 'Not a valid email'),
                          ]),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: TextFormField(
                            controller: passwordController,
                            validator:
                                RequiredValidator(errorText: 'Required*'),
                            style:
                                TextStyle(color: Colors.black.withOpacity(.7)),
                            cursorColor: Colors.black.withOpacity(.3),
                            obscureText: isPasswordSee,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: "Enter Password",
                              labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w500),
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon:
                                  Icon(Icons.lock_open, color: kPrimaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordSee == false
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordSee == true
                                        ? isPasswordSee = false
                                        : isPasswordSee = true;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPassword()));
                              },
                              child: Text(
                                "Forget Password?",
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * .80,
                        height: 55,
                        color: kPrimaryColor,
                        child: Text('Login',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0)),
                        elevation: 18.0,
                        clipBehavior: Clip.antiAlias,
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            Loading.showLoading("loading");
                            if (await checkUser() == true) {
                              await loginUser();
                            } else {
                              Alert.showAlert("User not found");
                              Loading.closeLoading();
                            }
                          } else {
                            print('not validate');
                          }
                        },
                      ),
                    ],
                  )),
              SizedBox(
                height: 15,
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have a account?",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()));
                    },
                    child: Text(
                      " Signup",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future login() async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();
      Alert.showAlert(error);
      passwordController.clear();
    }
  }

  checkUser() async {
    final users = FirebaseFirestore.instance.collection('Users');
    final data =
        await users.where('email', isEqualTo: emailController.text).get();
    List list = data.docs;
    if (list.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  loginUser() async {
    dynamic result = await login();
    if (result == null) {
      print("no login");
      Loading.closeLoading();
    } else {
      var uid = await Auth.getUid();
      final users = FirebaseFirestore.instance.collection('Users');
      await users.doc(uid).update({"fcm": deviceTokenToSendPushNotification});
      var data = await users.doc(uid).get();
      var list = data.data();
      print(list);
      Config.userData = list;
      await Auth.savePassword(passwordController.text);
      await Auth.saveUser(list);
      await checkAccount();
    }
  }

  checkAccount() async {
    if (FirebaseAuth.instance.currentUser != null) {
      var uid = await Auth.getUid();
      final ref = FirebaseFirestore.instance.collection("Users");
      var data = await ref.doc(uid).get();
      if (data.exists) {
        var doc = data.data();
        if (doc!["false_alert"] != null && doc["false_alert"] > 3) {
          Loading.closeLoading();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BlockScreen()),
              (route) => false);
        }else{
          Loading.closeLoading();
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => Tabs(
                page: 0,
              ),
            ),
                (route) => false, //if you want to disable back feature set to false
          );
        }
      }
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    deviceTokenToSendPushNotification = token.toString();
    print("Token Value $deviceTokenToSendPushNotification");
  }

  var deviceTokenToSendPushNotification = "";
}
