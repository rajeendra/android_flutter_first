import 'dart:async';
import 'dart:convert' show json, jsonEncode;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// App
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/app_util.dart' as util;

// This implemented Google SignIn together with make use of <OAuth consent screen>..
// ..to obtain the required scope by the app, with permission by the app user

class GoogleOAuthConsentSignIn extends StatefulWidget {
  GoogleOAuthConsentSignIn({Key? key, GoogleSignInAccount? this.currentUser}) : super(key: key);

  GoogleSignInAccount? currentUser;

  // setting up the message broadcaster
  final streamBroadcaster = new StreamController.broadcast();
  Stream<dynamic> getStream(){
    return streamBroadcaster.stream;
  }

  // This is to send confirmation message to parent once the user has been set after sign-in
  late Stream<dynamic> streamOut;

  @override
  State createState() => _GoogleOAuthConsentSignInState();
}

class _GoogleOAuthConsentSignInState extends State<GoogleOAuthConsentSignIn> {

  GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    //clientId: '979898998-rk7b7sgd117iou63v24qj6ts3p9df49r.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
      'https://www.googleapis.com/auth/drive',
    ],
  );

  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  bool isSighIn = false;

  @override
  void initState() {
    super.initState();
    // set a Listener to detect when user changed
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        //_handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

  void _sendMessageOnSignIn(){
    widget.currentUser = _currentUser;
    model.Message message = model.Message(
        sender: model.Message.GOOGLE_SIGN_IN,
        receiver: model.Message.PARENT,
        message: model.Message.MESSAGE_OK
    );
    String str = jsonEncode(message);
    widget.streamBroadcaster.sink.add(str);
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      //_sendMessageOnSignIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    _sendMessageOnSignIn();
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[

          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          Text(_contactText),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        util.buildHeader('Google sign-in'),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: _buildBody(),
          ),
        ),
      ],
    );
  }
}