import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:android_flutter_first/app_constants.dart' as constants;
import 'package:android_flutter_first/app_util.dart' as util;
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/contact_model.dart' as dm;
import 'package:shared_preferences/shared_preferences.dart';

var user = '<user>';
var password = '<password>';

app_setCredentials() async {
  model.AppConfiguration appConfiguration = await util.AppUtil.getAppConfig();
  user = appConfiguration.user ?? '';
  password = appConfiguration.password ?? '';
}

// Get all contacts
Future<List<dm.Contact>> findAllContacts() async{
  List<dm.Contact> contacts = [];

  await app_setCredentials();
  List<Map<String, dynamic>> result = await _findCollection();

  result.forEach((element) {
    dm.Contact contact = dm.Contact.fromJson(element);
    contacts.add(contact);
  });
  return await contacts;
}

Future<void> saveContact(dm.Contact contact) async{
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

Future<void> cacheContacts(List<dm.Contact> contacts) async {
  Map<String,dynamic> mapContacts = Map();
  mapContacts["contacts"] = contacts;
  String strContacts = jsonEncode(mapContacts);
  _cacheContacts(strContacts);
}

Future<List<dm.Contact>> getCachedContacts() async{
  List<dm.Contact> contacts = [];
  String strContacts = await _getCachedContact();
  if( strContacts.length > 0 ){
    Map<String, dynamic> contactsMap = jsonDecode(strContacts);
    List<dynamic> result = contactsMap['contacts'];
    result.forEach((element) {
      dm.Contact contact = dm.Contact.fromJson(element,source: 'local');
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

Future<void>  _insertDocument(dm.Contact contact) async {
  Map<String, dynamic> result;

  final db = await Db.create(
      'mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();
  final response = db.collection('contacts').insertOne(contact.toJson());

  await db.close();
}

Future<void>  _updateDocumentByID(String id, dm.Contact contact) async {
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

