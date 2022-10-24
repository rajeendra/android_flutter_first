import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Google API
import 'package:google_sign_in/google_sign_in.dart';

// App
import 'package:android_flutter_first/app_util.dart' as appUtil;
import 'package:android_flutter_first/app_model.dart' as appModel;
import 'package:android_flutter_first/app_constants.dart' as constants;
// App contact
import 'package:android_flutter_first/contact_service.dart' as contact;
import 'package:android_flutter_first/contact_model.dart' as model;

class Contact extends StatefulWidget {
  Contact({
    Key? key,
    required this.title,
    required this.shouldTriggerChange,
    required this.currentUser,
  }) : super(key: key);

  final GoogleSignInAccount currentUser;
  final Stream shouldTriggerChange;
  final String title;

  // Setting: inter widget communication, between, from child to parent
  // setting up the Contact() widget's broadcaster
  final changeNotifier = new StreamController.broadcast();

  // This method enable get the stream out form here to set in the parent..
  // ..once after this widget being constructed in the parent
  Stream<dynamic> getStream(){
    return changeNotifier.stream;
  }

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  // inter widget communication - setting up receiver
  StreamSubscription? streamSubscription;

  int selectedState = constants.STATE_MODULE_CONTACT;
  late ScrollController _scrollController;
  double _offset = 0.0;

  @override
  void initState(){
    _scrollController = ScrollController()
      ..addListener(() {
        // when ListView gets scroll _offset will update
        _offset = _scrollController.offset;
        //print("offset = ${_scrollController.offset}");
      });

    super.initState();
    // inter widget communication - data receiving
    // stream subscriber (streamSubscription) listen to the stream (shouldTriggerChange) ..
    // .. send by the broadcaster (StreamController.broadcast();)

    //streamSubscription = widget.shouldTriggerChange.listen((dynamic data) => someMethod(data));
    streamSubscription = widget.shouldTriggerChange.listen((dynamic data) => newContact(data));

    _setCachedContacts();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _scrollController.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  didUpdateWidget(Contact old) {
    super.didUpdateWidget(old);

    // inter widget communication - data receiving
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerChange != old.shouldTriggerChange) {
      streamSubscription?.cancel();
      // streamSubscription = widget.shouldTriggerChange.listen((dynamic data) => someMethod(data));
      streamSubscription = widget.shouldTriggerChange.listen((dynamic data) => newContact(data));
    }
  }

  @override
  Widget build(BuildContext context){
    return _buildSelectedBody();
  }

  // void someMethod(int data) {
  //   print('DATA: $data' );
  // }

  Widget _buildSelectedBody() {
    Widget result = _app_contact();

    if (selectedState == constants.STATE_MODULE_CONTACT_ONE) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    if (selectedState == constants.STATE_MODULE_CONTACT_ONE) {
      result = _app_contact_one();
    }
    else if (selectedState == constants.STATE_MODULE_CONTACT_NUMBER) {
      result = _app_contact_number_silver();
    }
    else if (selectedState == constants.STATE_MODULE_CONTACT_SPINNER) {
      result = _app_contact_spinner();
    }
    else if (selectedState == constants.STATE_ERROR_UNEXPECTED) {
      result = _app_Oops();
    }
    return result;
  }

  void newContact(int state) {
    if(state == constants.STATE_MODULE_CONTACT){
      if(selectedState==constants.STATE_MODULE_CONTACT){
        // At _app_contact
        selectedContact = _app_contact_new_contact();
        _app_contact_one_show(-1);
      }
      else if(selectedState==constants.STATE_MODULE_CONTACT_ONE){
        // At _app_contact_one
        _app_contact_number_show(-1);
      }
    }
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

  ///////////////////////////////////////////////////
  //  Contacts app
  ///////////////////////////////////////////////////

  String _contactsStorage = constants.MODULE_CONTACT_STORAGE_GOOGLE_DRIVE;
  //String _contactsStorage = constants.MODULE_CONTACT_STORAGE_MONGO_ATLAS;
  List<model.Contact> contacts = [];
  List<model.Contact> contactsCopy = [];
  model.Contact? selectedContact;
  model.Number? selectedNumber;
  appModel.AppConfiguration appContactConfiguration=appModel.AppConfiguration();

  final txtUserController  = TextEditingController();
  final txtPassController = TextEditingController();
  final txtSearchController = TextEditingController();

  final txtFnameController = TextEditingController();
  final txtLnameController = TextEditingController();
  final txtLCpseController = TextEditingController();

  bool activeContact = true;

  final txtNumberController = TextEditingController();
  bool isMobile = true;
  bool isPersonal = true;

  Widget _app_Oops() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader('Contacts'),
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
                        Icons.error,
                        size: 80.0,
                        color: Colors.red
                    ),
                    Text('Something went wrong',
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

  void _setCachedContacts() async{
    contacts = await contact.getCachedContacts();
    contactsCopy = contacts.toList();
    _app_contact_filter();
    setState(() {
      selectedState = constants.STATE_MODULE_CONTACT;
    });
  }

  void _mongoAtlas_contacts() async{
    try {
      _app_contact_spinner_show('Loading...');
      // _mongoAtlas specific
      contacts = await contact.findAllContacts();
      // common to both
      contact.cacheContacts(contacts);
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_MODULE_CONTACT;
      });
      String count = contacts.length.toString();
      appUtil.showSuccessSnackBar(context, 'Success, $count contacts fetched');

    } catch (e) {
      appUtil.showFailureSnackBar(context, 'Oh, Something has gone wrong');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _googleDrive_contacts() async{
    try {
      _app_contact_spinner_show('Loading...');
      // _googleDrive specific
      contacts = await contact.getContactsFromGoogleDrive(widget.currentUser);
      // common to both
      contact.cacheContacts(contacts);
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_MODULE_CONTACT;
      });
      String count = contacts.length.toString();
      appUtil.showSuccessSnackBar(context, 'Success, $count contacts fetched');

    } catch (e) {
      appUtil.showFailureSnackBar(context, 'Oh, Something has gone wrong');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _mongoAtlas_contact_save(model.Contact oneContact) async{
    try {
      _app_contact_spinner_show('Saving...');
      // _mongoAtlas specific
      await contact.saveContact(oneContact);
      contacts = await contact.findAllContacts();
      // common to both
      contact.cacheContacts(contacts);
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_MODULE_CONTACT_ONE;
      });
      appUtil.showSuccessSnackBar(context, 'Success, Save done.');

    } catch (e) {
      appUtil.showFailureSnackBar(context, 'Oops! Save attempt failed.');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _googleDrive_contact_save(model.Contact oneContact) async{
    try {
      _app_contact_spinner_show('Saving...');
      // _googleDrive specific
      // if(oneContact.id==null){
      //   oneContact.id = 'gd${appUtil.getKey()}';
      //   contacts.add(oneContact);
      // }else{
      //   for (var j = 0; j < contacts.length; j++) {
      //     if(oneContact.id==contacts[j].id){
      //       contacts[j] = oneContact;
      //       break;
      //     }
      //   }
      // }
      contacts = await contact.saveContactsToGoogleDrive(oneContact, contactsCopy, widget.currentUser);
      // common to both
      contact.cacheContacts(contacts);
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_MODULE_CONTACT_ONE;
      });
      appUtil.showSuccessSnackBar(context, 'Success, Save done.');

    } catch (e) {
      appUtil.showFailureSnackBar(context, 'Oops! Save attempt failed.');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _mongoAtlas_contact_delete(String _id) async{
    try {
      _app_contact_spinner_show('Deleting...');
      // _mongoAtlas specific
      await contact.deleteContact(_id);
      contacts = await contact.findAllContacts();
      // common to both
      contact.cacheContacts(contacts);
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_MODULE_CONTACT;
      });
      appUtil.showSuccessSnackBar(context, 'Success, Delete done.');

    } catch (e) {
      appUtil.showFailureSnackBar(context, 'Oops! Delete attempt failed.');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  void _googleDrive_contact_delete(String _id) async{
    try {
      _app_contact_spinner_show('Deleting...');
      // _googleDrive specific
      for (var j = 0; j < contactsCopy.length; j++) {
        if(_id==contactsCopy[j].id){
          contactsCopy.removeAt(j);
          break;
        }
      }
      //await contact.saveContactsToGoogleDrive(contacts, widget.currentUser);
      contacts = await contact.saveContactsToGoogleDrive(null, contactsCopy, widget.currentUser);

      // common to both
      contact.cacheContacts(contacts);
      contactsCopy = contacts.toList();
      _app_contact_filter();
      setState(() {
        selectedState = constants.STATE_MODULE_CONTACT;
      });
      appUtil.showSuccessSnackBar(context, 'Success, Delete done.');

    } catch (e) {
      appUtil.showFailureSnackBar(context, 'Oops! Delete attempt failed.');
      setState(() {
        selectedState = constants.STATE_ERROR_UNEXPECTED;
      });
      print(e);
    }
  }

  Widget _app_contact() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader('Contacts'),
        Container(
          color: Colors.white,
          child: Column(children: <Widget>[
            const SizedBox(
              height: 5,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              // const SizedBox(
              //   width: 5,
              // ),
              const SizedBox(
                width: 5,
              ),
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: 'Sync',
                onPressed: () {
                  if(_contactsStorage==constants.MODULE_CONTACT_STORAGE_GOOGLE_DRIVE){
                    _googleDrive_contacts();
                  }else{
                    _mongoAtlas_contacts();
                  }
                },
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  // child: Text('Bottom', textAlign: TextAlign.center),

                  child: TextField(
                    controller: txtSearchController,
                    //onChanged: (value) => filterContacts(value),
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      suffixIcon: IconButton(
                        onPressed: () {
                          txtSearchController.clear();
                          _app_contact_filter_show();
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const SizedBox(
                width: 5,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Filter contacts',
                onPressed: () {
                  _app_contact_filter_show();
                },
              ),
            ]),
          ]),
        ),
        contacts.length == 0
            ? _app_Oops_NO_Contacts()
            : Expanded(
                child: Container(
                  color: Colors.white,
                  // child: Text('Bottom', textAlign: TextAlign.center),

                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: contacts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _app_contact_tile(
                            index,
                            '${contacts[index].fname} ${contacts[index].lname}',
                            '${contacts[index].cpse}',
                            Icons.person);
                      }),
                ),
              ),
      ],
    );
  }

  Widget _app_Oops_NO_Contacts() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Oops!!!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                //fontStyle: FontStyle.italic,
                fontSize: 30.0,
              ),
            ),
            Icon(Icons.contacts, size: 80.0, color: Colors.blue),
            Text(
              'Refresh to get the contacts',
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _app_contact_show(){
    setState(() {
      selectedState = constants.STATE_MODULE_CONTACT;
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // After build() method this code inside will triggers
        _scrollDown();
      });
    });
  }

  // scrolling down with an animated effect
  // void _scrollDown() {
  //   _scrollController.animateTo(
  //     _scrollController.position.maxScrollExtent,
  //     duration: Duration(seconds: 2),
  //     curve: Curves.fastOutSlowIn,
  //   );
  // }

  void _scrollDown() {
    //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(_offset);
  }

  void _app_contact_spinner_show(String lm){
    setState(() {
      load_msg = lm;
      selectedState = constants.STATE_MODULE_CONTACT_SPINNER;
    });
  }

  String load_msg='';
  Widget _app_contact_spinner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader(load_msg),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Circular progress indicator',
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<model.Contact> _app_contact_filter() {
    var value = txtSearchController.text;

    List<model.Contact> filteredContacts = [];
    if (value.toString().trim().length > 0) {
      contactsCopy.forEach((element) {
        model.Contact contact = element;
        if (contact.fname
            .toString()
            .toLowerCase()
            .indexOf(value.toString().trim().toLowerCase()) >=
            0 ||
            contact.lname
                .toString()
                .toLowerCase()
                .indexOf(value.toString().trim().toLowerCase()) >=
                0 ||
            contact.cpse
                .toString()
                .toLowerCase()
                .indexOf(value.toString().trim().toLowerCase()) >=
                0) {
          filteredContacts.add(contact);
        }
      });
      contacts = filteredContacts.toList();
    } else {
      contacts = contactsCopy.toList();
    }
    return contacts;
  }

  void _app_contact_filter_show(){
    contacts = _app_contact_filter();
    setState(() {
    });
  }

  ListTile _app_contact_tile(index, String title, String subtitle, IconData icon) {
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
            IconButton(onPressed:  () { _app_contact_one_show(index); }, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () { _app_contact_delete_contact(index); }, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  Future<void> _app_contact_delete_contact(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Want to delete this contact?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
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
                String _id = contacts[index].id ?? '';
                if(_contactsStorage==constants.MODULE_CONTACT_STORAGE_GOOGLE_DRIVE){
                  _googleDrive_contact_delete(_id);
                }else{
                  _mongoAtlas_contact_delete(_id);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  model.Contact _app_contact_new_contact(){
    List<model.Number> numbers = [];
    model.Contact contact = new model.Contact(numbers: numbers );
    contact?.active = 'Y';
    return contact;
  }

  void _app_contact_one_populate(){
    txtFnameController.text = selectedContact?.fname ?? '';
    txtLnameController.text = selectedContact?.lname ?? '';
    txtLCpseController.text = selectedContact?.cpse ?? '';
    activeContact = (selectedContact?.active=='Y' ?? true);
  }

  void _app_contact_one_show(int index){
    selectedNumber = null; // initialize
    try {
      _offset = _scrollController?.offset ?? _offset;
    } catch (e) {
      print(e);
    }
    if(index>=0)
      //selectedContact = contacts[index];

      // Creating a new Contact object from edit to till save or cancel changes
      selectedContact = model.Contact.fromJson(contacts[index].toJson(),source: 'local');

    setState(() {
      _app_contact_one_populate();
      selectedState = constants.STATE_MODULE_CONTACT_ONE;
    });
  }

  Widget _app_contact_one() {
    return Column(
      children: <Widget>[
        _buildHeader('Contacts > Contact'),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: txtFnameController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'First name',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: txtLnameController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Last name',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: txtLCpseController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Company, Service type, Place, Event or Else',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row( mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              const SizedBox(
                width: 5,
              ),
              const Text(
                'Active',
                style: TextStyle(fontSize: 18),
              ),
              // const SizedBox(
              //   width: 5,
              // ),
              Switch(
                // This bool value toggles the switch.
                value: activeContact,
                //inactiveThumbColor: Colors.red,
                //inactiveTrackColor : Colors.red,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    activeContact = value;
                  });
                },
              ),
              const SizedBox(
                width: 30,
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  _app_contact_one_save();

                  // Setting: inter widget communication between from child to parent
                  // just to test message passing from this widget to parent widget
                  widget.changeNotifier.sink.add(constants.STATE_MODULE_CONTACT_ONE);
                },
                child: const Text(
                  'Save',
                  //style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white54,
                  onPrimary: Colors.black38,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  _app_contact_show();
                },
                child: const Text(
                  'Cancel',
                  //style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 10),
            ]),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            // child: Text('Bottom', textAlign: TextAlign.center),

            child: ListView.builder(
                itemCount: selectedContact?.numbers.length,
                itemBuilder: (BuildContext context, int index) {
                  return _app_contact_one_tile_numbers(index, '${selectedContact?.numbers[index].number}' , Icons.phone );
                }
            ),
          ),

          // child: Container(
          //   color: Colors.white,
          // ),
        ),
      ],
    );
  }

  ListTile _app_contact_one_tile_numbers(int index, String number, IconData icon) {
    return ListTile(
      title: Text(number,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      //subtitle: Text(subtitle),

      // leading: Icon(
      //   icon,
      //   color: Colors.blue[500],
      //
      // ),
      leading: IconButton(
        icon: const Icon(Icons.phone),
        tooltip: 'Tap to dial',
        color: Colors.blue[500],
        onPressed: () {_app_contact_one_dialCall(number);},
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            //IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton(onPressed:  () {_app_contact_number_show(index);}, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {_app_contact_one_delete_number(index);}, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  Future<void> _app_contact_one_dialCall(String phoneNumber) async {
    appUtil.dialCall(phoneNumber);
  }

  Future<void> _app_contact_one_delete_number(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete number'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Want to delete this number ?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
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
                String? name = selectedContact?.numbers[index].number;
                setState(() {
                  selectedContact?.numbers.removeAt(index);
                });
                appUtil.showSuccessSnackBar(context, 'Number $name removed. ');
                _app_contact_one_show(-1);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _app_contact_one_save(){
    _app_contact_one_set();
    model.Contact contact = selectedContact ?? _app_contact_new_contact();
    print('OK');
    if(_contactsStorage==constants.MODULE_CONTACT_STORAGE_GOOGLE_DRIVE){
      _googleDrive_contact_save(contact);
    }else{
      _mongoAtlas_contact_save(contact);
    }
  }

  void _app_contact_one_set(){
    // save controller values to models
    // before move to different screen
    selectedContact?.fname = txtFnameController.text;
    selectedContact?.lname = txtLnameController.text;
    selectedContact?.cpse = txtLCpseController.text;
    selectedContact?.active = (activeContact)?'Y':'N';
  }

  void _app_contact_number_populate(){
    _app_contact_one_set();
    txtNumberController.text = selectedNumber?.number ?? '';

    //1omx 1/0 : default/no, o/w : own/work, m/l mob/land, f/x : fax/no
    String type = selectedNumber?.type ?? '0omx';
    type = (type.length==4)? type : '0omx';
    isPersonal = !(type.substring(1,2)=='o' ?? false);
    isMobile = !(type.substring(2,3)=='m' ?? false);
  }

  void _app_contact_number_show(int index){
    if (index>=0) {
      // Edit number
      selectedNumber = selectedContact?.numbers[index];
      _app_contact_number_populate();
    }else{
      // Add number
      isPersonal = false;
      isMobile = false;
      txtNumberController.text = '';
      _app_contact_one_set();
    }
    setState(() {
      selectedState = constants.STATE_MODULE_CONTACT_NUMBER;
    });
  }

  // This is how a usual widget surrounded by a scrollable silver
  // Ex: conversion of the widget _app_contact_number() to scrollable silver _app_contact_number_silver(){
  Widget _app_contact_number_silver(){
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Container(
                color:  Colors.white,
                height: 700,
                child: _app_contact_number(),
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }

  Widget _app_contact_number() {
    return Column(
      children: <Widget>[
        _buildHeader('Contacts > Contact > Number'),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: txtNumberController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Number',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 5,
                ),
                Row( mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          minimumSize: const Size(100, 40),
                        ),
                        onPressed: () {
                          //_app_contact_saveContact();
                          __app_contact_number_set();
                        },
                        child: const Text(
                          'OK',
                          //style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white54,
                          onPrimary: Colors.black38,
                          minimumSize: const Size(100, 40),
                        ),
                        onPressed: () {
                          _app_contact_one_show(-1);
                        },
                        child: const Text(
                          'Cancel',
                          //style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      //const SizedBox(width: 10),
                      //const SizedBox(width: 10),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        'Personal',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Switch(
                        // This bool value toggles the switch.
                        value: isPersonal,
                        //inactiveThumbColor: Colors.red,
                        //inactiveTrackColor : Colors.red,
                        activeColor: Colors.red,
                        onChanged: (bool value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            isPersonal = value;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        'Official',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        '     Mob',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Switch(
                        // This bool value toggles the switch.
                        value: isMobile,
                        //inactiveThumbColor: Colors.red,
                        //inactiveTrackColor : Colors.red,
                        activeColor: Colors.red,
                        onChanged: (bool value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            isMobile = value;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        'Fixed',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ]),
              ]
          ),
        ),
      ],
    );
  }

  void __app_contact_number_set(){
    if(txtNumberController.text.trim().length==0){
      return;
    }

    String type = __app_contact_number_type();

    if (selectedNumber!=null){
      selectedNumber?.number = txtNumberController.text;
      selectedNumber?.type = type;
    }else{
      selectedContact?.addNumber(
          model.Number(
            number: txtNumberController.text,
            type: type,
          )
      );
    }
    _app_contact_one_show(-1);
  }

  String __app_contact_number_type(){
    //1omx 1/0 : default/no, o/w : own/work, m/l mob/land, f/x : fax/no
    String o = !isPersonal?'o':'w';
    String m = !isMobile ?'m':'p';
    String type ='0 $o $m x'.replaceAll(' ', '');
    return type;
  }

}