import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_demo/pages/bookmark_page/bookmark_page.dart';
import 'package:music_demo/pages/home_page/music_model.dart';
import 'package:music_demo/pages/home_page/music_bloc.dart';
import 'package:music_demo/pages/track_page/track_info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final musicBloc = MusicBloc();

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), ((timer) {
      musicBloc.eventSink.add(MusicAction.fetch);
    }));
    super.initState();
  }

  @override
  void dispose() {
    musicBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Jams'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BookMarkPage()));
              },
              icon: const Icon(Icons.bookmark))
        ],
      ),
      body: StreamBuilder<List<TrackList>>(
        stream: musicBloc.musicStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var music = snapshot.data![index];
                  return ListTile(
                    title: Text(music.track.trackName),
                    subtitle: Text(music.track.albumName),
                    leading: const Icon(Icons.music_note),
                    trailing: Text(music.track.artistName),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TrackInfoPage(trackId: music.track.trackId)));
                    },
                  );
                });
          } else if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('No Internet Connection'));
          }
        },
      ),
    );
  }
}
