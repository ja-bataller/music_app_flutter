// FLUTTER PACKAGE
import 'dart:io';
import 'package:flutter/material.dart';

// EXTERNAL PACKAGE USED - FROM PUB.DEV
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;

  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTrack, this.key}) : super(key: key);
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false;

  final AudioPlayer player = AudioPlayer();

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  // DISPOSE FUNCTION NULL SAFETY
  void dispose() {
    super.dispose();
    player?.dispose();
  }

  // FUNCTION TO GET THE DETAILS OF THE AUDIO TRACK
  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      if (currentValue >= maximumValue) {
        widget.changeTrack(true);
      }
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  // FUNCTION TO KNOW IF THERE IS A SONG PLAYING
  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }
  // FUNCTION TO GET THE DURATION OF THE AUDIO TRACK
  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff141414),
        appBar: AppBar(
          backgroundColor: Color(0xff141414),
          title: Text("Now Playing"),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.blueAccent)),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(8, 30, 8, 0),
          child: Column(children: <Widget>[
            Center(
              child: Container(
                width: 280.0,
                height: 280.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    image: DecorationImage(
                      image: widget.songInfo.albumArtwork == null
                          ? AssetImage('assets/disc.gif')
                          : FileImage(File(widget.songInfo.albumArtwork)),
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                widget.songInfo.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 6, 0, 25),
              child: Text(
                widget.songInfo.artist,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Slider(
              inactiveColor: Colors.grey,
              activeColor: Colors.lightBlueAccent,
              min: minimumValue,
              max: maximumValue,
              value: currentValue,
              onChanged: (value) {
                currentValue = value;
                player.seek(Duration(milliseconds: currentValue.round()));
              },
            ),
            Container(
              transform: Matrix4.translationValues(0, -15, 0),
              margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentTime,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500)),
                  Text(endTime,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500))
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                      )),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Icon(Icons.skip_previous,
                            color: Colors.grey[300], size: 35),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          widget.changeTrack(false);
                        },
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: Colors.white,
                              size: 80),
                        ),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          changeStatus();
                        },
                      ),
                      GestureDetector(
                        child:
                            Icon(Icons.skip_next, color: Colors.grey[300], size: 35),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          widget.changeTrack(true);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
          ),
        ),
      ),
    );
  }
}
