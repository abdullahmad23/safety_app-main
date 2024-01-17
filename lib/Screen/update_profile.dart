import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_safety_main_app/Screen/tabs.dart';
import 'package:my_safety_main_app/Services/auth.dart';
import 'package:my_safety_main_app/Services/config.dart';
import 'package:my_safety_main_app/utilities/loding.dart';

import '../utilities/alert.dart';
import '../utilities/app_color.dart';
import 'profile_header.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController username = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  String image = "";
  String pPassword = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth.getPassword().then((value) => pPassword = value);
    username.text = Config.userData["name"];
    phone.text = Config.userData["phone"];
    email.text = Config.userData["email"];
    Config.link =
        Config.userData["image"] == null ? "" : Config.userData["image"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 60,
              ),
              ProfileHeader(isEditShow: true,),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        hintText: 'Enter Username',
                        label: Text("Username"),
                        prefixIcon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        labelStyle: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w500),
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: phone,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Phone',
                        label: Text("Phone"),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: kPrimaryColor,
                        ),
                        labelStyle: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w500),
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Email',
                        label: Text("Email"),
                        prefixIcon: Icon(
                          Icons.mail,
                          color: kPrimaryColor,
                        ),
                        labelStyle: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w500),
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                            onPressed: () {
                              if (username.text == "" || email.text == "") {
                                Alert.showAlert("all field must be fill");
                              } else {
                                updateProfile();
                              }
                            },
                            child: Text("Update Profile")))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  updateProfile() async {
    Loading.showLoading("loading");
    String uid = await Auth.getUid();
    final ref = await FirebaseFirestore.instance.collection("Users");
    final FirebaseAuth firebaseAuth = await FirebaseAuth.instance;
    User currentUser = firebaseAuth.currentUser!;
    firebaseAuth
        .signInWithEmailAndPassword(
            email: Config.userData["email"], password: pPassword)
        .then((value) {
      currentUser.updateEmail(email.text).then((value) async {
        await ref.doc(uid).update({
          "image": Config.link,
          "name": username.text,
          "email": email.text,
        });
        Config.userData["name"] = username.text;
        Config.userData["email"] = email.text;
        Config.userData["image"] = Config.link;
        await Auth.saveUser(Config.userData);
        Loading.closeLoading();
        Alert.showAlert("Profile is Updated");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Tabs(
                      page: 2,
                    )),
            (route) => false);
      }).catchError((err) {
        Loading.closeLoading();
        Alert.showAlert(err.toString());
      });
    });
  }
}
