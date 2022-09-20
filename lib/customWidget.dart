import 'package:flutter/material.dart';
import 'domain.dart';

// Success SnackBar
void showSuccessSnackBar(BuildContext context, String msg) => ScaffoldMessenger
    .of(context)
  ..removeCurrentSnackBar()
  //..showSnackBar(SnackBar(content: Text(' Person $name successfully saved. ')));
  ..showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(msg)));

final ButtonStyle flatButtonStyle = TextButton.styleFrom(
  primary: Colors.black87,
  //minimumSize: Size(88, 36),
  minimumSize: Size.fromHeight(40),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
);

// Person Detail Screen
class DetailScreen extends StatelessWidget {
  DetailScreen({key, required this.person, required this.config});

  //BuildContext? context;
  final nameTxtController = TextEditingController();
  final addressTxtController = TextEditingController();
  final Person person;
  final Config config;
  //nameTxtController.text = person.name;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    //this.context = context;
    nameTxtController.text = '';
    addressTxtController.text = '';

    if (config.method == Config.METHOD_EDIT) {
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
                    Person person = Person(
                        nameTxtController.text, addressTxtController.text);
                    Result result = Result(config, person);
                    Navigator.pop<Result>(context, result);
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
