// FLUTTER PACKAGE
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// EXTERNAL PACKAGE USED - FROM PUB.DEV
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/music_player.dart';

class AudioTracks extends StatefulWidget {
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<AudioTracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();

  TextEditingController editingController = TextEditingController();
  List<SongInfo> songs = [];
  List blankList = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getTracks();
  }

  // FUNCTION TO GET THE AUDIO TRACKS FROM THE DEVICE
  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  // FUNCTION TO CHANGE THE AUDIO TRACK - PREVIOUS & NEXT
  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songs[currentIndex]);
  }

  // FUNCTION TO SEARCH AUDIO TRACKS BY AUDIO TITLE
  void searchTracks(query) async {
    List<SongInfo> allTracks = await audioQuery.getSongs();
    List<SongInfo> searched = await audioQuery.searchSongs(query: query);

    // IF THE QUERY SEARCHED DOESN'T MATCH ANY MUSIC - SHOW MUSIC NOT FOUND
    if (query.isNotEmpty && searched.isEmpty) {
      setState(() {
        blankList.clear();
        blankList.add("No Audio found");
        print(songs);
        return;
      });
    }

    // IF THE QUERY SEARCHED FOUND A MUSIC - SHOW ALL THE MATCH MUSIC
    if (query.isNotEmpty && searched.isNotEmpty) {
      setState(() {
        blankList.clear();
        songs.clear();
        songs.addAll(searched);
        print(songs);
        searched.clear();
        return;
      });
    }

    // IF THE QUERY INPUT IS EMPTY - SHOW ALL THE MUSIC
    if (query.isEmpty) {
      setState(() {
        blankList.clear();
        songs.clear();
        songs.addAll(allTracks);
        print(songs);
        return;
      });
    }
  }

  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff141414),
        body: songs.isEmpty == true
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/tuzki.gif'),
                      radius: 100.0,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "No music found",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 0, 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text("Library",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 50.0,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        searchTracks(value);
                      },
                      controller: editingController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            borderSide:
                                BorderSide(width: 1, color: Colors.blueGrey),
                          ),
                          labelText: "Search",
                          labelStyle:
                              TextStyle(fontSize: 20.0, color: Colors.grey),
                          hintText: "Title",
                          hintStyle:
                              TextStyle(fontSize: 20.0, color: Colors.white),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.lightBlueAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: blankList.isNotEmpty == true
                          ? ListView.builder(
                              itemCount: blankList.length,
                              itemBuilder: (context, index) => Card(
                                color: Colors.grey[900],
                                child: ListTile(
                                  title: Text(
                                    "No music found",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: songs.length,
                              itemBuilder: (context, index) => Card(
                                color: Colors.grey[900],
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: songs[index]
                                                .albumArtwork ==
                                            null
                                        ? AssetImage('assets/disc.png')
                                        : FileImage(
                                            File(songs[index].albumArtwork)),
                                  ),
                                  title: Text(
                                    songs[index].title,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    songs[index].artist,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    currentIndex = index;
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MusicPlayer(
                                                changeTrack: changeTrack,
                                                songInfo: songs[currentIndex],
                                                key: key)));
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
