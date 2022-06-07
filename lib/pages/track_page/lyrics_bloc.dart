import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:music_demo/pages/track_page/lyrics_model.dart';

enum LyricAction { fetch }

String trackIdInfo = '';

class LyricBloc {
  final _stateStreamController = StreamController<Lyrics>();
  StreamSink<Lyrics> get _lyricSink => _stateStreamController.sink;
  Stream<Lyrics> get lyricStream => _stateStreamController.stream;

  final _eventStreamController = StreamController<LyricAction>();
  StreamSink<LyricAction> get eventSink => _eventStreamController.sink;
  Stream<LyricAction> get _eventStream => _eventStreamController.stream;

  LyricBloc(int trackId) {
    trackIdInfo = trackId.toString();
    _eventStream.listen((event) async {
      if (event == LyricAction.fetch) {
        try {
          var lyric = await getTrack(trackIdInfo);
          _lyricSink.add(lyric.message.body.lyrics);
        } catch (e) {
          _lyricSink.addError('Something went wrong $e');
        }
      }
    });
  }

  Future<LyricsModel> getTrack(String trackId) async {
    var lyricModel;

    try {
      var url = Uri.parse(
          'https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=$trackIdInfo&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        lyricModel = lyricsModelFromJson(jsonString);
      }
    } catch (e) {
      print('something went wrong' + e.toString());
    }

    return lyricModel;
  }

  void dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }
}
