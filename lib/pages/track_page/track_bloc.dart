import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:music_demo/pages/track_page/track_model.dart';

enum TrackAction { fetch }

String trackIdInfo = '';

class TrackBloc {
  final _stateStreamController = StreamController<Track>();
  StreamSink<Track> get _trackSink => _stateStreamController.sink;
  Stream<Track> get trackStream => _stateStreamController.stream;

  final _eventStreamController = StreamController<TrackAction>();
  StreamSink<TrackAction> get eventSink => _eventStreamController.sink;
  Stream<TrackAction> get _eventStream => _eventStreamController.stream;

  TrackBloc(int trackId) {
    trackIdInfo = trackId.toString();
    _eventStream.listen((event) async {
      if (event == TrackAction.fetch) {
        try {
          var track = await getTrack(trackIdInfo);
          _trackSink.add(track.message.body.track);
        } catch (e) {
          _trackSink.addError('Something went wrong $e');
        }
      }
    });
  }

  Future<TrackModel> getTrack(String trackId) async {
    var trackModel;

    try {
      var url = Uri.parse(
          'https://api.musixmatch.com/ws/1.1/track.get?track_id=$trackIdInfo&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        trackModel = trackModelFromJson(jsonString);
      }
    } catch (e) {
      print('something went wrong' + e.toString());
    }

    return trackModel;
  }

  void dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }
}

