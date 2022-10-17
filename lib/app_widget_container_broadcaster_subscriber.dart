import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// App
import 'package:android_flutter_first/app_model.dart' as model;

// This widget hold the broadcaster as well as the subscriber..
// ..in order to enable inter widget message passing
// method codeNeedWhenThisWidgetConstructingAtParent() below..
// ..hold the boiler plate code required this widget constructing on the parent
// Message object model use to hold the information about the..
// ..source widget, destination widget and the message text being used of the message

class BSContainer extends StatefulWidget {
  BSContainer({Key? key, required this.title, required this.streamIn}) : super(key: key);

  final String title;

  // Incoming stream from parent
  final Stream streamIn;

  // setting up the message broadcaster
  final streamBroadcaster = new StreamController.broadcast();
  Stream<dynamic> getStream(){
    return streamBroadcaster.stream;
  }

  // setting up the message subscriber
  // setting up the subscription and the stream it listening to
  StreamSubscription? streamSubscription;
  // Outgoing stream to parent
  late Stream<dynamic> streamOut;


  @override
  _BSContainerState createState() => _BSContainerState();
}

class _BSContainerState extends State<BSContainer>{


  //int selectedState = 0;
  final txtFieldController = TextEditingController();
  String msg = '';

  @override
  void initState() {
    super.initState();
    widget.streamSubscription = widget.streamIn.listen((dynamic data) => respondOnMessageReceived(data));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    widget.streamBroadcaster.close();
    super.dispose();
  }

  //   void _onPressedFloatingActionButton() {
  //   if(selectedState==constants.STATE_DEFAULT){
  //     //_incrementCounter();
  //   } else if (selectedState == constants.STATE_APP_CONTACT) {
  //     // At _app_contact
  //
  //     //changeNotifier.sink.add(null);
  //     //changeNotifier.sink.add("Data!");
  //
  //     // Example of inter widget communication
  //     // Send Stream data from HomePage() widget to Contact() widget
  //     // Broadcaster (changeNotifier) sending Stream data to subscriber
  //     changeNotifier.sink.add(constants.STATE_APP_CONTACT);
  //   }
  // }

  void respondOnMessageReceived(String data){
    print('DATA: $data' );
    // msg = data;
    // setState(() {
    // });

    Map<String,dynamic> valueMap = jsonDecode(data);
    model.Message message = model.Message.fromJson(valueMap);
    if(message.receiver==widget.title || message.receiver==model.Message.ALL ){
      setState(() {
        msg = message.message;
      });
    }

  }

  void SendStreamMessage(String toWidget){
    String receiver = toWidget;
    if(toWidget==model.Message.CHILD){
      receiver =  widget.title==model.Message.CHILD_1? model.Message.CHILD_2 : model.Message.CHILD_1;
    }

    model.Message message = model.Message(
        sender: widget.title,
        //receiver: widget.title==model.Message.CHILD_1? model.Message.CHILD_2 : model.Message.CHILD_1,
        receiver: receiver,
        message: txtFieldController.text
    );

    String str = jsonEncode(message);
    //changeNotifier.sink.add(null);
    //changeNotifier.sink.add("Data!");

    // Example of inter widget communication
    // Send Stream data to parent
    widget.streamBroadcaster.sink.add(str);
  }

  @override
  Widget build(BuildContext context) {
    return _buildSelectedBody();
  }

  //Row( mainAxisAlignment: MainAxisAlignment.end,
  //children: <Widget>[]),

  Widget _buildSelectedBody() {
    return Container(
      color: Colors.white,
      // child: Text('Bottom', textAlign: TextAlign.center),
      child: Column(
        children: <Widget>[
          //Header
          DefaultTextStyle(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey,
              alignment: Alignment.center,
              child: Text(widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          //Message display board
          DefaultTextStyle(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(msg,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            style: TextStyle(color: Colors.blue),
          ),
          //TextField
          Container(
              height: 50,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text('Scrollable 2 : Index $index'),
                child: TextField(
                  controller: txtFieldController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Message',
                  ),
                ),
              )),
          Row( mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Button
                Container(
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
                        onPressed: () { SendStreamMessage(model.Message.CHILD); },
                        child: const Text(
                          'Sink Child',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )),
                Container(
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
                        onPressed: () { SendStreamMessage(model.Message.PARENT); },
                        child: const Text(
                          'Sink Parent',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )),
              ]),
        ],
      ),
      // child: Center(
      //   child: Text('Bottom', textAlign: TextAlign.center),
      // ),
    );
  }

  void codeNeedWhenThisWidgetConstructingAtParent(){
    // cwMc.BSContainer childWidget = cwMc.BSContainer(
    //   title: title,
    //
    //   // Setting: inter widget communication between from parent to child
    //
    //   // Stream goes in to child from parent
    //   streamIn: changeNotifier.stream,
    // );
    //
    // // Setting: inter widget communication between from child to parent
    // // After child construction over in the parent, get the stream from child
    // // for listening by the parent's subscription
    //
    // // Stream from child to parent
    // stream = childWidget.getStream();
    // // Parent listening to the stream coming from child
    // streamSubscription = stream.listen((dynamic data) => respondOnMessageReceived(data));
  }

}

