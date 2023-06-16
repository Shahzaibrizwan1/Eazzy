// ignore_for_file: unnecessary_import, unused_import, unused_field

import 'dart:developer';
import 'package:ezzychat/API/Apis.dart';
import 'package:ezzychat/Screens/auth/login_screen.dart';
import 'package:ezzychat/Screens/home_screen.dart';
import 'package:ezzychat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
//  bool _isAnimated = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        log('\n _signInWithGoogle ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .25,
              width: mq.width * .5,
              right: mq.width * .25,
              child: Image.asset(
                'Assets/Logo.png',
              )),
          Positioned(
              bottom: mq.height * .30,
              width: mq.width,
              child: Text(
                'Eazzy Chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                    letterSpacing: .5, fontSize: 26, color: Colors.black),
              ))
        ],
      ),
    );
  }
}
