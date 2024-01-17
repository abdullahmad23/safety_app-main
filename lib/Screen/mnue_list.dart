// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../login/login.dart';
import 'change_password.dart';
import 'privacy_policy.dart';
import 'update_profile.dart';

class MenuList extends StatefulWidget {
  const MenuList({Key? key}) : super(key: key);

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async{
                  var temp = await  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProfile()));
                },
                child: ListTile(
                  title: "Profile".text.bold.size(18).make(),
                  leading: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.black,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Divider(
                thickness: 2,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePassword()));
                },
                child: ListTile(
                  title: "Change Password".text.bold.size(18).make(),
                  leading: Icon(
                    Icons.key,
                    size: 30,
                    color: Colors.black,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Divider(
                thickness: 2,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivacyPolicy()));
                },
                child: ListTile(
                  title: "Privacy Policy".text.bold.size(18).make(),
                  leading: Icon(
                    Icons.privacy_tip,
                    size: 30,
                    color: Colors.black,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Divider(
                thickness: 2,
              ),
              GestureDetector(
                onTap: () async{
                  final FirebaseAuth firebaseAuth = await FirebaseAuth.instance;
                  firebaseAuth.signOut();
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => Login()), (route) => false);
                },
                child: ListTile(
                  title: "Log Out".text.bold.size(18).make(),
                  leading: Icon(
                    Icons.logout,
                    size: 30,
                    color: Colors.black,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
