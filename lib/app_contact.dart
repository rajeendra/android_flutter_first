import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:android_flutter_first/app_util.dart' as util;
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/app_contact_model.dart' as dm;

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
