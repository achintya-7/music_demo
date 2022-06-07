// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:ffi';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:music_demo/pages/track_page/lyrics_bloc.dart';
import 'package:music_demo/pages/track_page/lyrics_model.dart';
import 'package:music_demo/pages/track_page/track_bloc.dart';
import 'package:music_demo/pages/track_page/track_model.dart';

class TrackInfoPage extends StatefulWidget {
  final int trackId;
  const TrackInfoPage({
    Key? key,
    required this.trackId,
  }) : super(key: key);

  @override
  State<TrackInfoPage> createState() => _TrackInfoPageState();
}

class _TrackInfoPageState extends State<TrackInfoPage> {
  late final trackBloc;
  late final lyricBloc;
  late Timer timer;

  @override
  void initState() {
    trackBloc = TrackBloc(widget.trackId);
    lyricBloc = LyricBloc(widget.trackId);
    Timer.periodic(const Duration(seconds: 1), ((timer) {
      trackBloc.eventSink.add(TrackAction.fetch);
      lyricBloc.eventSink.add(LyricAction.fetch);
    }));
    super.initState();
  }

  setValue(String trackName, String trackId) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    try {
      ref.setStringList(trackId, [trackId, trackName]);
      Fluttertoast.showToast(msg: 'Track saved!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong : $e');
    }
  }

  @override
  void dispose() {
    timer.cancel();
    trackBloc.dispose();
    lyricBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Info Page'),
      ),
      body: StreamBuilder<Track>(
        stream: trackBloc.trackStream,
        builder: (context, snapshot1) {
          return StreamBuilder<Lyrics>(
            stream: lyricBloc.lyricStream,
            builder: (context, snapshot2) {
              if (snapshot1.hasData && snapshot2.hasData) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text(snapshot1.data!.trackName + '\n',
                          style: const TextStyle(fontSize: 20)),
                      Text('Album : ' + snapshot1.data!.albumName),
                      Text('Artists : ' + snapshot1.data!.artistName),
                      Text(
                        '\n Lyrics \n \n \n ' + snapshot2.data!.lyricsBody,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            setValue(snapshot1.data!.trackName,
                                widget.trackId.toString());
                          },
                          child: const Text('BookMark')),
                      const Spacer(),
                    ],
                  ),
                );
              } else if (snapshot1.connectionState != ConnectionState.active ||
                  snapshot2.connectionState != ConnectionState.active) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Center(child: Text('No Internet Connection'));
              }
            },
          );
        },
      ),
    );
  }
}
