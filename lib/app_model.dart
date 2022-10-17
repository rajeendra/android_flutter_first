class AppConfiguration{
  static final APP_CONFIG_KRY = 'app_config_aff';

  String? user = '<user>';
  String? password = '<password>';
  String? apiKey = '<API-KEY>';

  AppConfiguration({this.user,this.password, this.apiKey});

  AppConfiguration.fromJson(Map<String, dynamic> jsonMap)
      : user = jsonMap['user'],
        password = jsonMap['password'],
        apiKey = jsonMap['apiKey'];

  Map<String, dynamic> toJson() => {
    'user': user,
    'password': password,
    'apiKey': apiKey,
  };
}

class Message{
  static final ALL = 'all';
  static final PARENT = 'Parent';
  static final CHILD = 'Child';
  static final CHILD_1 = 'First Child Widget';
  static final CHILD_2 = 'Second Child Widget';

  String sender = '<sender>';
  String receiver = '<receiver>';
  String message = '<message>';

  Message({required this.sender,required this.receiver, required this.message});

  Message.fromJson(Map<String, dynamic> jsonMap)
      : sender = jsonMap['sender'],
        receiver = jsonMap['receiver'],
        message = jsonMap['message'];

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'receiver': receiver,
    'message': message,
  };
}
