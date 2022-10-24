import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_flutter_first/app_constants.dart' as constants;
import 'package:android_flutter_first/app_util.dart' as appUtil;
import 'package:android_flutter_first/app_model.dart' as appModel;
import 'package:android_flutter_first/contact_model.dart' as model;

var user = '<user>';
var password = '<password>';
String fileId = '1qm2AUpkedJ4iEL9WefrnEWYv64ipjA8L';

app_setCredentials() async {
  appModel.AppConfiguration appConfiguration = await appUtil.AppUtil.getAppConfig();
  user = appConfiguration.user ?? '';
  password = appConfiguration.password ?? '';
}

// Get all contacts
Future<List<model.Contact>> findAllContacts() async{
  List<model.Contact> contacts = [];

  await app_setCredentials();
  List<Map<String, dynamic>> result = await _findCollection();

  result.forEach((element) {
    model.Contact contact = model.Contact.fromJson(element);
    contacts.add(contact);
  });
  return await contacts;
}

Future<void> saveContact(model.Contact contact) async{
  String? _id = contact.id;
  await app_setCredentials();

  try {
    if(_id==null){
      await _insertDocument(contact);
    }else{
      await _updateDocumentByID(_id, contact);
    }
  } catch (e) {
    print(e);
  }
  return null;
}

Future<void> deleteContact(String _id) async{
  await app_setCredentials();

  try {
    await _deleteDocumentByID(_id);
  } catch (e) {
    print(e);
  }
  return null;
}

Future<void> cacheContacts(List<model.Contact> contacts) async {
  Map<String,dynamic> mapContacts = Map();
  mapContacts["contacts"] = contacts;
  String strContacts = jsonEncode(mapContacts);
  _cacheContacts(strContacts);
}

Future<List<model.Contact>> getCachedContacts() async{
  List<model.Contact> contacts = [];
  String strContacts = await _getCachedContact();
  if( strContacts.length > 0 ){
    Map<String, dynamic> contactsMap = jsonDecode(strContacts);
    List<dynamic> result = contactsMap['contacts'];
    result.forEach((element) {
      model.Contact contact = model.Contact.fromJson(element,source: 'local');
      contacts.add(contact);
    });
  }
  return contacts;
}

//
Future< List<Map<String, dynamic>> > _findCollection() async {
  List<Map<String, dynamic>> cts = [];

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();
  final response = db.collection('contacts').find();

  await response.forEach((element) { cts.add(element); });
  await db.close();

  return await cts;
}

Future<void>  _insertDocument(model.Contact contact) async {
  Map<String, dynamic> result;

  final db = await Db.create(
      'mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();
  final response = db.collection('contacts').insertOne(contact.toJson());

  await db.close();
}

Future<void>  _updateDocumentByID(String id, model.Contact contact) async {
  Map<String, dynamic> result;
  ObjectId objId = ObjectId.parse(id);

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();

  final response = db.collection('contacts').update({'_id': objId}, contact.toJson());

  //result = await response.
  await db.close();
  //return await response;
}

Future<void>  _deleteDocumentByID(String id) async {
  Map<String, dynamic> result;
  ObjectId objId = ObjectId.parse(id);

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();

  final response = db.collection('contacts').deleteOne({'_id': objId});

  //result = await response.
  await db.close();
  //return await response;
}

Future<void> _cacheContacts(String contacts) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(constants.MODULE_CONTACT_CACHE, contacts);
}

Future<String> _getCachedContact() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
String strConfig = await prefs.getString(constants.MODULE_CONTACT_CACHE) ?? '';
return strConfig;
}

Future<List<model.Contact>> getContactsFromGoogleDrive(GoogleSignInAccount currentUser) async {
  List<model.Contact> result;

  final http.Response response = await http.get(
    Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
    headers: await currentUser.authHeaders,
  );
  if (response.statusCode != 200) {
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

Future<List<model.Contact>> saveContactsToGoogleDrive(
    model.Contact? oneContact,
    List<model.Contact> contacts,
    GoogleSignInAccount currentUser) async {
  List<model.Contact> result;

  if (oneContact == null){
    // Delete contact
  }else if(oneContact.id==null){
    // Add contact
    oneContact.id = 'gd${appUtil.getKey()}';
    contacts.add(oneContact);
  }else{
    // Update contact
    for (var j = 0; j < contacts.length; j++) {
      if(oneContact.id==contacts[j].id){
        contacts[j] = oneContact;
        break;
      }
    }
  }

  Map<String,dynamic> mapContacts = Map();
  mapContacts["contacts"] = contacts;
  String fileContent = jsonEncode(mapContacts);

  final http.Response response = await http.patch(
    Uri.parse('https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media'),
    body: fileContent,
    headers: await currentUser.authHeaders,
  );
  if (response.statusCode == 200) {
    result = await getContactsFromGoogleDrive(currentUser);
    return result;
  } else {
    final Map<String, dynamic> data =
    json.decode(response.body) as Map<String, dynamic>;
    throw ('${data['error']['message']}');
  }
}

