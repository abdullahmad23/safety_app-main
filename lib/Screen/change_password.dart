import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_safety_main_app/Services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: prefer_const_constructors
import '../Services/config.dart';
import '../login/login.dart';
import '../utilities/alert.dart';
import '../utilities/app_color.dart';
import '../utilities/loding.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController cuPassword = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController conPassword = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth.getPassword().then((value) => pPassword = value);
  }
  String pPassword = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cuPassword,
              decoration: InputDecoration(
                hintText: 'Enter your current password',
                label: Text("Current Password"),
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
              height: 20,
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(
                hintText: 'Enter your new password',
                label: Text("New Password"),
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
              height: 20,
            ),
            TextField(
              controller: conPassword,
              decoration: InputDecoration(
                hintText: 'Enter your confirm password',
                label: Text("Confirm Password"),
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
            SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    onPressed: () {
                      if (cuPassword.text == "" ||
                          password.text == "" ||
                          conPassword.text == "") {
                        Alert.showAlert("all field must be field");
                      } else {
                        if (password.text == conPassword.text) {
                          if (password.text.length < 6) {
                            Alert.showAlert("Password must be 6 character");
                          } else {
                            print(pPassword);
                            if (cuPassword.text == pPassword.trim()) {
                              changePassword();
                            } else {
                              Alert.showAlert(
                                  "Your Previous Password is not matched");
                            }
                          }
                        } else {
                          Alert.showAlert(
                              "Password and Confirm Password should be same");
                        }
                      }
                    },
                    child: Text("Change Password")))
          ],
        ),
      ),
    );
  }

  void changePassword() async {
    Loading.showLoading("loading");
    final FirebaseAuth firebaseAuth = await FirebaseAuth.instance;
    User currentUser = firebaseAuth.currentUser!;
    firebaseAuth
        .signInWithEmailAndPassword(
            email: Config.userData["email"],
            password: pPassword)
        .then((value) {
      currentUser.updatePassword(conPassword.text).then((value) {
        Loading.closeLoading();
        Alert.showAlert("Password is Updated");
        firebaseAuth.signOut();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Login()), (route) => false);
      }).catchError((err) {
        Loading.closeLoading();
        Alert.showAlert(err.toString());
      });
    });
  }
}
