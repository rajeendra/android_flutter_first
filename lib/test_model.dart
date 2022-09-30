

// Object class with fromJson()
class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

// Object class with fromJson() and toJson() to deserialize and serialize
class User {
  final String name;
  final String email;

  User(this.name, this.email);

  User.fromJson(Map<String, dynamic> jsonMap)
      : name = jsonMap['name'],
        email = jsonMap['email'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
  };
}