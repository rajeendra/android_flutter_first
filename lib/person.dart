import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// App
import 'package:android_flutter_first/app_util.dart' as util;
import 'package:android_flutter_first/app_model.dart' as model;
import 'package:android_flutter_first/app_constants.dart' as constants;
// App person
import 'package:android_flutter_first/person_form.dart' as formPerson;
import 'package:android_flutter_first/person_model.dart' as modelPerson;

class Person extends StatefulWidget {
  Person({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person>{
  List<modelPerson.Person> persons=[];

  @override
  Widget build(BuildContext context){
   return _buildPerson();
  }

  Widget _buildHeader(String hd) => DefaultTextStyle(
    child: Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.blue,
      alignment: Alignment.center,
      child: Text(hd),
    ),
    style: TextStyle(color: Colors.white),
  );

  Widget _buildPerson() {
    return _app_person();
  }

  Widget _app_person(){
    return  Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildHeader('List view - Dynamically growing'),
              Text(
                'Press plus button to add a new person:',
              ),

              Expanded(child:
              ListView.builder(
                //itemCount: names.length,
                  itemCount: persons.length,
                  itemBuilder: (BuildContext context, int index) {
                    //return _tilePerson('${names[index]}' , '${names[index]}', Icons.restaurant );
                    return _tilePerson(index,'${persons[index].name }' , '${persons[index].address}', Icons.restaurant );
                  }
              ),
              )
            ]
        ),
      )
      ,
      floatingActionButton: FloatingActionButton(
        //onPressed: _onPressedFloatingActionButton,
        onPressed: (){
          _addOrEditPerson(context,modelPerson.Person('',''),modelPerson.Config(modelPerson.Config.METHOD_ADD));
        },
        tooltip: 'add person',
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListTile _tilePerson(int index, String title, String subtitle, IconData icon) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),

      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            //IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton(onPressed:  () { _addOrEditPerson(context,persons[index],modelPerson.Config(modelPerson.Config.METHOD_EDIT,intValue:index)); }, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () { _deletePerson(index); }, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => cw.DetailScreen(todo: persons[index]),
      //     ),
      //   );
      // },
    );
  }

  // Navigate to person edit screen and return back with the data holding in <Result> object
  // Show SnackBar with a message
  Future<void> _addOrEditPerson(BuildContext context, modelPerson.Person person, modelPerson.Config config) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final modelPerson.Result result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formPerson.DetailScreen(person: person, config: config,) ),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    String name = result.person.name;

    if(result.config.method==modelPerson.Config.METHOD_ADD){
      persons.insert(0, result.person);
    } else {
      persons[result.config.intValue]=result.person;
    }

    setState(() {
      // update UI
    });

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    util.showSuccessSnackBar(context, ' Person $name successfully saved. ');

    // ScaffoldMessenger.of(context)
    //   ..removeCurrentSnackBar()
    //   //..showSnackBar(SnackBar(content: Text(' Person $name successfully saved. ')));
    //   ..showSnackBar(_getSnackBar(' Person $name successfully saved. '));
  }

  // Delete with alert dialog conformation
  Future<void> _deletePerson(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete '),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Want to delete ?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          // actions: <Widget>[
          //   TextButton(
          //     child: const Text('Approve'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
          actions: <Widget>[
            TextButton(
              //onPressed: () => Navigator.pop(context, 'Cancelx'),
              onPressed: () { Navigator.pop(context, 'Cancel'); },
              child: const Text('Cancel'),
            ),
            TextButton(
              //onPressed: () => Navigator.pop(context, 'OKx'),
              onPressed: () {
                Navigator.pop(context, 'OK');
                String name = persons.elementAt(index).name;
                setState(() {
                  persons.removeAt(index);
                });
                util.showSuccessSnackBar(context, ' Person $name successfully removed. ');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
