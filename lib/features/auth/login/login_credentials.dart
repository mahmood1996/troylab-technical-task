class LoginCredentials {
  const LoginCredentials({this.username = '', this.password = ''});

  final String username;
  final String password;

  bool isUsernameOrPasswordEmpty() {
    return username.isEmpty || password.isEmpty;
  }

  LoginCredentials copyWith(String? username, String? password) {
    return LoginCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
