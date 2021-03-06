// FLUTTER PACKAGE
import 'dart:async';
import 'package:flutter/material.dart';

// EXTERNAL PACKAGE USED - PUB.DEV
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:music_player/audio_tracks.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // THIS WIDGET IS THE ROOT OF THE APPLICATION

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(
      Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        // GO TO AUDIO TRACKS PAGE
        MaterialPageRoute(builder: (context) => AudioTracks()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff141414),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            // SPIN KIT - LOADER
            child: SpinKitWave(
              color: Color(0xffa0eef3),
              size: 100.0,
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          Text("Loading...", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}