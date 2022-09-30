
// class AppConfiguration{
//   static final APP_CONFIG_KRY = 'app_config_aff';
//
//   String? user = '<user>';
//   String? password = '<password>';
//   String? apiKey = '<API-KEY>';
//
//   AppConfiguration({this.user,this.password, this.apiKey});
//
//   AppConfiguration.fromJson(Map<String, dynamic> jsonMap)
//       : user = jsonMap['user'],
//         password = jsonMap['password'],
//         apiKey = jsonMap['apiKey'];
//
//   Map<String, dynamic> toJson() => {
//     'user': user,
//     'password': password,
//     'apiKey': apiKey,
//   };
// }

class Contact {
  String? id;
  String? fname;
  String? lname;
  String? cpse;
  String? active;
  List<Number> numbers=[];
  Address? address;

  Contact({
    this.id,
    this.fname,
    this.lname,
    this.cpse,
    this.active,
    required this.numbers,
    this.address,
  });

  factory Contact.fromJson(Map<String, dynamic> jsonMap) {

    Map<String, dynamic> addressMap = jsonMap['address'] ?? Map<String, dynamic>();
    List numbersIn = jsonMap['numbers'];
    List<Number> numbersOut=[];

    numbersIn.forEach((element) {
      Number number = Number.fromJson(element);
      numbersOut.add(number);
    });

    return Contact(
        id: jsonMap['_id'].$oid,
        fname: jsonMap['fname'],
        lname: jsonMap['lname'],
        cpse: jsonMap['cpse'],
        active: jsonMap['active'],
        numbers: numbersOut,
        address: Address(
          no: addressMap['no'],
          street: addressMap['street'],
          city: addressMap['city'],
        )
    );
  }

  Map<String, dynamic> toJson() => getContsctJson();

  Map<String, dynamic> getContsctJson(){

    List<Map<String, dynamic>> numbersJSON=[];

    numbers.forEach((element) {
      final Map<String, dynamic> oneNumber = {
        "id": element.id,
        "number": element.number,
        "type": element.type,
      };
      numbersJSON.add(oneNumber);
    });

    Map<String, dynamic> addressMap = {
      'no' : address?.no,
      'street': address?.street,
      'city': address?.city
    };

    return {
      'fname': fname,
      'lname': lname,
      'cpse': cpse,
      'active': active,
      'numbers': numbersJSON,
      'addres': addressMap
    };
  }
}

class Number {
  String? id;
  String? number;
  String? type;

  Number({
    this.id,
    this.number,
    this.type,
  });

  factory Number.fromJson(Map<String, dynamic> jsonMap) {
    return Number(
      id: jsonMap['id'],
      number: jsonMap['number'],
      type: jsonMap['type'],
    );
  }
}

class Address {
  String? no;
  String? street;
  String? city;

  Address({
    this.no,
    this.street,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> jsonMap) {
    return Address(
      no: jsonMap['no'],
      city: jsonMap['city'],
      street: jsonMap['street'],
    );
  }
}


