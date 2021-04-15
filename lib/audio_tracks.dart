import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/music_player.dart';

class AudioTracks extends StatefulWidget {
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<AudioTracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  List<SongInfo> songs = [];
  int currentIndex = 0;

  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTracks();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

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

  void searchTracks(query) async {
    List <SongInfo> allTracks = await audioQuery.getSongs();
    List <SongInfo> searched = await audioQuery.searchSongs(query: query);
    if(query.isNotEmpty && searched.isNotEmpty) {
      setState(() {
        songs.clear();
        songs.addAll(searched);
        print(songs);
        searched.clear();
        return;
      });
    }
    if (query.isEmpty) {
      setState(() {
        songs.clear();
        songs.addAll(allTracks);
        print(songs);
        return;
      });
    }

  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        leading: Icon(Icons.music_note, color: Colors.blueAccent),
        title: Text('Music App',
            style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,

      ),
      body: songs.isEmpty == true
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/tuzki.gif'),
                Text(
                  "No Music Found",
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
          :
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: (value) {
                searchTracks(value);
              },
              controller: editingController,
              decoration: InputDecoration(
                labelText: "Search Audio Title",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                )
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: songs.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: songs[index].albumArtwork == null
                      ? AssetImage('assets/disc.png')
                      : FileImage(File(songs[index].albumArtwork)),
                ),
                title: Text(songs[index].title),
                subtitle: Text(songs[index].artist),
                onTap: () {
                  currentIndex = index;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MusicPlayer(
                          changeTrack: changeTrack,
                          songInfo: songs[currentIndex],
                          key: key)));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
