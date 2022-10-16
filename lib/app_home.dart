import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// main
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
import 'package:android_flutter_first/app_person.dart' as person;
// App contact
import 'package:android_flutter_first/app_contact.dart' as contact;
// App album
import 'package:android_flutter_first/app_album.dart' as album;

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  // settings for widget messaging
  final changeNotifier = new StreamController.broadcast();

  // setting up the subscription and the stream it listening to
  // Declare the HomePage() widget's subscription ( Parent widget )
  StreamSubscription? streamSubscription;
  // Declare the Stream from Contact() widget ( Child widget )
  // This initialize at the child construction time in the parent
  late Stream<dynamic> stream;

  // Test data
  final fNms = List<String>.generate(30, (i) => "Fname$i Lname$i");
  final fAds = List<String>.generate(30, (i) => "10 Street$i City$i");

  bool isFAButtonVisible = true;
  int _counter = 0;
  int selectedState = constants.STATE_DEFAULT;

  late CameraController cameraController;

  @override
  void initState() {
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

  // Test method is just to test the messages from child once they received
  void someMethod(int data) {
    print('DATA: $data' );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    cameraController.dispose();
    changeNotifier.close();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onPressedFloatingActionButton() {
    if(selectedState==constants.STATE_DEFAULT){
      _incrementCounter();
    } else if(selectedState==constants.STATE_APP_PERSON){

    } else if(selectedState==constants.STATE_LAYOUT_FULL_STRETCHED){
      test.mainTest(context);
    } else if (selectedState == constants.STATE_APP_CONTACT) {
      // At _app_contact

      //changeNotifier.sink.add(null);
      //changeNotifier.sink.add("Data!");

      // Example of inter widget communication
      // Send Stream data from HomePage() widget to Contact() widget
      // Broadcaster (changeNotifier) sending Stream data to subscriber
      changeNotifier.sink.add(constants.STATE_APP_CONTACT);

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
    isFAButtonVisible = true;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: _buildSelectedBody()
      ,
      drawer: _drawer(),
       // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: Visibility(
        child: FloatingActionButton(
                onPressed: _onPressedFloatingActionButton,
                tooltip: 'add new',
                elevation: 1,
                child: Icon(Icons.add),
              ),
        visible: isFAButtonVisible, // set it to false
      )

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
            child: Text('Flatter learn app'),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Layout | Grid',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              setState(() {
                selectedState = constants.STATE_LAYOUT_GRID;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Person | List view, Dynamically grow',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Layout | Widgets fully stretched',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Album | Async http call',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Configuration',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              _app_contact_config_show();
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Contact',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              setState(() {
              selectedState = constants.STATE_APP_CONTACT;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            title: const Text('Share content',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Layout | Scrollable form',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Layout | Silvers',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Silvers - Multiple pages',
              style: TextStyle(fontSize: 15),
            ),
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
            title: const Text('Number incrementer | ..',
              style: TextStyle(fontSize: 15),
            ),
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

    if (selectedState == constants.STATE_LAYOUT_GRID) {
      return _buildGridUI();
    }
    else if (selectedState == constants.STATE_APP_PERSON) {
      isFAButtonVisible = false;
      return person.Person(title: "Person",);
    }
    else if (selectedState == constants.STATE_LAYOUT_FULL_STRETCHED) {
      return _buildWidgetsFullyStretched();
    }
    else if (selectedState == constants.STATE_APP_ALBUM) {
      return album.Album(title: "Album");
    }
    else if (selectedState == constants.STATE_APP_CONFIGURATION) {
      return _app_contact_config();
    }
    else if (selectedState == constants.STATE_APP_CONTACT) {
      //return _app_contact();
      contact.Contact theContact = contact.Contact(
        title: "Contact",

        // Setting: inter widget communication between from parent to child
        // Setting up the stream from this widget (HomePage()) to Contact() widget
        shouldTriggerChange: changeNotifier.stream,
      );

      // Setting: inter widget communication between from child to parent
      // After child construction over in the parent, get the stream from child
      // for listening by the parent's subscription
      stream = theContact.getStream();
      streamSubscription = stream.listen((dynamic data) => someMethod(data));

      return theContact;
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

  ///////////////////////////////////////////////////
  //  App | core app components
  ///////////////////////////////////////////////////

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

  final txtFnameController = TextEditingController();
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
    silverPages.add(album.Album(title: "Album1"));
    silverPages.add(_app_Oops());
    silverPages.add(album.Album(title: "Album2"));
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
  //  Share resources
  ///////////////////////////////////////////////////

  Widget _buildShareResources() => Scaffold(
    //backgroundColor: Color(0xFF222222),
    backgroundColor: Colors.white,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildHeader('Share content'),
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
  //  Configuration app
  ///////////////////////////////////////////////////

  model.AppConfiguration appContactConfiguration=model.AppConfiguration();
  final txtUserController  = TextEditingController();
  final txtPassController = TextEditingController();

  Future<void> _app_contact_config_show() async {
    await _app_contact_getCredentials();
    setState(() {
      selectedState = constants.STATE_APP_CONFIGURATION;
    });
  }

  Future<void> _app_contact_getCredentials() async {
    try {
      appContactConfiguration = await util.AppUtil.getAppConfig();
    } catch (e) {
      print(e);
    }
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
