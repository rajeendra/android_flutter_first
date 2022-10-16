import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/cupertino.dart';
import 'package:android_flutter_first/app_util.dart' as util;
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/contact_model.dart' as dm;

var user = '<user>';
var password = '<password>';

class MongoDatabase{

  static connect() async {
    // mongodb+srv://rajeendra:<password>@cluster0.ybonlek.mongodb.net/?retryWrites=true&w=majority
    final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
    await db.open();
    //final response = db.collection('contacts');
    var collection = await db.collection('contacts');
    await collection.insertOne(
        {
          "fname": "rajeendra",
          "lname": "kanishka"
        }
    );
  }

}

app_setCredentials() async {
  model.AppConfiguration appConfiguration = await util.AppUtil.getAppConfig();
  user = appConfiguration.user ?? '';
  password = appConfiguration.password ?? '';
}

// Get all contacts
funcMongo_findCollection(BuildContext context) async{
  List<dm.Contact> contacts = [];
  List<Map<String, dynamic>> result = await findCollection();

  result.forEach((element) {
    dm.Contact contact = dm.Contact.fromJson(element);
    contacts.add(contact);
  });
  util.showSuccessSnackBar(context, 'Success');
  return await contacts;
}

Future< List<Map<String, dynamic>> > findCollection() async {
  List<Map<String, dynamic>> cts = [];

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();
  final response = db.collection('contacts').find();

  await response.forEach((element) { cts.add(element); });
  await db.close();

  return await cts;
}

// find document by id
funcMongo_findDocumentByID(BuildContext context) async{
  dm.Contact contact;
  Map<String, dynamic> result = await findOneContact("632f34bc9dd20c022f54c787");

  contact = await dm.Contact.fromJson(result);

  util.showSuccessSnackBar(context, 'Success');
  return await contact;
}

Future< Map<String, dynamic> >  findOneContact(String id) async {
  Map<String, dynamic> contact;
  ObjectId objId = ObjectId.parse(id);

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();
  final response = db.collection('contacts').find( {'_id': objId} );

  contact = await response.first;
  await db.close();

  return await contact;
}

// insert document
funcMongo_insertDocument(BuildContext context) async{

  List<dm.Number> numbers=[
    dm.Number(id:'0',number:'77118882232332', type: '1omx' ),
    dm.Number(id:'1',number:'772299938u2938', type: '1omx' ),
  ];

  dm.Contact contact = dm.Contact(
    fname: 'fnameWQ',
    lname: 'lnameWQ',
    active: 'Y',
    cpse: 'Company WQ',
    numbers: numbers,
    address: dm.Address(no:'238',street: 'Kandy Rd', city: 'Peradeniya'),
  );

  await insertDocument(contact);

  util.showSuccessSnackBar(context, 'Success');
  return await contact;
}

Future<void>  insertDocument(dm.Contact contact) async {
  Map<String, dynamic> result;

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();
  final response = db.collection('contacts').insertOne(contact.toJson());

  await db.close();
}

// update document by ID
funcMongo_updateDocumentByID(BuildContext context) async{

  List<dm.Number> numbers=[
    dm.Number(id:'0',number:'77338882232332', type: '1omx' ),
    dm.Number(id:'1',number:'774499938u2938', type: '1omx' ),
  ];

  dm.Contact contact = dm.Contact(
    fname: 'fnameWQ',
    lname: 'lnameRR',
    active: 'Y',
    cpse: 'Company WQ',
    numbers: numbers,
    address: dm.Address(no:'232',street: 'Kuru Rd', city: 'Karu'),
  );

  await updateDocumentByID('6332d33e948ad961ec755c5d', contact);

  util.showSuccessSnackBar(context, 'Success');
  return await contact;
}

Future<void>  updateDocumentByID(String id, dm.Contact contact) async {
  Map<String, dynamic> result;
  ObjectId objId = ObjectId.parse(id);

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();

  final response = db.collection('contacts').update({'_id': objId}, contact.toJson());

  //result = await response.
  await db.close();
  //return await response;
}

// Delete document by ID
funcMongo_deleteDocumentByID(BuildContext context) async{

  await deleteDocumentByID('6332cf8f948ad961ec755c5c');

  util.showSuccessSnackBar(context, 'Success');
  return await null;
}

Future<void>  deleteDocumentByID(String id) async {
  Map<String, dynamic> result;
  ObjectId objId = ObjectId.parse(id);

  final db = await Db.create('mongodb+srv://$user:$password@cluster0.ybonlek.mongodb.net/home?retryWrites=true&w=majority');
  await db.open();

  final response = db.collection('contacts').deleteOne({'_id': objId});

  //result = await response.
  await db.close();
  //return await response;
}





