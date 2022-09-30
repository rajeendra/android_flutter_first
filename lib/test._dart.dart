import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_flutter_first/test_mongo_database.dart' as mongo;
import 'package:android_flutter_first/test_model.dart' as testModel;
import 'package:android_flutter_first/app_contact_model.dart' as contactModel;
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/app_util.dart' as util;

void mainTest(BuildContext context) async{
  //testJSON();
  mongoDB(context);
  //testWriteKeyValueToStorage();
}

void mongoDB(BuildContext context) async{
  await mongo.app_setCredentials();

  //await mongo.MongoDatabase.connect();
  //await mongo.funcMongo_findCollection(context);
  //await mongo.funcMongo_findDocumentByID(context);
  //await mongo.funcMongo_insertDocument(context);
  await mongo.funcMongo_updateDocumentByID(context);
  //await mongo.funcMongo_deleteDocumentByID(context);

  print('OK');
}

testWriteKeyValueToStorage() async {
  var user = "<user>";
  var password = "<password>";

  await util.AppUtil.saveAppConfig( model.AppConfiguration(user: user,password: password));
  model.AppConfiguration config = await util.AppUtil.getAppConfig();
  print(await "OK");
}

addStringToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('stringValue', "abc");
  prefs.setInt('intValue', 123);
}

getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String? stringValue = prefs.getString('stringValue');
  return stringValue;
}

void testJSON(){

  // json string
  String jsonString = "{ \"name\": \"John Smith\", \"email\": \"john@example.com\", "+
      "\"address\": { \"street\": \"main street\", \"city\": \"Colombo\" } }";
  //String jsonStringCollection = "{ \"users\" : [{ \"name\": \"Afirst Alast\", \"email\": \"amail@example.com\" },{ \"name\": \"Bfirst Blast\", \"email\": \"bmail@example.com\" }] }";

  // json array string
  String jsonStringCollection = "[{ \"name\": \"Afirst Alast\", \"email\": \"amail@example.com\" },{ \"name\": \"Bfirst Blast\", \"email\": \"bmail@example.com\" }]";

  // Casting json string to a map
  Map<String, dynamic> user = jsonDecode(jsonString);
  //Map user = jsonDecode(jsonString);
  List userCollection = jsonDecode(jsonStringCollection);

  // use values
  print('Howdy, ${user['name']}!');
  print('We sent the verification link to ${user['email']}.');
  print('Street: ${user['address']["street"]}. Street: ${user['address']["city"]} ');

  // json string to map
  Map<String, dynamic> userMap = jsonDecode(jsonString);
  // Take only the values you want to have in data object, in this case without address
  var userA = testModel.User.fromJson(userMap);

  print('Howdy, ${userA.name}!');
  print('We sent the verification link to ${userA.email}.');

  //
  // Map<String, dynamic> userMap = jsonDecode(jsonString);

  // Map to Model
  var userB = testModel.User.fromJson(userMap);
  // Model to String
  String json = jsonEncode(userB);
  print(json);
  // String to Map
  Map<String, dynamic> userMapB = jsonDecode(json);
  // Map to Model
  var userD = testModel.User.fromJson(userMapB);
  // Model to String
  String jsonD = jsonEncode(userD);
  print(jsonD);

}

