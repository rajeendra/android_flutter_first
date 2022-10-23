import 'dart:async';
import 'dart:convert' show json, jsonEncode, utf8;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:android_flutter_first/contact_model.dart' as model;

// App
import 'package:android_flutter_first/app_util.dart' as util;

// This integrate the app with the usage of Google's Driver API.
// Sign-in required in prior to access the scope by the app in user's space
// API Ref: https://developers.google.com/drive/api

class APIGoogleDrive extends StatefulWidget {
  APIGoogleDrive({Key? key, required GoogleSignInAccount this.currentUser}) : super(key: key);

  final GoogleSignInAccount currentUser;

  @override
  State createState() => _APIGoogleDriveState();
}

class _APIGoogleDriveState extends State<APIGoogleDrive> {

  String fileId = '1qm2AUpkedJ4iEL9WefrnEWYv64ipjA8L';
  List<model.Contact>? contacts;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
  }

  Future<List<model.Contact>> _getContacts() async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    List<model.Contact> result = await _getContactsFromGoogleDrive();
    setState(() {
      _contactText = '';
    });
    return result;
  }

  Future<List<model.Contact>> _getContactsFromGoogleDrive() async {
    List<model.Contact> result;

    final http.Response response = await http.get(
      Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
      headers: await widget.currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      _contactText = 'Drive API gave a ${response.statusCode} '
          'response. Check logs for details.';
      print('Drive API ${response.statusCode} response: ${response.body}');
    }
    final Map<String, dynamic> data =
    json.decode(response.body) as Map<String, dynamic>;
    result = _transformContacts(data);
    return result;
  }

  List<model.Contact> _transformContacts(Map<String, dynamic> data) {
    List<model.Contact> contacts = [];
    List<dynamic> result = data['contacts'];
    result.forEach((element) {
      model.Contact contact = model.Contact.fromJson(element,source: 'local');
      contacts.add(contact);
    });
    return contacts;
  }

  Future<model.Contact> _getContactByIndex(int index) async {
    List<model.Contact> fetchedContacts =  await _getContacts();
    if(fetchedContacts.length>0){
      contacts = fetchedContacts;
    }
    return contacts![0];
  }

  Future<File> writeTextContentToFile(String strContacts, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    final file = '$path/$fileName';
    return await File(file).writeAsString(strContacts);
  }

  _getFirstContact() async{
    model.Contact _contact = await _getContactByIndex(0);
    _txtFnameController.text = _contact.fname ?? '';
    _txtLnameController.text = _contact.lname ?? '';
  }

  _saveFirstContact() async{
    //model.Contact _contact = await _getContactByIndex(0);
    contacts?[0].fname = _txtFnameController.text;
    contacts?[0].lname = _txtLnameController.text;
    await _saveContacts();
    //util.showSuccessSnackBar(context, 'contact saved');
  }

  Future<void> _saveContacts() async {
    setState(() {
      _contactText = 'Saving contact info...';
    });
    await _saveContactsToGoogleDrive();
    setState(() {
      _contactText = '';
    });
  }

  _saveContactsToGoogleDrive() async {
    Map<String,dynamic> mapContacts = Map();
    mapContacts["contacts"] = contacts;
    String fileContent = jsonEncode(mapContacts);

    final http.Response response = await http.patch(
      Uri.parse('https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media'),
      body: fileContent,
      headers: await widget.currentUser.authHeaders,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      final Map<String, dynamic> data =
      json.decode(response.body) as Map<String, dynamic>;
      throw ('${data['error']['message']}');
    }
  }

  final _txtFnameController = TextEditingController();
  final _txtLnameController = TextEditingController();
  Widget _buildBody() {
    //final GoogleSignInAccount user = widget.currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        util.buildHeader('Google Drive API'),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ListTile(
                leading: GoogleUserCircleAvatar(
                  identity: widget.currentUser,
                ),
                title: Text(widget.currentUser.displayName ?? ''),
                subtitle: Text(widget.currentUser.email),
              ),
              Text(_contactText),
              ElevatedButton(
                child: const Text('Extract contact'),
                onPressed: () => _getFirstContact()
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: _txtFnameController,
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
                controller: _txtLnameController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Last name',
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                child: const Text('Save contact'),
                onPressed: () => _saveFirstContact(),
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