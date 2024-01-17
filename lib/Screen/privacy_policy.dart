import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../utilities/privacy.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Html(
              data: privacy,
          ),
        ),
      ),
    );
  }
}
