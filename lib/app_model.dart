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
