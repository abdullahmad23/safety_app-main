
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:video_compress/video_compress.dart';
// ignore_for_file: prefer_const_constructors


class FileServices{
  static Future<dynamic> pickFile()async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg','mp4'],
    );
    if(result != null){
      return result;
    }
  }

  static Future<String> compressVideo(var video,String folder)async{
    await VideoCompress.setLogLevel(0);
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      video,
      quality: VideoQuality.LowQuality,
      includeAudio: true
      // It's false by default
    );
    var link = await uploadTask(File(mediaInfo!.path.toString()),folder);
    print(link);
    return link;
  }


  static Future<String> compressImage(var image,String folder) async {
    int sizeInBytes = File(image.path).lengthSync();
    File compressedFile = await FlutterNativeImage.compressImage(image.path,
        quality: sizeInBytes >= 800000
            ? 60
            : sizeInBytes >= 2000000
            ? 50
            : 80,
        percentage: sizeInBytes >= 800000
            ? 60
            : sizeInBytes >= 2000000
            ? 50
            : 80);
    var link = await uploadTask(compressedFile,folder);
    print(link);
    return link;
  }

  static uploadTask(File image,String folder)async{
    var link = "";
    String name = "ABA+${DateTime.now().toString()}+${getRandomString(8)}";
    FirebaseStorage storage = FirebaseStorage.instance;
    final reference =  storage.ref().child("$folder/$name");
    UploadTask uploadTask = reference.putFile(image);
    await  uploadTask.whenComplete(()async{
      link = await reference.getDownloadURL();
      print(link);
      return link;
    });
    return link;
  }

  static var chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random rnd = Random();
  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

}