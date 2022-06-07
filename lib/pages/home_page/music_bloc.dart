import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:music_demo/pages/home_page/music_model.dart';

enum MusicAction { fetch }

class MusicBloc {
  final _stateStreamController = StreamController<List<TrackList>>();
  StreamSink<List<TrackList>> get _musicSink => _stateStreamController.sink;
  Stream<List<TrackList>> get musicStream => _stateStreamController.stream;

  final _eventStreamController = StreamController<MusicAction>();
  StreamSink<MusicAction> get eventSink => _eventStreamController.sink;
  Stream<MusicAction> get _eventStream => _eventStreamController.stream;

  MusicBloc() {
    _eventStream.listen((event) async {
      if (event == MusicAction.fetch) {
        try {
          var music = await getMusic();
          _musicSink.add(music.message.body.trackList);
        } catch (e) {
          _musicSink.addError('Something went wrong $e');
        }
      }
    });
  }


  Future<MusicModel> getMusic() async {
    var musicModel;

    try {
      var url = Uri.parse(
          'https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        musicModel = musicModelFromJson(jsonString);
      } 
    } catch (e) {
      return musicModel;
    }

    return musicModel;
  }

  void dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }
}
