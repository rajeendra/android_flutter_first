import 'package:flutter/material.dart';
import 'package:android_flutter_first/person_model.dart' as modelPerson;

// Person Detail Screen
class DetailScreen extends StatelessWidget {
  DetailScreen({key, required this.person, required this.config});

  //BuildContext? context;
  final nameTxtController = TextEditingController();
  final addressTxtController = TextEditingController();
  final modelPerson.Person person;
  final modelPerson.Config config;
  //nameTxtController.text = person.name;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    //this.context = context;
    nameTxtController.text = '';
    addressTxtController.text = '';

    if (config.method == modelPerson.Config.METHOD_EDIT) {
      nameTxtController.text = person.name;
      addressTxtController.text = person.address;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Person Info'),
      ),
      body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'You are now landed at the person detail info page',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: nameTxtController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: addressTxtController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Address',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        //elevation: 3,
                        //minimumSize: const Size.fromHeight(50), // NEW
                        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: () {
                        modelPerson.Person person = modelPerson.Person(
                            nameTxtController.text, addressTxtController.text);
                        modelPerson.Result result = modelPerson.Result(config, person);
                        Navigator.pop<modelPerson.Result>(context, result);
                        //Navigator.pop(context, person);
                      },
                      child: const Text(
                        'Save',
                        //style: TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ]),
                ]),
          )),
    );
  }
}
