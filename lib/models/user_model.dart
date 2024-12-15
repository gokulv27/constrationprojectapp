class User {
  final String accessToken;
  final String refreshToken;

  User({required this.accessToken, required this.refreshToken});

  // Factory method to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accessToken: json['access'],
      refreshToken: json['refresh'],
    );
  }
}
