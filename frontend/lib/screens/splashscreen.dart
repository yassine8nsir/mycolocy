

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mon_projet/screens/onboardingscreen.dart';

/// Initial splash that shows the logo then routes to the onboarding flow.
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
   @override
  void initState() {
    // Wait a few seconds, then replace the splash with the onboarding pages.
    Timer(
      Duration(seconds: 9), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>onboardingscreen()));
      }
    );
    super.initState();
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.bottomCenter,
            colors: [
            Colors.deepOrangeAccent,
            CupertinoColors.lightBackgroundGray
          ])
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 100,width: 100,),
            Text("MyColocy",style: TextStyle(
              color: Colors.amber
            ),
            )
          ],
        ),
      ),
    );
  }
}