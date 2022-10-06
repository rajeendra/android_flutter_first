import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';

class AppUtil{
  static saveAppConfig(model.AppConfiguration config) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(model.AppConfiguration.APP_CONFIG_KRY, jsonEncode(config));
  }

  static Future<model.AppConfiguration> getAppConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? strConfig = await prefs.getString(model.AppConfiguration.APP_CONFIG_KRY);
    Map<String, dynamic> config = await jsonDecode(strConfig ?? "" );
    var appConfig = await model.AppConfiguration.fromJson(config);
    return appConfig;
  }
}

// Success SnackBar
void showSuccessSnackBar(BuildContext context, String msg) => ScaffoldMessenger
    .of(context)
  ..removeCurrentSnackBar()
//..showSnackBar(SnackBar(content: Text(' Person $name successfully saved. ')));
  ..showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(msg)));

void showFailureSnackBar(BuildContext context, String msg) => ScaffoldMessenger
    .of(context)
  ..removeCurrentSnackBar()
//..showSnackBar(SnackBar(content: Text(' Person $name successfully saved. ')));
  ..showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));

void showPrimarySnackBar(BuildContext context, String msg) => ScaffoldMessenger
    .of(context)
  ..removeCurrentSnackBar()
//..showSnackBar(SnackBar(content: Text(' Person $name successfully saved. ')));
  ..showSnackBar(SnackBar(backgroundColor: Colors.blue, content: Text(msg)));


final ButtonStyle flatButtonStyle = TextButton.styleFrom(
  primary: Colors.black87,
  //minimumSize: Size(88, 36),
  minimumSize: Size.fromHeight(40),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
);