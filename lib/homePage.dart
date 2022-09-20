import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:android_flutter_first/domain.dart' as data;
import 'package:android_flutter_first/customWidget.dart' as cw;


class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<data.Person> persons=[];
  int _counter = 0;
  int _selectedMenuItem = 0;

  // final nameTxtController = TextEditingController();
  // final addressTxtController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    // nameTxtController.dispose();
    // addressTxtController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // void _addItemToList() {
  //   setState(() {
  //     if (nameTxtController.text.isNotEmpty & addressTxtController.text.isNotEmpty) {
  //     //persons.insert(persons.length , Person(nameTxtController.text, addressTxtController.text)); // Adding to bottom
  //       persons.insert(0, data.Person(nameTxtController.text, addressTxtController.text)); // Adding to top
  //       nameTxtController.clear();
  //       addressTxtController.clear();
  //     }
  //   });
  // }

  void _addPersonToList(data.Person person) {
    setState(() {
      if (person.name.isNotEmpty & person.address.isNotEmpty) {
        persons.insert(0, person);
      }
    });
  }

  void _onPressedFloatingActionButton() {
    if(_selectedMenuItem==0){
      _incrementCounter();
    }
    if(_selectedMenuItem==2){
      //_addItemToList();
      _addOrEditPerson(context,data.Person('',''),data.Config(data.Config.METHOD_ADD));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: _buildSelectedBody()
      ,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.rectangle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [
                    //0.1,
                    //0.4,
                    0.5,
                    0.8,
                  ],
                  colors: [
                    //Colors.yellow,
                    //Colors.red,
                    Colors.green,
                    Colors.blue,
                  ],
                )

              ),
              child: Text('Flatter layout selector'),
            ),
            ListTile(
              title: const Text('Grid'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                setState(() {
                  _selectedMenuItem = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('List view - Dynamically growing'),
              onTap: () {
                setState(() {
                  _selectedMenuItem = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Widgets Fully Stretched'),
              onTap: () {
                setState(() {
                  _selectedMenuItem = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Number incrementer'),
              onTap: () {
                setState(() {
                  _selectedMenuItem = 0;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressedFloatingActionButton,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget? _buildSelectedBody() {
    if (_selectedMenuItem == 1) {
      return _buildGridUI();
    }
    else if (_selectedMenuItem == 2) {
      return _buildIncrementalList();
    }
    else if (_selectedMenuItem == 3) {
      return _buildWidgetsFullyStretched();
    }
    else {
      return _buildNumberIncrementer();
    }
  }

  Widget _buildWidgetsFullyStretched() => Scaffold(
        backgroundColor: Color(0xFF222222),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Expanded row has Expanded children inside a column with CrossAxisAlignment.stretch
            _buildHeader('Widgets fully stretched'),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    // Center is NON Expandable
                    // NON expanded Container in Center
                    // child: Center(
                    //   child: Container(
                    //     color: Colors.red,
                    //     child: Text('Left', textAlign: TextAlign.center),
                    //   ),
                    // ),

                    // Container is Expandable
                    // Center in Expanded Container
                    child: Container(
                      color: Colors.white24,
                      child: Center(
                        child: Text('Left', textAlign: TextAlign.center),
                      )
                    ),

                    // child: Container(
                    //   color: Colors.red,
                    //   child: Text('Left', textAlign: TextAlign.center),
                    // ),

                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white38,
                      child: Text('Right', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),

            // Expanded Container after a Row
            Expanded(
              child: Container(
                color: Colors.white,
                // child: Text('Bottom', textAlign: TextAlign.center),

                child: Center(
                  child: Text('Bottom', textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      );

  // 1. Number Incrementer
  Widget _buildNumberIncrementer() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header not expanded so it goes on top of the column
          _buildHeader('Number Incrementer'),

          // Expanded Container take rest of all the vertical space
          // children placed vertically center as the below column MainAxisAlignment set to center
          Expanded(
            child: Container(
              color: Colors.black12,

              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You have clicked the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    )

                  ]
              ),
            ),
          ),
        ],
      );

  // 4. Build incremental list
  Widget _buildIncrementalList() {
    return
      Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildHeader('List view - Dynamically growing'),
              // DefaultTextStyle(
              //   child: Container(
              //             padding: const EdgeInsets.all(8.0),
              //             color: Colors.blue,
              //             alignment: Alignment.center,
              //             child: Text("Header"),
              //          ),
              //   style: TextStyle(color: Colors.white),
              // ),
              Text(
                'Press plus button to add a new person:',
              ),
              // TextField(
              //   controller: nameTxtController,
              //   obscureText: false,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Name',
              //   ),
              // ),
              // TextField(
              //   controller: addressTxtController,
              //   obscureText: false,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Address',
              //   ),
              // ),

              // TextButton(
              //   style: cw.flatButtonStyle,
              //   onPressed: () { },
              //   child: Text('Looks like a FlatButton'),
              // ),

              // RaisedButton(
              //   color: true ? Colors.green : Colors.red,
              //   onPressed: () {
              //     setState(() {
              //       //_list[i] = !_list[i];
              //     });
              //   },
              //   child: Text("Button"),
              // ),

              // const SizedBox(
              //   height: 5,
              // ),

              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.green,
              //     onPrimary: Colors.white,
              //     //elevation: 3,
              //     minimumSize: const Size.fromHeight(50), // NEW
              //     //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
              //     //minimumSize: const Size(100,40),
              //   ),
              //   onPressed: () {_addItemToList();},
              //   child: const Text(
              //     'Submit',
              //     //style: TextStyle(fontSize: 24),
              //   ),
              // ),

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
            IconButton(onPressed:  () { _addOrEditPerson(context,persons[index],data.Config(data.Config.METHOD_EDIT,intValue:index)); }, icon: const Icon(Icons.edit)),
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

  void _XaddOrEditPerson(BuildContext context, data.Person person, data.Config config){
    // Switching to another scaffold with same <build context> with MaterialPageRoute
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => cw.DetailScreen(person: person, config: config,),
      ),
    );
  }

  // Navigate to person edit screen and return back with the data holding in <Result> object
  // Show SnackBar with a message
  Future<void> _addOrEditPerson(BuildContext context, data.Person person, data.Config config) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final data.Result result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => cw.DetailScreen(person: person, config: config,) ),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    String name = result.person.name;

    if(result.config.method==data.Config.METHOD_ADD){
      persons.insert(0, result.person);
    } else {
      persons[result.config.intValue]=result.person;
    }

    setState(() {
      // update UI
    });


    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    cw.showSuccessSnackBar(context, ' Person $name successfully saved. ');

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
                cw.showSuccessSnackBar(context, ' Person $name successfully removed. ');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}

// 2. Page Header
Widget _buildHeader(String hd) => DefaultTextStyle(
  child: Container(
    padding: const EdgeInsets.all(8.0),
    color: Colors.blue,
    alignment: Alignment.center,
    child: Text(hd),
  ),
  style: TextStyle(color: Colors.white),
);

// 2. GridView Layout
Widget _buildGridUI() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildHeader('Grid'),
        Expanded(
          child: _buildGrid(),
        ),
      ],
    )
);

Widget _buildGrid() => GridView.extent(
    maxCrossAxisExtent: 150,
    padding: const EdgeInsets.all(4),
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    children: _buildGridTileList(30));

List<Widget> _buildGridTileList(int count) =>
    List.generate(count, (i) => Container(child: Image.asset('images/c.png')));

// 3. List of images in a row or column
Widget _buildImageCollection() =>
  Center(
    // child: Row(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Image.asset('images/a.jpg'),
          // Image.asset('images/b.png'),
          // Image.asset('images/c.png'),

          Expanded(
            child: Image.asset('images/large_01.jpg'),
          ),
          Expanded(
            flex: 2,
            child: Image.asset('images/large_02.jpg'),
          ),
          Expanded(
            child: Image.asset('images/large_03.jpg'),
          ),
        ],
      )
  );

// 4. Build list
Widget _buildList() {
  return ListView(
    children: [
      _tile('CineArts at the Empire', '85 W Portal Ave', Icons.theaters),
      _tile('The Castro Theater', '429 Castro St', Icons.theaters),
      _tile('Alamo Drafthouse Cinema', '2550 Mission St', Icons.theaters),
      _tile('Roxie Theater', '3117 16th St', Icons.theaters),
      _tile('United Artists Stonestown Twin', '501 Buckingham Way',
          Icons.theaters),
      _tile('AMC Metreon 16', '135 4th St #3000', Icons.theaters),
      const Divider(),
      _tile('K\'s Kitchen', '757 Monterey Blvd', Icons.restaurant),
      _tile('Emmy\'s Restaurant', '1923 Ocean Ave', Icons.restaurant),
      _tile(
          'Chaiya Thai Restaurant', '272 Claremont Blvd', Icons.restaurant),
      _tile('La Ciccia', '291 30th St', Icons.restaurant),
    ],
  );
}

ListTile _tile(String title, String subtitle, IconData icon) {
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

  );
}

// 5. Stack
Widget _buildStack() {
  return Stack(
    alignment: const Alignment(0.6, 0.6),
    children: [
      const CircleAvatar(
        backgroundImage: AssetImage('images/pic.jpg'),
        radius: 100,
      ),
      Container(
        decoration: const BoxDecoration(
          color: Colors.black45,
        ),
        child: const Text(
          'Mia B',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

// 6. Card
Widget _buildCard() {
  return SizedBox(
    height: 210,
    child: Card(
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '1625 Main Street',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('My City, CA 99984'),
            leading: Icon(
              Icons.restaurant_menu,
              color: Colors.blue[500],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              '(408) 555-1212',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
          ),
          ListTile(
            title: const Text('costa@example.com'),
            leading: Icon(
              Icons.contact_mail,
              color: Colors.blue[500],
            ),
          ),
        ],
      ),
    ),
  );
}





/*

* */