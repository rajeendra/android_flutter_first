
class Person {
  final String name;
  final String address;

  const Person(this.name, this.address);
}

class Config {
  static final String METHOD_EDIT = "edit";
  static final String METHOD_ADD = "add";
  final String method;
  final String strValue;
  final int intValue;

  Config( this.method, { this.strValue="", this.intValue=0 } );
}

class Result {
  final Config config;
  final Person person;

  const Result(this.config, [this.person=const Person("","")] );
}
