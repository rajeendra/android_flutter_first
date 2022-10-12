import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:android_flutter_first/main.dart' as main;

// Custom widgets
import 'package:android_flutter_first/custom_widget_icon_favorite.dart' as cwIcon;
import 'package:android_flutter_first/custom_widget_button.dart' as cwBtn;
// Test
import 'package:android_flutter_first/test._dart.dart' as test;
// App
import 'package:android_flutter_first/app_util.dart' as util;
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/app_constants.dart' as constants;
// App person
import 'package:android_flutter_first/app_person_ui.dart' as personUI;
import 'package:android_flutter_first/app_person_model.dart' as data;
// App contact
import 'package:android_flutter_first/app_contact.dart' as contact;
import 'package:android_flutter_first/app_contact_model.dart' as modelContact;
// App album
import 'package:android_flutter_first/app_album.dart' as album;
import 'package:android_flutter_first/app_album_model.dart' as modelAlbum;
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

  _HomePageState(){
    _app_contact_init();
  }

  // Test data
  final fNms = List<String>.generate(30, (i) => "Fname$i Lname$i");
  final fAds = List<String>.generate(30, (i) => "10 Street$i City$i");

  //List<service.Album> albums=[];
  List<data.Person> persons=[];
  int _counter = 0;
  int selectedState = constants.STATE_DEFAULT;

  // final nameTxtController = TextEditingController();
  // final addressTxtController = TextEditingController();

  late AnimationController controller;
  late ScrollController _scrollController;
  double _offset = 0.0;

  late CameraController cameraController;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: false);

    _scrollController = ScrollController()
    ..addListener(() {
      // when ListView gets scroll _offset will update
      _offset = _scrollController.offset;
      //print("offset = ${_scrollController.offset}");
    });

    cameraController = CameraController( main.cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controller.dispose();
    _scrollController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // void _addItemToList() {
  //   setState(() {
  //     if (nameTxtController.text.isNotEmpty & addressTxtController.text.isNotEmpty) {
  //     //persons.insert(persons.length , Person(nameTxtController.text, addressTxtController.text)); // Adding to bottom
  //       persons.insert(0, data.Person(nameTxtController.text, addressTxtController.text)); // Adding to top
  //       nameTxtController.clear();
  //       addressTxtController.clear();
  //     }
  //   });
  // }

  void _addPersonToList(data.Person person) {
    setState(() {
      if (person.name.isNotEmpty & person.address.isNotEmpty) {
        persons.insert(0, person);
      }
    });
  }

  void _onPressedFloatingActionButton() {
    if(selectedState==constants.STATE_DEFAULT){
      _incrementCounter();
    } else if(selectedState==constants.STATE_APP_PERSON){
      _addOrEditPerson(context,data.Person('',''),data.Config(data.Config.METHOD_ADD));
    } else if(selectedState==constants.STATE_LAYOUT_FULL_STRETCHED){
      test.mainTest(context);
    } else if (selectedState == constants.STATE_APP_CONTACT) {
      // At _app_contact
      selectedContact = _app_contact_new_contact();
      _app_contact_one_show(-1);
    } else if(selectedState==constants.STATE_APP_CONTACT_ONE){
      // At _app_contact_one
      _app_contact_number_show(-1);
    } else if(selectedState==constants.STATE_SHARE_CONTENT_CAMERA){
      _camera_take_picture();
    } else if(selectedState==constants.STATE_LAYOUT_SILVERS){
      setState(() {
        topIntSilvers.add(-topIntSilvers.length - 1);
        bottomIntSilvers.add(bottomIntSilvers.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: _buildSelectedBody()
      ,
      drawer: _drawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressedFloatingActionButton,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Drawer _drawer(){
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.rectangle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [
                    //0.1,
                    //0.4,
                    0.5,
                    0.8,
                  ],
                  colors: [
                    //Colors.yellow,
                    //Colors.red,
                    Colors.green,
                    Colors.blue,
                  ],
                )

            ),
            child: Text('Flatter layout selector'),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Layout | Grid'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              // Then close the drawer
              setState(() {
                selectedState = constants.STATE_LAYOUT_GRID;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Person | List view, Dynamically grow'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_APP_PERSON;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Layout | Widgets fully stretched'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_LAYOUT_FULL_STRETCHED;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Album | Async http call'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_APP_ALBUM;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Contact | configuration'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_APP_CONTACT_CONFIGURATION;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Contact'),
            onTap: () {
              //setState(() {
              // setState() trigger after fetch the contacts
              selectedState = constants.STATE_APP_CONTACT;
              //});
              _mongoAtlas_contacts();
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Share content'),
            onTap: () {
              setState(() {
              selectedState = constants.STATE_SHARE_CONTENT;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Layout | Scrollable form'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_LAYOUT_SCROLLABLE_FORM;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Layout | Silvers'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_LAYOUT_SILVERS;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Silvers - Multiple pages'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_LAYOUT_SILVERS_PAGES;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Number incrementer | ..'),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_DEFAULT;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildSelectedBody() {

    if (selectedState == constants.STATE_APP_CONTACT_NUMBER) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    if (selectedState == constants.STATE_LAYOUT_GRID) {
      return _buildGridUI();
    }
    else if (selectedState == constants.STATE_APP_PERSON) {
      return _buildIncrementalList();
    }
    else if (selectedState == constants.STATE_LAYOUT_FULL_STRETCHED) {
      return _buildWidgetsFullyStretched();
    }
    else if (selectedState == constants.STATE_APP_ALBUM) {
      return _buildAsyncFutureHttp();
    }
    else if (selectedState == constants.STATE_APP_CONTACT_CONFIGURATION) {
      return _app_contact_config();
    }
    else if (selectedState == constants.STATE_APP_CONTACT) {
      return _app_contact();
    }
    else if (selectedState == constants.STATE_APP_CONTACT_ONE) {
      return _app_contact_one();
    }
    else if (selectedState == constants.STATE_APP_CONTACT_NUMBER) {
      return _app_contact_number_silver();
    }
    else if (selectedState == constants.STATE_APP_CONTACT_SPINNER) {
      return _app_contact_spinner();
    }
    else if (selectedState == constants.STATE_SHARE_CONTENT) {
      return _buildShareResources();
    }
    else if (selectedState == constants.STATE_SHARE_CONTENT_CAMERA) {
      return _build_camera(context);
    }
    else if (selectedState == constants.STATE_LAYOUT_SCROLLABLE_FORM) {
      _assemble_scroll_view();
      return _build_scroll_view();
    }
    else if (selectedState == constants.STATE_LAYOUT_SILVERS) {
      return _build_silvers();
    }
    else if (selectedState == constants.STATE_LAYOUT_SILVERS_PAGES) {
      return _build_silvers_multiple_pages();
    }
    else if (selectedState == constants.STATE_ERROR_UNEXPECTED) {
      return _app_Oops();
    }
    else {
      return _buildNumberIncrementer();
    }
  }

  Widget _build_camera(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(cameraController),
    );
  }

  void _camera_take_picture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      //await _initializeControllerFuture;

      // Attempt to take a picture and then get the location
      // where the image file is saved.
      final image = await  cameraController.takePicture();
      util.showSuccessSnackBar(context, 'Picture has been taken');
    } catch (e) {
      util.showFailureSnackBar(context, 'Failed to take the picture');
      // If an error occurs, log the error to the console.
      print(e);
    }

  }

  Widget _buildWidgetsFullyStretched() => Scaffold(
        backgroundColor: Color(0xFF222222),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Expanded row has Expanded children inside a column with CrossAxisAlignment.stretch
            _buildHeader('Widgets fully stretched'),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    // Center is NON Expandable
                    // NON expanded Container in Center
                    // child: Center(
                    //   child: Container(
                    //     color: Colors.red,
                    //     child: Text('Left', textAlign: TextAlign.center),
                    //   ),
                    // ),

                    // Container is Expandable
                    // Center in Expanded Container
                    child: Container(
                      color: Colors.white24,
                      child: Center(
                        child: Text('Left', textAlign: TextAlign.center),
                      )
                    ),

                    // child: Container(
                    //   color: Colors.red,
                    //   child: Text('Left', textAlign: TextAlign.center),
                    // ),

                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white38,
                      child: Text('Right', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),

            // Expanded Container after a Row
            Expanded(
              child: Container(
                color: Colors.white,
                // child: Text('Bottom', textAlign: TextAlign.center),

                child: Center(
                  child: Text('Bottom', textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      );

  // 8. Scrollable data entry screen
  final ScrollController _firstController = ScrollController();

  Widget _build_scroll_view() =>
      LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Row(
              children: <Widget>[
                // SizedBox(
                //     width: constraints.maxWidth / 2,
                //     // When using the PrimaryScrollController and a Scrollbar
                //     // together, only one ScrollPosition can be attached to the
                //     // PrimaryScrollController at a time. Providing a
                //     // unique scroll controller to this scroll view prevents it
                //     // from attaching to the PrimaryScrollController.
                //     child: Scrollbar(
                //       //thumbVisibility: true,
                //       controller: _firstController,
                //       child: ListView.builder(
                //           controller: _firstController,
                //           itemCount: 100,
                //           itemBuilder: (BuildContext context, int index) {
                //             return Padding(
                //               padding: const EdgeInsets.all(8.0),
                //               child: Text('Scrollable 1 : Index $index'),
                //             );
                //           }),
                //     )),
                SizedBox(
                    //width: constraints.maxWidth / 2,
                    width: constraints.maxWidth,
                    // This vertical scroll view has primary set to true, so it is
                    // using the PrimaryScrollController. On mobile platforms, the
                    // PrimaryScrollController automatically attaches to vertical
                    // ScrollViews, unlike on Desktop platforms, where the primary
                    // parameter is required.
                    child: Scrollbar(
                      //thumbVisibility: true,
                      child: ListView.builder(
                          primary: true,
                          itemCount: cns.length,
                          itemBuilder: (BuildContext context, int index) {
                            //return _container(index);
                            return cns[index];
                            // return Container(
                            //     height: 50,
                            //     color: index.isEven
                            //         ? Colors.white
                            //         : Colors.lightBlue,
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       //child: Text('Scrollable 2 : Index $index'),
                            //       child: TextField(
                            //         controller: txtFnameController,
                            //         obscureText: false,
                            //         decoration: InputDecoration(
                            //           border: OutlineInputBorder(),
                            //           labelText: 'First name',
                            //         ),
                            //       ),
                            //     ));
                          }),
                    )),
              ],
            );
          });

  List<Widget> cns = [];
  void _assemble_scroll_view(){
    cns = [];
    cns.add(_container(1));
    cns.add(_container(2));
    cns.add(_buttonr());

    cns.add(_container(2));
    cns.add(_container(1));
    cns.add(_buttonr());

    cns.add(_container(2));
    cns.add(_container(1));
    cns.add(_buttonr());

    cns.add(_container(2));
    cns.add(_container(1));
    cns.add(_buttonr());

    cns.add(_container(2));
    cns.add(_container(1));
    cns.add(_buttonr());

    cns.add(_container(2));
    cns.add(_container(1));
    cns.add(_buttonr());

    cns.add(_container(2));
    cns.add(_container(1));
    cns.add(_buttonr());
  }

  Widget _container(int index) {
    return Container(
        height: 50,
        color: index.isEven ?
        Colors.white
            : Colors.lightBlue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          //child: Text('Scrollable 2 : Index $index'),
          child: TextField(
            controller: txtFnameController,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'First name',
            ),
          ),
        ));
  }

  Widget _buttonr() {
    return Container(
        height: 75,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          //child: Text('Scrollable 2 : Index $index'),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
              minimumSize: const Size(100, 40),
            ),
            onPressed: () {  },
            child: const Text(
              'Take Photo',
              //style: TextStyle(fontSize: 24),
            ),
          ),
        ));
  }

  // 9. Silvers - custom scroll view - Adding silvers from top and bottom
  List<int> topIntSilvers = <int>[];
  List<int> bottomIntSilvers = <int>[0];
  Widget _build_silvers(){
    //const Key centerKey = ValueKey<String>('bottom-sliver-list');
    return CustomScrollView(
      //center: centerKey,
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Container(
                // alignment: Alignment.center,
                // color: Colors.blue[200 + topIntSilvers[index] % 4 * 100],
                // height: 100 + topIntSilvers[index] % 4 * 20.0,
                // child: Text('Item: ${topIntSilvers[index]}'),

                alignment: Alignment.center,
                color: Colors.blue[200 + topIntSilvers[index] % 4 * 100],
                height: 100.0,
                child: Text('Item: ${topIntSilvers[index]}'),

              );
            },
            childCount: topIntSilvers.length,
          ),
        ),
        SliverList(
          //key: centerKey,
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Container(
                // alignment: Alignment.center,
                // color: Colors.blue[200 + bottomIntSilvers[index] % 4 * 100],
                // height: 100 + bottomIntSilvers[index] % 4 * 20.0,
                // child: Text('Item: ${bottomIntSilvers[index]}'),

                alignment: Alignment.center,
                color:  Colors.blue[200 + bottomIntSilvers[index] % 4 * 100],
                height: 100,
                child: Text('Item: ${bottomIntSilvers[index]}'),

                //height: 700,
                //child: _app_Oops(),


              );
            },
            childCount: bottomIntSilvers.length,
          ),
        ),
      ],
    );
  }

  // 91. Silvers - custom scroll view - Multiple scrollable pages
  List<Widget> silverPages = <Widget>[];
  Widget _build_silvers_multiple_pages(){
    silverPages = [];
    silverPages.add(_buildAsyncFutureHttp());
    silverPages.add(_app_Oops());
    silverPages.add(_buildAsyncFutureHttp());
    silverPages.add(_app_Oops());

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Container(
                // alignment: Alignment.center,
                // color: Colors.blue[200 + bottomIntSilvers[index] % 4 * 100],
                // height: 100 + bottomIntSilvers[index] % 4 * 20.0,
                // child: Text('Item: ${bottomIntSilvers[index]}'),

                color:  Colors.white,
                height: 500,
                child: silverPages[index],

              );
            },
            childCount: silverPages.length,
          ),
        ),
      ],
    );
  }

  // 1. Number Incrementer
  Widget _buildNumberIncrementer() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header not expanded so it goes on top of the column
          _buildHeader('Number Incrementer'),

          // Expanded Container take rest of all the vertical space
          // children placed vertically center as the below column MainAxisAlignment set to center
          Expanded(
            child: Container(
              color: Colors.black12,

              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You have clicked the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    )

                  ]
              ),
            ),
          ),
        ],
      );

  ///////////////////////////////////////////////////
  //  Person app | incremental list
  ///////////////////////////////////////////////////

  Widget _buildIncrementalList() {
    return
      Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildHeader('List view - Dynamically growing'),
              // DefaultTextStyle(
              //   child: Container(
              //             padding: const EdgeInsets.all(8.0),
              //             color: Colors.blue,
              //             alignment: Alignment.center,
              //             child: Text("Header"),
              //          ),
              //   style: TextStyle(color: Colors.white),
              // ),
              Text(
                'Press plus button to add a new person:',
              ),
              // TextField(
              //   controller: nameTxtController,
              //   obscureText: false,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Name',
              //   ),
              // ),
              // TextField(
              //   controller: addressTxtController,
              //   obscureText: false,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Address',
              //   ),
              // ),

              // TextButton(
              //   style: cw.flatButtonStyle,
              //   onPressed: () { },
              //   child: Text('Looks like a FlatButton'),
              // ),

              // RaisedButton(
              //   color: true ? Colors.green : Colors.red,
              //   onPressed: () {
              //     setState(() {
              //       //_list[i] = !_list[i];
              //     });
              //   },
              //   child: Text("Button"),
              // ),

              // const SizedBox(
              //   height: 5,
              // ),

              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.green,
              //     onPrimary: Colors.white,
              //     //elevation: 3,
              //     minimumSize: const Size.fromHeight(50), // NEW
              //     //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
              //     //minimumSize: const Size(100,40),
              //   ),
              //   onPressed: () {_addItemToList();},
              //   child: const Text(
              //     'Submit',
              //     //style: TextStyle(fontSize: 24),
              //   ),
              // ),

              Expanded(child:
                  ListView.builder(
                    //itemCount: names.length,
                    itemCount: persons.length,
                    itemBuilder: (BuildContext context, int index) {
                      //return _tilePerson('${names[index]}' , '${names[index]}', Icons.restaurant );
                      return _tilePerson(index,'${persons[index].name }' , '${persons[index].address}', Icons.restaurant );
                    }
                  ),
              )
            ]
        ),
      );
  }

  ListTile _tilePerson(int index, String title, String subtitle, IconData icon) {
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
            IconButton(onPressed:  () { _addOrEditPerson(context,persons[index],data.Config(data.Config.METHOD_EDIT,intValue:index)); }, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () { _deletePerson(index); }, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => cw.DetailScreen(todo: persons[index]),
      //     ),
      //   );
      // },
    );
  }

  void _XaddOrEditPerson(BuildContext context, data.Person person, data.Config config){
    // Switching to another scaffold with same <build context> with MaterialPageRoute
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => personUI.DetailScreen(person: person, config: config,),
      ),
    );
  }

  // Navigate to person edit screen and return back with the data holding in <Result> object
  // Show SnackBar with a message
  Future<void> _addOrEditPerson(BuildContext context, data.Person person, data.Config config) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final data.Result result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => personUI.DetailScreen(person: person, config: config,) ),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    String name = result.person.name;

    if(result.config.method==data.Config.METHOD_ADD){
      persons.insert(0, result.person);
    } else {
      persons[result.config.intValue]=result.person;
    }

    setState(() {
      // update UI
    });


    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    util.showSuccessSnackBar(context, ' Person $name successfully saved. ');

    // ScaffoldMessenger.of(context)
    //   ..removeCurrentSnackBar()
    //   //..showSnackBar(SnackBar(content: Text(' Person $name successfully saved. ')));
    //   ..showSnackBar(_getSnackBar(' Person $name successfully saved. '));
  }

  // Delete with alert dialog conformation
  Future<void> _deletePerson(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete '),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Want to delete ?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          // actions: <Widget>[
          //   TextButton(
          //     child: const Text('Approve'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
          actions: <Widget>[
            TextButton(
              //onPressed: () => Navigator.pop(context, 'Cancelx'),
              onPressed: () { Navigator.pop(context, 'Cancel'); },
              child: const Text('Cancel'),
            ),
            TextButton(
              //onPressed: () => Navigator.pop(context, 'OKx'),
              onPressed: () {
                Navigator.pop(context, 'OK');
                String name = persons.elementAt(index).name;
                setState(() {
                  persons.removeAt(index);
                });
                util.showSuccessSnackBar(context, ' Person $name successfully removed. ');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  ///////////////////////////////////////////////////
  //  Share resources
  ///////////////////////////////////////////////////

  Widget _buildShareResources() => Scaffold(
    //backgroundColor: Color(0xFF222222),
    backgroundColor: Colors.white,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildHeader('Share resources'),
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
                    setState(() {
                      selectedState = constants.STATE_SHARE_CONTENT_CAMERA;
                    });
                  },
                  child: const Text(
                    'Camera',
                    //style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: () { _email(); },
                  child: const Text(
                    'eMail',
                    //style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: () { _sms(); },
                  child: const Text(
                    'sms',
                    //style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 10),
              ]),
        ),
        //Image.file(),
        DefaultTextStyle(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            alignment: Alignment.center,
            child: Text('Press buttons to share information'),
          ),
          style: TextStyle(color: Colors.blue),
        ),
        cwIcon.FavoriteWidget(),
        cwBtn.ExElevatedButton(
            onPressed: () {
              util.showSuccessSnackBar(context, 'ExElevatedButton pressed');
            },
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            // child: Text('Bottom', textAlign: TextAlign.center),
          ),
        ),
      ],
    ),
  );

  void _email(){
    util.sendEmail(
        toMail: 'some.email@gmail.com',
        subject: 'This is the subject',
        body: 'This is the content of the email \n\n //Sender '
    );
  }

  void _sms(){
    util.sendSMS(
        phoneNumber: '0778987765',
        body: 'This is the text message'
    );
  }

  ///////////////////////////////////////////////////
  //  Album app | Async http service call
  ///////////////////////////////////////////////////
  List<modelAlbum.Album> albums=[];
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
                    return _tileAlum('${albums[index].title }' , '${albums[index].id}', Icons.album_outlined );
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

  ///////////////////////////////////////////////////
  //  Contacts app
  ///////////////////////////////////////////////////
  List<modelContact.Contact> contacts = [];
  List<modelContact.Contact> contactsCopy = [];
  modelContact.Contact? selectedContact;
  modelContact.Number? selectedNumber;
  model.AppConfiguration appContactConfiguration=model.AppConfiguration();

  final txtUserController  = TextEditingController();
  final txtPassController = TextEditingController();
  final txtSearchController = TextEditingController();

  final txtFnameController = TextEditingController();
  final txtLnameController = TextEditingController();
  final txtLCpseController = TextEditingController();
  bool activeContact = true;

  final txtNumberController = TextEditingController();
  bool isMobile = true;
  bool isPersonal = true;

  Widget _app_Oops() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader('Contacts'),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: <Widget>[
                    Text('Oops!!!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        //fontStyle: FontStyle.italic,
                        fontSize: 30.0,
                      ),
                    ),
                    Icon(
                        Icons.error,
                        size: 80.0,
                        color: Colors.red
                    ),
                    Text('Something went wrong',
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
  }

  void _app_contact_init(){
    _app_contact_getCredentials();
  }

  void _app_contact_getCredentials() async {
    appContactConfiguration = await util.AppUtil.getAppConfig();
    txtUserController.text = appContactConfiguration.user ?? '';
    txtPassController.text = appContactConfiguration.password ?? '';
  }

  Widget _app_contact_config() {
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      body: Column(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader('Contacts | Configuration'),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            alignment: Alignment.center,
            child:
            Column(
                children: <Widget>[
                  Text(
                    "You can save your provider's credentials here",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: txtUserController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: txtPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                ]
            ),

          ),

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
                      _app_contact_saveCredentials();
                    },
                    child: const Text(
                      'Save',
                      //style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     primary: Colors.grey,
                  //     onPrimary: Colors.black,
                  //     minimumSize: const Size(100, 40),
                  //   ),
                  //   onPressed: () { _clearAlbums(); },
                  //   child: const Text(
                  //     'Clear',
                  //     //style: TextStyle(fontSize: 24),
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                ]),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _app_contact_saveCredentials() async{
    if ((txtUserController.text.isEmpty ?? true) ||
        (txtPassController.text.isEmpty ?? true)) {
      return;
    }

    model.AppConfiguration appConfiguration = model.AppConfiguration(
      user: txtUserController.text, password: txtPassController.text
    );

    try {
      await util.AppUtil.saveAppConfig(appConfiguration);
      util.showSuccessSnackBar(context, 'Your credential details have been saved');
    } catch (e) {
      print(e);
    }
  }

  void _mongoAtlas_contacts() async{
    try {
      _app_contact_spinner_show('Loading...');
      contacts = await contact.findAllContacts();
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_APP_CONTACT;
      });
      String count = contacts.length.toString();
      util.showSuccessSnackBar(context, 'Success, $count contacts fetched');

    } catch (e) {
      util.showFailureSnackBar(context, 'Oh, Something has gone wrong');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _mongoAtlas_contact_save(modelContact.Contact oneContact) async{
    try {
      _app_contact_spinner_show('Saving...');
      await contact.saveContact(oneContact);
      contacts = await contact.findAllContacts();
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_APP_CONTACT_ONE;
      });
      util.showSuccessSnackBar(context, 'Success, Save done.');

    } catch (e) {
      util.showFailureSnackBar(context, 'Oops! Save attempt failed.');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _mongoAtlas_contact_delete(String _id) async{
    try {
      _app_contact_spinner_show('Deleting...');
      await contact.deleteContact(_id);
      contacts = await contact.findAllContacts();
      contactsCopy = contacts.toList();
      setState(() {
        selectedState = constants.STATE_APP_CONTACT;
      });
      util.showSuccessSnackBar(context, 'Success, Delete done.');

    } catch (e) {
      util.showFailureSnackBar(context, 'Oops! Delete attempt failed.');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  Widget _app_contact() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader('Contacts'),
        Container(
          color: Colors.white,
          child: Column(children: <Widget>[
            const SizedBox(
              height: 5,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // const SizedBox(
                  //   width: 5,
                  // ),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Increase volume by 10',
                    onPressed: () {_app_contact_filter_show();},
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      // child: Text('Bottom', textAlign: TextAlign.center),

                      child: TextField(
                        controller: txtSearchController,
                        //onChanged: (value) => filterContacts(value),
                        obscureText: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Search',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ]),
          ]),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            // child: Text('Bottom', textAlign: TextAlign.center),

            child: ListView.builder(
                controller: _scrollController,
                itemCount: contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  return _app_contact_tile( index,
                      '${contacts[index].fname} ${contacts[index].lname}',
                      '${contacts[index].cpse}',
                      Icons.person);
                }),
          ),
        ),
      ],
    );
  }

  void _app_contact_show(){
    setState(() {
      selectedState = constants.STATE_APP_CONTACT;
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // After build() method this code inside will triggers
        _scrollDown();
      });

    });
  }

  // scrolling down with an animated effect
  // void _scrollDown() {
  //   _scrollController.animateTo(
  //     _scrollController.position.maxScrollExtent,
  //     duration: Duration(seconds: 2),
  //     curve: Curves.fastOutSlowIn,
  //   );
  // }
  void _scrollDown() {
    //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(_offset);
  }

  void _app_contact_spinner_show(String lm){
    setState(() {
      load_msg = lm;
      selectedState = constants.STATE_APP_CONTACT_SPINNER;
    });
  }

  String load_msg='';
  Widget _app_contact_spinner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader(load_msg),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                value: controller.value,
                semanticsLabel: 'Circular progress indicator',
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<modelContact.Contact> _app_contact_filter() {
    var value = txtSearchController.text;

    List<modelContact.Contact> filteredContacts = [];
    if (value.toString().trim().length > 0) {
      contactsCopy.forEach((element) {
        modelContact.Contact contact = element;
        if (contact.fname
                    .toString()
                    .toLowerCase()
                    .indexOf(value.toString().trim().toLowerCase()) >=
                0 ||
            contact.lname
                    .toString()
                    .toLowerCase()
                    .indexOf(value.toString().trim().toLowerCase()) >=
                0 ||
            contact.cpse
                    .toString()
                    .toLowerCase()
                    .indexOf(value.toString().trim().toLowerCase()) >=
                0) {
          filteredContacts.add(contact);
        }
      });
        contacts = filteredContacts.toList();
    } else {
      contacts = contactsCopy.toList();
    }
    return contacts;
  }

  void _app_contact_filter_show(){
    contacts = _app_contact_filter();
    setState(() {
    });
  }

  ListTile _app_contact_tile(index, String title, String subtitle, IconData icon) {
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
            IconButton(onPressed:  () { _app_contact_one_show(index); }, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () { _app_contact_delete_contact(index); }, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  Future<void> _app_contact_delete_contact(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Want to delete this contact?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              //onPressed: () => Navigator.pop(context, 'Cancelx'),
              onPressed: () { Navigator.pop(context, 'Cancel'); },
              child: const Text('Cancel'),
            ),
            TextButton(
              //onPressed: () => Navigator.pop(context, 'OKx'),
              onPressed: () {
                Navigator.pop(context, 'OK');
                String _id = contacts[index].id ?? '';
                _mongoAtlas_contact_delete(_id);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  modelContact.Contact _app_contact_new_contact(){
    List<modelContact.Number> numbers = [];
    modelContact.Contact contact = new modelContact.Contact(numbers: numbers );
    contact?.active = 'Y';
    return contact;
  }

  void _app_contact_one_populate(){
    txtFnameController.text = selectedContact?.fname ?? '';
    txtLnameController.text = selectedContact?.lname ?? '';
    txtLCpseController.text = selectedContact?.cpse ?? '';
    activeContact = (selectedContact?.active=='Y' ?? true);
  }

  void _app_contact_one_show(int index){
    selectedNumber = null; // initialize
    try {
      _offset = _scrollController?.offset ?? _offset;
    } catch (e) {
      print(e);
    }
    if(index>=0)
      //selectedContact = contacts[index];

      // Creating a new Contact object from edit to till save or cancel changes
      selectedContact = modelContact.Contact.fromJson(contacts[index].toJson(),source: 'local');

    setState(() {
        _app_contact_one_populate();
        selectedState = constants.STATE_APP_CONTACT_ONE;
    });
  }

  Widget _app_contact_one() {
    return Column(
      children: <Widget>[
        _buildHeader('Contacts > Contact'),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: txtFnameController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'First name',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: txtLnameController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Last name',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: txtLCpseController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Company, Service type, Place, Event or Else',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row( mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              const SizedBox(
                width: 5,
              ),
              const Text(
                'Active',
                style: TextStyle(fontSize: 18),
              ),
              // const SizedBox(
              //   width: 5,
              // ),
              Switch(
                // This bool value toggles the switch.
                value: activeContact,
                //inactiveThumbColor: Colors.red,
                //inactiveTrackColor : Colors.red,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    activeContact = value;
                  });
                },
              ),
              const SizedBox(
                width: 30,
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  _app_contact_one_save();
                  //_app_contact_saveContact();
                },
                child: const Text(
                  'Save',
                  //style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white54,
                  onPrimary: Colors.black38,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  _app_contact_show();
                },
                child: const Text(
                  'Cancel',
                  //style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 10),
            ]),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            // child: Text('Bottom', textAlign: TextAlign.center),

            child: ListView.builder(
                itemCount: selectedContact?.numbers.length,
                itemBuilder: (BuildContext context, int index) {
                  return _app_contact_one_tile_numbers(index, '${selectedContact?.numbers[index].number}' , Icons.phone );
                }
            ),
          ),

          // child: Container(
          //   color: Colors.white,
          // ),
        ),
      ],
    );
  }

  ListTile _app_contact_one_tile_numbers(int index, String number, IconData icon) {
    return ListTile(
      title: Text(number,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      //subtitle: Text(subtitle),

      // leading: Icon(
      //   icon,
      //   color: Colors.blue[500],
      //
      // ),
      leading: IconButton(
        icon: const Icon(Icons.phone),
        tooltip: 'Tap to dial',
        color: Colors.blue[500],
        onPressed: () {_app_contact_one_dialCall(number);},
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            //IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton(onPressed:  () {_app_contact_number_show(index);}, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {_app_contact_one_delete_number(index);}, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  Future<void> _app_contact_one_dialCall(String phoneNumber) async {
    util.dialCall(phoneNumber);
  }

  Future<void> _app_contact_one_delete_number(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete number'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Want to delete this number ?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              //onPressed: () => Navigator.pop(context, 'Cancelx'),
              onPressed: () { Navigator.pop(context, 'Cancel'); },
              child: const Text('Cancel'),
            ),
            TextButton(
              //onPressed: () => Navigator.pop(context, 'OKx'),
              onPressed: () {
                Navigator.pop(context, 'OK');
                String? name = selectedContact?.numbers[index].number;
                setState(() {
                  selectedContact?.numbers.removeAt(index);
                });
                util.showSuccessSnackBar(context, 'Number $name removed. ');
                _app_contact_one_show(-1);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _app_contact_one_save(){
    _app_contact_one_set();
     modelContact.Contact contact = selectedContact ?? _app_contact_new_contact();
     print('OK');
     _mongoAtlas_contact_save(contact);
  }

  void _app_contact_one_set(){
    // save controller values to models
    // before move to different screen
    selectedContact?.fname = txtFnameController.text;
    selectedContact?.lname = txtLnameController.text;
    selectedContact?.cpse = txtLCpseController.text;
    selectedContact?.active = (activeContact)?'Y':'N';
  }

  void _app_contact_number_populate(){
    _app_contact_one_set();
    txtNumberController.text = selectedNumber?.number ?? '';

    //1omx 1/0 : default/no, o/w : own/work, m/l mob/land, f/x : fax/no
    String type = selectedNumber?.type ?? '0omx';
    type = (type.length==4)? type : '0omx';
    isPersonal = !(type.substring(1,2)=='o' ?? false);
    isMobile = !(type.substring(2,3)=='m' ?? false);
  }

  void _app_contact_number_show(int index){
    if (index>=0) {
      // Edit number
      selectedNumber = selectedContact?.numbers[index];
      _app_contact_number_populate();
    }else{
      // Add number
      isPersonal = false;
      isMobile = false;
      txtNumberController.text = '';
      _app_contact_one_set();
    }
    setState(() {
      selectedState = constants.STATE_APP_CONTACT_NUMBER;
    });
  }

  // This is how a usual widget surrounded by a scrollable silver
  // Ex: conversion of the widget _app_contact_number() to scrollable silver _app_contact_number_silver(){
  Widget _app_contact_number_silver(){
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Container(
                color:  Colors.white,
                height: 700,
                child: _app_contact_number(),
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }

  Widget _app_contact_number() {
    return Column(
        children: <Widget>[
          _buildHeader('Contacts > Contact > Number'),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: txtNumberController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row( mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            minimumSize: const Size(100, 40),
                          ),
                          onPressed: () {
                            //_app_contact_saveContact();
                            __app_contact_number_set();
                          },
                          child: const Text(
                            'OK',
                            //style: TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white54,
                            onPrimary: Colors.black38,
                            minimumSize: const Size(100, 40),
                          ),
                          onPressed: () {
                            _app_contact_one_show(-1);
                          },
                          child: const Text(
                            'Cancel',
                            //style: TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 10),
                        //const SizedBox(width: 10),
                        //const SizedBox(width: 10),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Personal',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Switch(
                          // This bool value toggles the switch.
                          value: isPersonal,
                          //inactiveThumbColor: Colors.red,
                          //inactiveTrackColor : Colors.red,
                          activeColor: Colors.red,
                          onChanged: (bool value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              isPersonal = value;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Official',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          '     Mob',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Switch(
                          // This bool value toggles the switch.
                          value: isMobile,
                          //inactiveThumbColor: Colors.red,
                          //inactiveTrackColor : Colors.red,
                          activeColor: Colors.red,
                          onChanged: (bool value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              isMobile = value;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Fixed',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ]),
                ]
            ),
          ),
        ],
      );
  }

  void __app_contact_number_set(){
    if(txtNumberController.text.trim().length==0){
      return;
    }

    String type = __app_contact_number_type();

    if (selectedNumber!=null){
      selectedNumber?.number = txtNumberController.text;
      selectedNumber?.type = type;
    }else{
      selectedContact?.addNumber(
        modelContact.Number(
            number: txtNumberController.text,
            type: type,
        )
      );
    }
    _app_contact_one_show(-1);
  }

  String __app_contact_number_type(){
    //1omx 1/0 : default/no, o/w : own/work, m/l mob/land, f/x : fax/no
    String o = !isPersonal?'o':'w';
    String m = !isMobile ?'m':'p';
    String type ='0 $o $m x'.replaceAll(' ', '');
    return type;
  }

}

// 2. Page Header
Widget _buildHeader(String hd) => DefaultTextStyle(
  child: Container(
    padding: const EdgeInsets.all(8.0),
    color: Colors.blue,
    alignment: Alignment.center,
    child: Text(hd),
  ),
  style: TextStyle(color: Colors.white),
);

// 2. GridView Layout
Widget _buildGridUI() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildHeader('Grid'),
        Expanded(
          child: _buildGrid(),
        ),
      ],
    )
);

Widget _buildGrid() => GridView.extent(
    maxCrossAxisExtent: 150,
    padding: const EdgeInsets.all(4),
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    children: _buildGridTileList(30));

List<Widget> _buildGridTileList(int count) =>
    List.generate(count, (i) => Container(child: Image.asset('images/c.png')));

// 3. List of images in a row or column
Widget _buildImageCollection() =>
  Center(
    // child: Row(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Image.asset('images/a.jpg'),
          // Image.asset('images/b.png'),
          // Image.asset('images/c.png'),

          Expanded(
            child: Image.asset('images/large_01.jpg'),
          ),
          Expanded(
            flex: 2,
            child: Image.asset('images/large_02.jpg'),
          ),
          Expanded(
            child: Image.asset('images/large_03.jpg'),
          ),
        ],
      )
  );

// 4. Build list
Widget _buildList() {
  return ListView(
    children: [
      _tile('CineArts at the Empire', '85 W Portal Ave', Icons.theaters),
      _tile('The Castro Theater', '429 Castro St', Icons.theaters),
      _tile('Alamo Drafthouse Cinema', '2550 Mission St', Icons.theaters),
      _tile('Roxie Theater', '3117 16th St', Icons.theaters),
      _tile('United Artists Stonestown Twin', '501 Buckingham Way',
          Icons.theaters),
      _tile('AMC Metreon 16', '135 4th St #3000', Icons.theaters),
      const Divider(),
      _tile('K\'s Kitchen', '757 Monterey Blvd', Icons.restaurant),
      _tile('Emmy\'s Restaurant', '1923 Ocean Ave', Icons.restaurant),
      _tile(
          'Chaiya Thai Restaurant', '272 Claremont Blvd', Icons.restaurant),
      _tile('La Ciccia', '291 30th St', Icons.restaurant),
    ],
  );
}

ListTile _tile(String title, String subtitle, IconData icon) {
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

  );
}

// 5. Stack
Widget _buildStack() {
  return Stack(
    alignment: const Alignment(0.6, 0.6),
    children: [
      const CircleAvatar(
        backgroundImage: AssetImage('images/pic.jpg'),
        radius: 100,
      ),
      Container(
        decoration: const BoxDecoration(
          color: Colors.black45,
        ),
        child: const Text(
          'Mia B',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

// 6. Card
Widget _buildCard() {
  return SizedBox(
    height: 210,
    child: Card(
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '1625 Main Street',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('My City, CA 99984'),
            leading: Icon(
              Icons.restaurant_menu,
              color: Colors.blue[500],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              '(408) 555-1212',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
          ),
          ListTile(
            title: const Text('costa@example.com'),
            leading: Icon(
              Icons.contact_mail,
              color: Colors.blue[500],
            ),
          ),
        ],
      ),
    ),
  );
}
