


import 'package:flutter/material.dart';

Color kPrimaryColor = const Color(0xFF1877BD);
Color kScaffoldColor = Colors.grey[200]!;


ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ButtonStyle(
    foregroundColor:
    MaterialStateProperty.all<Color>(Colors.white),
    backgroundColor:
    MaterialStateProperty.all<Color>(kPrimaryColor),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
  ),
  );


AppBarTheme appBarTheme = AppBarTheme(
  color: kPrimaryColor,
  centerTitle: true,
);