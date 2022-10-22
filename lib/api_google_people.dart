import 'dart:async';
import 'dart:convert' show json, jsonEncode;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// App
import 'package:android_flutter_first/app_util.dart' as util;

// This implemented Google SignIn together with make use of <OAuth consent screen>..
// ..to obtain the required scope use in the the app, with permission by the app user
// API Ref: https://developers.google.com/people/api/rest/?apix=true

class APIGooglePeople extends StatefulWidget {
  APIGooglePeople({Key? key, required GoogleSignInAccount this.currentUser}) : super(key: key);

  GoogleSignInAccount currentUser;

  // setting up the message broadcaster
  final streamBroadcaster = new StreamController.broadcast();
  Stream<dynamic> getStream(){
    return streamBroadcaster.stream;
  }

  // This is to send confirmation message to parent once the user has been set after sign-in
  late Stream<dynamic> streamOut;

  @override
  State createState() => _APIGooglePeopleState();
}

class _APIGooglePeopleState extends State<APIGooglePeople> {

  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  bool isSighIn = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
    json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Widget _buildBody() {
    final GoogleSignInAccount user = widget.currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        util.buildHeader('Google People API'),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ListTile(
                leading: GoogleUserCircleAvatar(
                  identity: user,
                ),
                title: Text(user.displayName ?? ''),
                subtitle: Text(user.email),
              ),
              //const Text('Signed in successfully.'),
              Text(_contactText),
              // ElevatedButton(
              //   onPressed: _handleSignOut,
              //   child: const Text('SIGN OUT'),
              // ),
              ElevatedButton(
                child: const Text('Request API'),
                onPressed: () => _handleGetContact(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: _buildBody(),
    );
  }
}