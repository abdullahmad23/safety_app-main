// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:io';

import '../Services/config.dart';
import '../Services/file_handling.dart';
import '../utilities/app_color.dart';
import '../utilities/loding.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({Key? key,required this.isEditShow}) : super(key: key);
  final bool isEditShow;
  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool isTaped = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                )),
          ),
          Positioned(
              left: MediaQuery.of(context).size.width * .50 - 80,
              right: MediaQuery.of(context).size.width * .50 - 80,
              top: -50,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: isTaped
                        ? NetworkImage(Config.link)
                        : Config.userData["image"] == null ||
                                Config.userData["image"] == ""
                            ? AssetImage("assets/images/profile.png")
                            : NetworkImage(Config.userData["image"])
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(width: 5, color: Colors.white),
                ),
              )),
          widget.isEditShow?Positioned(
            left: MediaQuery.of(context).size.width * .50,
            top: 35,
            child: GestureDetector(
              onTap: () async {
                pickFile();
              },
              child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.edit,
                    color: Colors.black,
                  )),
            ),
          ):SizedBox(),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Config.userData["name"]
                    .toString()
                    .toString()
                    .text
                    .white
                    .bold
                    .size(25)
                    .make(),
                SizedBox(
                  height: 15,
                ),
                Config.userData["email"].toString().text.white.size(20).make(),
              ],
            ),
          )
        ],
      ),
    );
  }

  pickFile() async {
    var result = await FileServices.pickFile();
    if (result != null) {
      PlatformFile file = result.files.first;
      uploadImage(file);
    }
  }

  void uploadImage(var img) async {
    Loading.showLoading("loading");
    Config.link = await FileServices.compressImage(img, "Profile_Attachment");
    Loading.closeLoading();
    setState(() {
      isTaped = true;
    });
  }
}
