class User {
  static final User _singleton = User._internal();

  factory User() {
    return _singleton;
  }

  User._internal();

  String? username;

  void setUsername(String username) {
    this.username = username;
  }
}