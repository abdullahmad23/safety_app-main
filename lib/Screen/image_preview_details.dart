import 'package:flutter/material.dart';

class ImageDetailsPreview extends StatelessWidget {
  const ImageDetailsPreview({Key? key, required this.image}) : super(key: key);
  final String image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image:
            DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)),
      ),
    );
  }
}
