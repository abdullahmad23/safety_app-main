// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:lottie/lottie.dart';
import 'package:my_safety_main_app/utilities/loding.dart';
import 'package:velocity_x/velocity_x.dart';

import '../utilities/alert.dart';
import '../utilities/app_color.dart';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String? email;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  void snackBar(Text text){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:text,
        duration: Duration(seconds: 5),
      ),
    );
  }
  Future restPassword(String email)async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Loading.closeLoading();
      if(!mounted)return;
      Navigator.pop(context);
      snackBar(Text('The link has been send to your email...'));
      Loading.closeLoading();
    }on FirebaseAuthException
    catch(e){
      String error = e.message.toString() ;
      Loading.closeLoading();
      Alert.showAlert(error);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Column(
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
                     Text("")
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                Text('Rest Password',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                SizedBox(height: 20,),
                Lottie.asset(
                  'assets/animation/forgot-password.json',
                  height: MediaQuery.of(context).size.height * .30,
                  width: MediaQuery.of(context).size.width * .80,
                ),
                SizedBox(height: 30,),
                Form(
                  key: formkey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30,bottom: 20,left: 30,right: 30),
                      child: TextFormField(
                        onChanged: (value){
                          email = value;
                        },
                        decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'example@gmail.com',
                          labelStyle: TextStyle(color:kPrimaryColor, fontWeight: FontWeight.w500),
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
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed:()async{
                            if(formkey.currentState!.validate())
                            {
                             Loading.showLoading("loading");
                              restPassword(email.toString());
                            }
                          },
                          child:Text('Send Email'),
                          style: ElevatedButton.styleFrom(
                            primary: kPrimaryColor,
                          ),
                        ),
                      ),
                    )

                  ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
