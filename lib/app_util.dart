import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

Widget buildHeader(String hd) => DefaultTextStyle(
  child: Container(
    padding: const EdgeInsets.all(8.0),
    color: Colors.blue,
    alignment: Alignment.center,
    child: Text(hd),
  ),
  style: TextStyle(color: Colors.white),
);

Widget app_Oops_Alert(String msg) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      buildHeader(' -- attention notification --'),
      Expanded(
        child: Container(
          color: Colors.white,
          child: Center(
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,

                children: <Widget>[
                  Text('Oops!!!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      //fontStyle: FontStyle.italic,
                      fontSize: 30.0,
                    ),
                  ),
                  Icon(
                      Icons.add_alert,
                      size: 80.0,
                      color: Colors.blue
                  ),
                  Text(msg,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    ],
  );
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

Future<void> dialCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launch(launchUri.toString());
}

Future<void> sendEmail({
    required String toMail,
    required String subject,
    required String body,
  }) async {

  final Uri params = Uri(scheme: 'mailto', path: toMail, queryParameters: {
    'subject': subject,
    'body': body,
  });

  await launch(params.toString());
}

Future<void> sendSMS({
    required String phoneNumber,
    required String body
  }) async {

  final Uri params = Uri(
      scheme: 'sms', path:
      phoneNumber,
      queryParameters: {'body': body}
  );

  await launch(params.toString());
}
