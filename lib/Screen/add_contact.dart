import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:my_safety_main_app/utilities/alert.dart';
import 'package:my_safety_main_app/utilities/loding.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Services/auth.dart';
import '../Services/config.dart';
import '../utilities/app_color.dart';
// ignore_for_file: prefer_const_constructors

class AddContact extends StatefulWidget {
  const AddContact({Key? key}) : super(key: key);

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  List<Contact>? contacts;
  List<Contact>? total = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContact();
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      total = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      print(contacts);
      contacts = total;
      setState(() {});
    }
  }

  String code = "";
  String verId = "";

  void _runFilter(String enteredKeyword) {
    setState(() {
      contacts = total!.where((e) =>  e.name.first.toLowerCase().contains(enteredKeyword)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Loading.closeLoading();
    return Scaffold(
        appBar: EasySearchBar(
          foregroundColor: Colors.white,
                title: Text('Contacts'),
                onSearch: (value){
                    _runFilter(value);
                }),
        body: (contacts) == null
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: contacts!.length,
                itemBuilder: (BuildContext context, int index) {
                  Uint8List? image = contacts![index].photo;
                  String num = (contacts![index].phones.isNotEmpty)
                      ? (contacts![index].phones.first.number)
                      : "--";
                  return ListTile(
                      leading: (contacts![index].photo == null)
                          ? const CircleAvatar(child: Icon(Icons.person))
                          : CircleAvatar(backgroundImage: MemoryImage(image!)),
                      title: Text(
                          "${contacts![index].name.first} ${contacts![index].name.last}"),
                      subtitle: Text(num),
                      onTap: () {
                        if (num[0] == '0' &&
                            num.removeAllWhiteSpace().length == 11) {
                          showAlertDialog(
                              context,
                              num.removeAllWhiteSpace()
                                  .replaceFirst('0', '+92'),
                              "${contacts![index].name.first} ${contacts![index].name.last}");
                        } else {
                          showAlertDialog(context, num.removeAllWhiteSpace(),
                              "${contacts![index].name.first} ${contacts![index].name.last}");
                        }
                      });
                },
              ));
  }

  showAlertDialog(BuildContext context, var phone, var name) {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
      child: Text("Yes"),
      onPressed: () {
        Navigator.pop(context);
        Loading.showLoading("loading");
        checkNo(phone, name);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Do you want to add this contact?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void checkNo(var no, var name) async {
    print(no);
    var uid = await Auth.getUid();

    final ref = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot addData = await ref.where("phone", isEqualTo: no).get();
    if (addData.size > 0) {
      dynamic list = addData.docs[0].data();
      print(list);
      final ref1 = FirebaseFirestore.instance.collection('Contacts');
      var data = await ref1
          .doc(uid)
          .collection("contactList")
          .where("phone", isEqualTo: no)
          .get();
      {
        if (data.size > 0) {
          Alert.showAlert("this user is already exist in your list");
          Loading.closeLoading();
        } else {
          Loading.closeLoading();
          sentOtp(no);
          if(!mounted) return;
          otpFill(context, no, name, list);
          Alert.showAlert("We sent a code on this no please verify");
        }
      }
    } else {
      Alert.showAlert("this user is not register in app");
      Loading.closeLoading();
      return;
    }
  }



  otpFill(BuildContext context, var phone, var name,var list) {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
      child: Text("Verify"),
      onPressed: () {
        Navigator.pop(context);
        Loading.showLoading("loading");
        signIn(code, list, name, phone);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Verify"),
      content:  PinCodeTextField(
        appContext: context,
        pastedTextStyle: TextStyle(
          color: Colors.green.shade600,
          fontWeight: FontWeight.bold,
        ),
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: 40,
            fieldWidth: 30,
            inactiveFillColor: Colors.white,
            inactiveColor: Colors.grey.shade400,
            selectedColor: Colors.grey.shade400,
            selectedFillColor: Colors.white,
            activeFillColor: Colors.white,
            activeColor: Colors.grey.shade400),
        cursorColor: Colors.black,
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        keyboardType: TextInputType.number,
        boxShadows: const [
          BoxShadow(
            offset: Offset(0, 1),
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
        onChanged: (value){
          code = value;
        },
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  sentOtp(
    String phone,
  ) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {},
        verificationFailed: (FirebaseException exception) {
          if (exception.code == "too-many-requests") {
            Alert.showAlert('Too many requests, Kindly Try again later');
          } else {
            print('Your phone is not correct');
            Alert.showAlert('Your phone is not correct');
          }
        },
        codeSent: (String verificationID, int? resendToken) {
          verId = verificationID;
          print(verId);
        },
        codeAutoRetrievalTimeout: (String id) {
          print(id);
        });
  }

  signIn(String code,var list,var name,var no) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verId.toString(), smsCode: code);

      final result = await auth.signInWithCredential(credential);

      User? user = result.user;
      if (user != null) {
        var user = await login();
        if(user != null){
          addPhone(list, name, no);
        }

      } else {
        print("Error");
      }
    } catch (e) {
      Alert.showAlert("invalid otp");
      Loading.closeLoading();
    }
  }

  login()async{
    await FirebaseAuth.instance.signOut();
    var password = await Auth.getPassword();
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: Config.userData["email"], password:password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();
      Alert.showAlert(error);
    }
    print(password);
  }

  addPhone(var list, var name, var no) async {
    var uid = await Auth.getUid();
    final ref1 = FirebaseFirestore.instance.collection('Contacts');
    await ref1.doc(uid).collection("contactList").add({
      "name": name,
      "phone": no,
      "_id": list["_id"],
    });
    await ref1.doc(list["_id"]).collection("contactList").add({
      "name": Config.userData["name"],
      "phone": Config.userData["phone"],
      "_id": uid,
    });
    Config.fetchFriend();
    Loading.closeLoading();
    Alert.showAlert("Contact is Added");
  }
}
