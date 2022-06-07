// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:music_demo/pages/track_page/track_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookMarkPage extends StatefulWidget {
  const BookMarkPage({Key? key}) : super(key: key);

  @override
  State<BookMarkPage> createState() => _BookMarkPageState();
}

class _BookMarkPageState extends State<BookMarkPage> {
  List trackKeys = [];
  List items = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List> getValue() async {
    items.clear();
    trackKeys.clear();

    SharedPreferences ref = await SharedPreferences.getInstance();
    if (ref.getKeys().isNotEmpty) {
      trackKeys = ref.getKeys().toSet().toList();
      for (var i = 0; i < trackKeys.length; i++) {
        items.add(ref.getStringList(trackKeys[i]));
      }
      // final List<String>? items = ref.getStringList(trackKeys);
      return items;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bookmark Tracks'),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: getValue(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    if (items.isEmpty) {
                      return const Text('No BookMarked Tracks');
                    }
                    var favTracks = snapshot.data![index];
                    return ListTile(
                      title: Text('Track Name : ' + favTracks[1]),
                      subtitle: Text('TrackId : ' + favTracks[0]),
                      onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TrackInfoPage(
                                      trackId: int.parse(favTracks[0]))));
                        }
                    );
                  });
            }

            return const Text('No Tracks BookMarked');
          },
        ));
  }
}
