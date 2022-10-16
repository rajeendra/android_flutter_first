import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android_flutter_first/album_model.dart' as model;

Future<List<model.Album>> fetchAlbum() async {
  List<model.Album>? result;

  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    List<model.Album> albums = [];
    try {
      List albumList = jsonDecode(response.body);
      albumList.forEach((element) {
        albums.add(model.Album.fromJson(element));
      });

    } catch (e) {
      print(e);
    }

    result = albums;
    return result;

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }

}
