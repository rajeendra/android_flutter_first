import 'package:flutter/material.dart';
import 'package:android_flutter_first/app_home.dart' as hp;
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  //final firstCamera = cameras.first;
  //print('OK');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return buildMaterialApp(context);
  }
}

Widget buildMaterialApp(BuildContext context){
  return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.green
      ),

      // Always one home page ( stateful ) for one app
      // On top of home page you can build dynamically Scaffold s and/or Body s as you needed inside build() method
      // Each build() has its own Build context and the State currently its in
      // Each time you call setSate() only run the build() in the current state where the setSate() is call

      home: hp.HomePage(title: 'Test App', key: ValueKey<String>("wyewriyweu"))
  );
}





