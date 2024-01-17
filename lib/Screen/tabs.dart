import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:my_safety_main_app/Screen/feed.dart';
import 'package:my_safety_main_app/Screen/listContact.dart';

import '../Services/auth.dart';
import '../utilities/app_color.dart';
import 'home_sceen.dart';
import 'setting.dart';


class Tabs extends StatefulWidget {
  const Tabs({Key? key,required this.page});
  final int page;
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  Widget getPage(int currentPage) {
    switch (currentPage) {
      case 0:
        return const Home();
      case 1:
        return  Feed(uid: uid,);
      case 2:
        return   ContactList(uid: uid);
      case 3:
        return   Profile();
    }
    return const Home();
  }

  int selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.page;
    getData();
  }
  getData()async{
    uid = await Auth.getUid();
  }
  String uid = "";
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
          initialActiveIndex: 0,
          backgroundColor: kPrimaryColor,
          height: 60,
          items: const[
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.feed, title: 'Feed'),
            TabItem(icon: Icons.contact_page, title: 'Contacts'),
            TabItem(icon: Icons.settings, title: 'Setting'),
          ],
          onTap: (int i)  {selectedIndex = i;setState(() {
          });}
      ),
      body: getPage(selectedIndex) ,
    );
  }
}