import 'package:flutter/material.dart';

class BlockScreen extends StatelessWidget {
  const BlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Your Account is block due to false alert"),
      ),
    );
  }
}
