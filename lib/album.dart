import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// App album
import 'package:android_flutter_first/album_service.dart' as album;
import 'package:android_flutter_first/album_model.dart' as model;

class Album extends StatefulWidget {
  Album({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Album> createState() => _AlbumStateState();
}

class _AlbumStateState extends State<Album>{

  late List<model.Album> albums;

  @override
  void initState() {
    albums=[];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return _buildAsyncFutureHttp();
  }

  Widget _buildHeader(String hd) => DefaultTextStyle(
    child: Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.blue,
      alignment: Alignment.center,
      child: Text(hd),
    ),
    style: TextStyle(color: Colors.white),
  );

  ///////////////////////////////////////////////////
  //  Album app | Async http service call
  ///////////////////////////////////////////////////
  Widget _buildAsyncFutureHttp() {
    Widget result;
    if(albums.length==0){
      result = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader('Async with Future<T> and HTTP'),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            alignment: Alignment.center,
            child: Row(mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      onPrimary: Colors.white,
                      minimumSize: const Size(100, 40),
                    ),
                    onPressed: () {
                      _httpGetAlbums();
                    },
                    child: const Text(
                      'Fetch',
                      //style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      onPrimary: Colors.black,
                      minimumSize: const Size(100, 40),
                    ),
                    onPressed: () {
                      _clearAlbums();
                    },
                    child: const Text(
                      'Clear',
                      //style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                ]),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: <Widget>[
                      Text('Empty albums',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          //fontStyle: FontStyle.italic,
                          fontSize: 30.0,
                        ),
                      ),
                      Icon(
                          Icons.album,
                          size: 80.0,
                          color: Colors.blue
                      ),
                      Text('Press fetch to get the albums',
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),
        ],
      );
    }else{
      result = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader('Async with Future<T> and HTTP'),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            alignment: Alignment.center,
            child: Row( mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      onPrimary: Colors.white,
                      minimumSize: const Size(100, 40),
                    ),
                    onPressed: () {
                      _httpGetAlbums();
                    },
                    child: const Text(
                      'Fetch',
                      //style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      onPrimary: Colors.black,
                      minimumSize: const Size(100, 40),
                    ),
                    onPressed: () { _clearAlbums(); },
                    child: const Text(
                      'Clear',
                      //style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                ]),
          ),

          DefaultTextStyle(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              alignment: Alignment.center,
              child: Text('Press buttons to do http and clear'),
            ),
            style: TextStyle(color: Colors.blue),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              // child: Text('Bottom', textAlign: TextAlign.center),

              child: ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _tileAlum('${albums[index].title}' , '${albums[index].id}', Icons.album_outlined );
                  }
              ),
            ),
          ),
        ],
      );
    }
    return result;
  }

  ListTile _tileAlum(String title, String subtitle, IconData icon) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),

      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            //IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton(onPressed:  () {}, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  void _httpGetAlbums() async{
    albums = await album.fetchAlbum();
    setState(() {
    });
  }

  void _clearAlbums() async{
    albums = [];
    setState(() {
    });
  }

}