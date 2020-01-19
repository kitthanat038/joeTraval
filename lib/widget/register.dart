import 'dart:io';

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joetravel/utility/My_style.dart';
import 'package:joetravel/utility/normal_dialog.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
//  Field
  File file;
  String name, email, password, uid, url;

// Method

  Widget emailFrom() {
    Color color = Colors.blueAccent;
    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (String string) {
          email = string.trim();
        },
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperText: 'Type Your Email In Blank',
          helperStyle: TextStyle(color: color),
          labelText: 'Email :',
          labelStyle: TextStyle(color: color),
          icon: Icon(Icons.email, color: color, size: 36.0),
        ),
      ),
    );
  }

  Widget passwordFrom() {
    Color color = Colors.green;
    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          password = string.trim();
        },
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperText: 'Type Your Password In Blank',
          helperStyle: TextStyle(color: color),
          labelText: 'Password :',
          labelStyle: TextStyle(color: color),
          icon: Icon(Icons.lock, color: color, size: 36.0),
        ),
      ),
    );
  }

  Widget nameFrom() {
    Color color = Colors.purple;
    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          name = string.trim();
        },
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperText: 'Type Your Name In Blank',
          helperStyle: TextStyle(color: color),
          labelText: 'Display Name :',
          labelStyle: TextStyle(color: color),
          icon: Icon(Icons.account_circle, color: color, size: 36.0),
        ),
      ),
    );
  }

  Widget cameraButton() {
    return OutlineButton.icon(
      icon: Icon(Icons.add_a_photo),
      label: Text('Camera'),
      onPressed: () {
        cameraOrGallery(ImageSource.camera);
      },
    );
  }

  Future<void> cameraOrGallery(ImageSource imageSource) async {
    try {
      var object = await ImagePicker.pickImage(
        source: imageSource,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );

      setState(() {
        file = object;
      });
    } catch (e) {
      print('e ===>> ${e.toString()}');
    }
  }

  Widget galleryButton() {
    return OutlineButton.icon(
      icon: Icon(Icons.add_photo_alternate),
      label: Text('gallery'),
      onPressed: () {
        cameraOrGallery(ImageSource.gallery);
      },
    );
  }

  Widget showButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[cameraButton(), galleryButton()],
    );
  }

  Widget showAvatar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: file == null ? Image.asset('images/avatar.png') : Image.file(file),
    );
  }

  Widget registerButton() {
    return IconButton(
      icon: Icon(Icons.cloud_upload),
      onPressed: () {
        if (file == null) {
          normalDialog(
              context, 'NO Image', 'Plase Click or Gallery for Choose Image');
        } else if (name == null ||
            name.isEmpty ||
            email == null ||
            email.isEmpty ||
            password == null ||
            password.isEmpty) {
          normalDialog(context, 'Have Space', 'Plese Fill Every Blank');
        } else {
          registerFirebase();
        }
      },
    );
  }

  Future<void> registerFirebase() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((response) {
      print('Register Success');
      findUID();
    }).catchError((response) {
      print('Register Fale');
      String title = response.code;
      String message = response.message;
      normalDialog(context, title, message);
    });
  }

  Future<void> findUID() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    uid = firebaseUser.uid;
    print('uid = $uid');
    uploadPicture();
  }

  Future<void> uploadPicture() async {
    Random random = Random();
    int i = random.nextInt(1000);
    String namePic = 'avata$i.jpg';

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    StorageReference storageReference =
        firebaseStorage.ref().child('Avatar/$namePic');
    StorageUploadTask storageUploadTask = storageReference.putFile(file);

    url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    print('url = $url');
    insertValueToFirestore();
  }

  Future<void> insertValueToFirestore() async {
    Map<String, dynamic> map = Map();
    map['Name'] = name;
    map['Uid'] = uid;
    map['Url'] = url;

    Firestore firestore = Firestore.instance;
    CollectionReference collectionReference = firestore.collection('Travel');
    await collectionReference.document().setData(map).then((respone) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          registerButton(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('Register'),
      ),
      body: ListView(
        children: <Widget>[
          showAvatar(),
          showButton(),
          nameFrom(),
          emailFrom(),
          passwordFrom(),
        ],
      ),
    );
  }
}
