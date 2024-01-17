// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:my_safety_main_app/Services/config.dart';
import 'package:my_safety_main_app/utilities/alert.dart';
import 'package:my_safety_main_app/utilities/loding.dart';
import '../utilities/app_color.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isPasswordSee = true;
  bool isConPasswordSee = true;
  String countryCode = "+92";

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String? uid;

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    deviceTokenToSendPushNotification = token.toString();
    print("Token Value $deviceTokenToSendPushNotification");
  }
  var deviceTokenToSendPushNotification = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceTokenToSendNotification();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
              SizedBox(
                height: 50,
              ),
              Text(
                'Let Get Started!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Create account to get more feature",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                ),
              ),
              Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: formkey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: TextFormField(
                          validator: RequiredValidator(errorText: 'Required'),
                          onChanged: (value) {},
                          controller: nameController,
                          decoration: InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter Name',
                              prefixIcon: Icon(
                                Icons.people_outline,
                                color: kPrimaryColor,
                              ),
                            labelStyle: TextStyle(color:kPrimaryColor, fontWeight: FontWeight.w500),
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: TextFormField(
                          controller: emailController,
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'Required'),
                            EmailValidator(errorText: 'Not a valid Email'),
                          ]),
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'example@gmail.com',
                              prefixIcon: Icon(
                                Icons.mail,
                                color: kPrimaryColor,
                              ),
                            labelStyle: TextStyle(color:kPrimaryColor, fontWeight: FontWeight.w500),
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.phone,
                                  color: kPrimaryColor,
                                ),
                                CountryCodePicker(
                                  onChanged: (value){
                                    countryCode = value.toString();
                                    print(countryCode);
                                  },
                                  textStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),
                                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                  initialSelection: "+92",
                                  favorite: ["+92"],
                                  // optional. Shows only country name and flag
                                  showCountryOnly: false,
                                  // optional. Shows only country name and flag when popup is closed.
                                  showOnlyCountryWhenClosed: false,
                                  // optional. aligns the flag and the Text left
                                  showFlag: false,
                                  showFlagDialog: true,
                                  alignLeft: false,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey,
                                            width: 0.5,
                                            style: BorderStyle.solid),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: phoneController,
                                      cursorColor: Colors.black.withOpacity(.3),
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(color: Colors.black.withOpacity(.7)),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                       border: InputBorder.none,
                                        hintText: 'Enter your Phone',
                                        labelStyle: TextStyle(color: kPrimaryColor,fontWeight: FontWeight.w500),
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 1,width: double.infinity,
                              color: kPrimaryColor,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: isPasswordSee,
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'Required'),
                            MaxLengthValidator(15,
                                errorText: 'Password less than 15 characters'),
                            MinLengthValidator(6,
                                errorText:
                                'Password greater than 6 characters'),
                          ]),
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: "Enter Password",
                              suffixIcon: IconButton(
                                icon:Icon(
                                  isPasswordSee == false? Icons.visibility: Icons.visibility_off,
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
                              prefixIcon:
                              Icon(Icons.lock_open, color: kPrimaryColor),
                            labelStyle: TextStyle(color:kPrimaryColor, fontWeight: FontWeight.w500),
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: TextFormField(
                          controller: cPasswordController,
                          obscureText: isConPasswordSee,
                          onChanged: (value) {
                            // cpassword = value;
                          },
                          validator: (cpassword) {
                            if (passwordController.text !=
                                cPasswordController.text) {
                              return 'Password are not same';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: "Enter Confirm Password",
                              prefixIcon:
                              Icon(Icons.lock_open, color: kPrimaryColor),
                              suffixIcon: IconButton(
                                icon:Icon(
                                  isConPasswordSee == false? Icons.visibility: Icons.visibility_off,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isConPasswordSee == true
                                        ? isConPasswordSee = false
                                        : isConPasswordSee = true;
                                  });
                                },
                              ),
                            labelStyle: TextStyle(color:kPrimaryColor, fontWeight: FontWeight.w500),
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                             ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * .80,
                        height: 55,
                        color: kPrimaryColor,
                        child: Text('Create',
                            style:
                            TextStyle(fontSize: 16.0, color: Colors.white)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0)),
                        elevation: 18.0,
                        clipBehavior: Clip.antiAlias,
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                           Loading.showLoading("loading");
                            createUser();
                          } else {
                            print('not validate');
                          }
                        },
                      ),
                    ],
                  )),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      " Login here",
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
  Future register() async {
    try {
      print("Hello");
      CollectionReference users =
      FirebaseFirestore.instance.collection('Users');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      User? user = result.user;
      uid = result.user!.uid.toString();

      users.doc(result.user!.uid).set({
        'name': nameController.text,
        'email': emailController.text,
        "phone" : countryCode+phoneController.text,
        "fcm" :  deviceTokenToSendPushNotification,
        "_id":uid,
      });
      Config.fetchFriend();
      return user;
    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();
      Alert.showAlert(error);
      passwordController.clear();
      cPasswordController.clear();
    }
  }

  void createUser() async {
    dynamic result = await register();
    if (result == null) {
      print("not register");
      Loading.closeLoading();
    } else {
      Loading.closeLoading();
      if(!mounted)return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login()), (route) => false);
    }
  }
}